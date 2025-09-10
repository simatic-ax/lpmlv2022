USING Siemens.Simatic.S71500.Clocks;
USING System.DateTime;
NAMESPACE Simatic.Ax.LPMLV2022
///================================================================================
/// SIEMENS AG
/// (c)Copyright 2025 All Rights Reserved
///--------------------------------------------------------------------------------
/// Library: LPMLV2022
/// Engineering: SIMATIC AX
/// Restrictions: -
/// Requirements: S7-1500 FW 2.6
/// Functionality: Machine and Unit States according to ANSI/ISA-TR88.00.02-2022
///                (if the default settings are active at 'holdCmdCfg' and 'completeCmdCfg')
///================================================================================	
FUNCTION_BLOCK LPMLV2022_UnitModeStateManager
   {S7.extern = ReadWrite}
   VAR_INPUT 
      UnitMode : DInt := LPMLV2022_ModeConstants#MODE_INVALID;   // Requested unit mode
      UnitModeChangeRequest : Bool;   // TRUE: Request unit mode
      CntrlCmd : DInt := LPMLV2022_CommandConstants#CMD_UNDEFINED;   // Request control command
      CmdChangeRequest : Bool;   // TRUE: Enable change into requested state
      SC : Bool;   // State change from FALSE to TRUE (rising edge) triggers state complete signal
	  config : LPMLV2022_typeConfiguration := (
		DisabledStatesCfg := [32(DWORD#16#0)],
		ModeTransitionCfg := [DWORD#0, 31(DWORD#16#00000214)]); // FB configuration (is taken into account in first call after STOP/RUN)
   END_VAR

   {S7.extern = ReadOnly}
   VAR_OUTPUT 
      UnitModeCurrent  : DInt := LPMLV2022_ModeConstants#MODE_MANUAL;   // Current unit mode
      StateCurrent  : DInt := LPMLV2022_StateConstants#STATE_STOPPED;   // Current state
      StateRequested  : DInt := LPMLV2022_StateConstants#STATE_STOPPED;   // Requested state
      StateChangeInProcess  : Bool;   // State change in process
      CurDisabledStates  : DWord;   // Disabled states in current unit mode
      curHoldCmdCfg  : DWord;   // Bit locations within the DWORD represent State numbers. A value of 1 in a bit location indicates that the Hold control command is taken into account in the corresponding state
      curCompleteCmdCfg  : DWord;   // Bit locations within the DWORD represent State numbers. A value of 1 in a bit location indicates that the Complete control command is taken into account in the corresponding state
      unitModeChangeNotAllowed  : Bool;   // TRUE: Requested unit mode change is not allowed (output is reset with the next successful unit mode change or if input 'UnitMode' is set to 0 or if input 'UnitModeChangeRequest' is set to FALSE)
      cntrlCmdNotAllowed  : Bool;   // TRUE: Control command is not allowed (output is reset with the next successful CntrlCmd or if input 'CntrlCmd' is set to 0 or if input 'CmdChangeRequest' is set to FALSE)
      diagnostics  : LPMLV2022_typeDiagnostics;   // Diagnostics information of FB
   END_VAR

   VAR 
      statConfiguration  : LPMLV2022_typeConfiguration := (
		DisabledStatesCfg := [32(DWORD#16#0)],
		ModeTransitionCfg := [DWORD#0, 31(DWORD#16#00000214)]);   // FB configuration
      statUnitModeChangeRequest  : Bool;   // TRUE: Enable change into requested unit mode
      statCmdChangeRequest  : Bool;   // TRUE: Enable change into requested state
      statFirstCycle  : Bool := TRUE;   // First cycle of run
      statSCOld  : Bool;   // For edge detection
      statUnitMode  : DInt := LPMLV2022_ModeConstants#MODE_MANUAL;   // Current command mode
      statUnitModeOld  : DInt := LPMLV2022_ModeConstants#MODE_MANUAL;   // For edge detection
      statUnitModeCurrentInternal  : DInt := LPMLV2022_ModeConstants#MODE_MANUAL;   // Current internal mode
      statUnitModeCurrentInternalOld  : DInt := LPMLV2022_ModeConstants#MODE_INVALID;   // For edge detection
      statStateCurrentOld  : DInt := LPMLV2022_StateConstants#STATE_STOPPED;   // For edge detection
      statStateInternal  : DInt := LPMLV2022_StateConstants#STATE_STOPPED;   // Current internal state
      statStateInternalOld  : DInt := LPMLV2022_StateConstants#STATE_UNDEFINED;   // For edge detection
      statCntrlCmdOld  : DInt := LPMLV2022_CommandConstants#CMD_UNDEFINED;   // For edge detection
      statStatesInCurrentMode  : LPMLV2022_typeStatesInCurrentMode;   // Copied from configuration
      statConsiderHoldCmdIn  : LPMLV2022_typeConsiderHoldCmdIn;   // Copied from configuration
      statConsiderCompleteCmdIn  : LPMLV2022_typeConsiderCompleteCmdIn;   // Copied from configuration
      statCmdChangeRequestOld  : Bool;   // For edge detection
      statUnitModeChangeRequestOld  : Bool;   // For edge detection
      statDiagnosticsBufferIndex  : Int := -1;   // Index of actual diagnostics buffer entry
      statStateRequested  : DInt := LPMLV2022_StateConstants#STATE_STOPPED;   // Static variable for requested state
      statUnitModeChangeNotAllowed  : Bool;   // Static value for output 'unitModeChangeNotAllowed'
      statCntrlCmdNotAllowed  : Bool;   // Static value for output 'cntrlCmdNotAllowed'
   END_VAR

   VAR_TEMP 
      tempDWord1 : DWord;
      tempDWord2 : DWord;
      tempCntrlCmd : DInt;   // Temporary control command
      tempSCInternal : Bool;   // Internal state complete
      tempRetVal : Word;   // Tag for system function
      tempDiagnosticsBufferIndexSC : Int;   // Index of actual diagnostics buffer entry for SC messages
      tempDiagnosticsBufferIndexCmd : Int;   // Index of actual diagnostics buffer entry for control command messages

	  tempSysTime : LDATE_AND_TIME; // for parsing to DTL type
	  tempYear, tempMonth, tempDay, tempWeekday, tempHour, tempMinute, tempSecond, tempMillisecond, tempMicrosecond, tempNanosecond : INT;
   END_VAR

   VAR CONSTANT 
      MSG_NO_MESSAGE : Byte := BYTE#16#00;   // Initial value
      MSG_MODE_CHANGED_SUCCESSFULLY : Byte := BYTE#16#01;   // Unit mode changed successfully
      MSG_STATE_CHANGED_SUCCESSFULLY : Byte := BYTE#16#02;   // State changed successfully
      MSG_MODE_ALREADY_ACTIVE : Byte := BYTE#16#03;   // Requested unit mode already active
      MSG_MODE_NOT_DEFINED : Byte := BYTE#16#80;   // Unit mode not defined
      MSG_CMD_NOT_DEFINED : Byte := BYTE#16#81;   // Control command not defined
      MSG_REQ_MODE_NOT_CONFIGURED : Byte := BYTE#16#82;   // Requested unit mode not configured - check 'configuration.EnabledModesCfg'
      MSG_MODE_TRANSITION_NOT_ALLOWED : Byte := BYTE#16#83;   // Unit mode transition in this state not allowed - check 'configuration.ModeTransitionCfg[]' of the current mode and the requested mode. The corresponding state bit must be set for both modes
      MSG_CMD_NOT_ALLOWED : Byte := BYTE#16#84;   // Control command in this state not allowed
      MSG_SC_NOT_ALLOWED : Byte := BYTE#16#85;   // SC in this state not allowed
      MSG_STATE_CONFIG_FORCED : Byte := BYTE#16#86;   // State configuration forced to OMAC standard (corrected configuration -> see FB output 'CurDisabledStates')
      MSG_MODE_TRANSITION_NOT_POSSIBLE : Byte := BYTE#16#87;   // Unit mode transition in this state not possible, because the current state is not available in the requested mode - check 'configuration.DisabledStatesCfg[]' of the requested mode
      MSG_SC_OVERRIDDEN_BY_CMD_HOLD : Byte := BYTE#16#88;   // SC overridden by control command Hold
   END_VAR


	

	
	
	IF NOT statCmdChangeRequest AND statCmdChangeRequestOld THEN // Falling edge CmdChangeRequest
	  statCntrlCmdOld := LPMLV2022_CommandConstants#CMD_UNDEFINED;
	END_IF;
	statCmdChangeRequestOld := statCmdChangeRequest;
	
	IF NOT statUnitModeChangeRequest AND statUnitModeChangeRequestOld THEN // Falling edge UnitModeChangeRequest
	  statUnitModeOld := LPMLV2022_ModeConstants#MODE_INVALID;
	END_IF;
	statUnitModeChangeRequestOld := statUnitModeChangeRequest;
	
	diagnostics.bufferIndex := statDiagnosticsBufferIndex;
	tempDiagnosticsBufferIndexSC  := -1;
	tempDiagnosticsBufferIndexCmd := -1;
	
	StateCurrent    := statStateInternal;
	UnitModeCurrent := statUnitModeCurrentInternal;
	
	IF statFirstCycle THEN // Initialize values in first cycle
	  statConfiguration := config; // Copy configuration from input
	  statConfiguration.EnabledModesCfg.%X3 := TRUE; // Unit mode Manual is mandatory
	
	//--------------------------------------------------------------------------------------------------
	// Unit mode manager
	//--------------------------------------------------------------------------------------------------
	ELSE // As from second cycle
	  //------------------------------------------------
	  // Evaluation of input parameters -> UnitMode, CntrlCmd
	  //------------------------------------------------
	  statUnitMode := UnitMode;
	  tempCntrlCmd := CntrlCmd;
	  
	  // Set change requests from input
	  statUnitModeChangeRequest := UnitModeChangeRequest;
	  statCmdChangeRequest      := CmdChangeRequest;
	  
	  //------------------------------------------------
	  //Message handling for mode manager: head part
	  //------------------------------------------------
	  IF statUnitModeChangeRequest AND statUnitMode <> statUnitModeOld AND statUnitMode <> LPMLV2022_ModeConstants#MODE_INVALID THEN
	    statDiagnosticsBufferIndex := statDiagnosticsBufferIndex + 1; // Next buffer index
	    IF statDiagnosticsBufferIndex > LPMLV2022_LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
	      statDiagnosticsBufferIndex := 0;
	    END_IF;
	    // Check for defined unit modes
		tempRetVal := GetLocalDateTime(value => tempSysTime);
		SplitDateAndTime(
			value := tempSysTime,
			year => tempYear,
			month => tempMonth,
			day => tempDay,
			hour => tempHour,
			minute => tempMinute,
			second => tempSecond,
			millisecond => tempMillisecond,
			microsecond => tempMicrosecond,
			nanosecond => tempNanosecond
		);
	    diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;


	    diagnostics.buffer[statDiagnosticsBufferIndex].UnitModeCurrent := TO_SINT(UnitModeCurrent);
	    diagnostics.buffer[statDiagnosticsBufferIndex].StateCurrent := TO_SINT(StateCurrent);
	    diagnostics.buffer[statDiagnosticsBufferIndex].UnitMode := TO_SINT(statUnitMode);
	    diagnostics.buffer[statDiagnosticsBufferIndex].CntrlCmd := TO_SINT(tempCntrlCmd);
	    diagnostics.buffer[statDiagnosticsBufferIndex].SC := SC;
	    diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_NO_MESSAGE;
	    
	    IF statUnitMode < LPMLV2022_ModeConstants#MODE_INVALID OR statUnitMode > LPMLV2022_ModeConstants#MODE_USER_28 THEN
	      diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_MODE_NOT_DEFINED;
	      statUnitModeChangeNotAllowed := TRUE;
	    ELSIF statUnitMode = statUnitModeCurrentInternal THEN
	      diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_MODE_ALREADY_ACTIVE;
	      statUnitModeChangeNotAllowed := TRUE;
	    END_IF;
	  END_IF; // End: message handling for mode manager: head part
	END_IF;
	
	//------------------------------------------------
	// Unit mode machine
	//------------------------------------------------
	// Check if unit mode has to be changed
	IF (statUnitModeChangeRequest AND
	  statUnitMode <> statUnitModeCurrentInternal AND
	  statUnitMode <> statUnitModeOld AND
	  statUnitMode > LPMLV2022_ModeConstants#MODE_INVALID AND
	  statUnitMode <= LPMLV2022_ModeConstants#MODE_USER_28
	  ) OR
	  statFirstCycle
	THEN
	  // Is a mode transition in the current state allowed? 
	  // -> Check mode transition config. The corresponding state bit for statStateInternal must be present in ModeTransitionCfg[statUnitMode] AND ModeTransitionCfg[statUnitModeCurrentInternal]
	  tempDWord1 := SHR(statConfiguration.ModeTransitionCfg[statUnitMode], TO_UINT(statStateInternal)); // Shift the bit, whose bit position corresponds to the value of statStateInternal to bit position zero (tempDWord1.%X0)
	  tempDWord2 := SHR(statConfiguration.ModeTransitionCfg[statUnitModeCurrentInternal], TO_UINT(statStateInternal)); // Shift the bit, whose bit position corresponds to the value of statStateInternal to bit position zero (tempDWord2.%X0)
	
	  IF (tempDWord1.%X0 = FALSE OR tempDWord2.%X0 = FALSE) AND NOT statFirstCycle THEN // Mode transition is not allowed
	    diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_MODE_TRANSITION_NOT_ALLOWED;
	    statUnitModeChangeNotAllowed := TRUE;
	
	  ELSE // (tempDWord1.%X0 = TRUE AND tempDWord2.%X0 = TRUE) -> The state bit of the current state is set in both mode transition config DWords, i.e. mode transition is allowed
	    // Requested unit mode enabled? -> Is the corresponding bit set in the EnabledModesCfg DWord?
	    tempDWord1 := SHR(statConfiguration.EnabledModesCfg, TO_UINT(statUnitMode)); // Shift the bit, whose bit position corresponds to the value of statUnitMode to bit position zero (tempDWord1.%X0)
	    
	    IF (tempDWord1.%X0 = TRUE) THEN // Requested unit mode is enabled
	      // State in requested unit mode available or rather not disabled? (Stopped, Idle, Execute and Aborted are always present. They cannot be disabled. Every acting state can be disabled)
	      IF ((statStateInternal = LPMLV2022_StateConstants#STATE_CLEARING)     AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X1 = TRUE))  OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_STARTING)     AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X3 = TRUE))  OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_SUSPENDED)    AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X13 = TRUE) AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X14 = TRUE) AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X5 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_STOPPING)     AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X7 = TRUE))  OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_ABORTING)     AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X8 = TRUE))  OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_HOLDING)      AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X10 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_HELD)         AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X10 = TRUE) AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X12 = TRUE) AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X11 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_UNHOLDING)    AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X12 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_SUSPENDING)   AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X13 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_UNSUSPENDING) AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X14 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_RESETTING)    AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X15 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_COMPLETING)   AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X16 = TRUE)) OR
	         ((statStateInternal = LPMLV2022_StateConstants#STATE_COMPLETED)    AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X16 = TRUE) AND (statConfiguration.DisabledStatesCfg[statUnitMode].%X17 = TRUE))
	      THEN // Error - state is not available in target unit mode
	        diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_MODE_TRANSITION_NOT_POSSIBLE;
	        statUnitModeChangeNotAllowed := TRUE;
	
	      ELSE // State in requested unit mode is available (or is going to be available, because the state configuration is adapted afterwards)
	        // Set internal variable
	        statUnitModeCurrentInternal := statUnitMode;
	        
	        // Read current configuration for the states
	        statStatesInCurrentMode.clearing := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X1;
	        statStatesInCurrentMode.stopped := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X2;
	        statStatesInCurrentMode.starting := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X3;
	        statStatesInCurrentMode.idle := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X4;
	        statStatesInCurrentMode.suspended := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X5;
	        statStatesInCurrentMode.execute := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X6;
	        statStatesInCurrentMode.stopping := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X7;
	        statStatesInCurrentMode.aborting := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X8;
	        statStatesInCurrentMode.aborted := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X9;
	        statStatesInCurrentMode.holding := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X10;
	        statStatesInCurrentMode.held := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X11;
	        statStatesInCurrentMode.unholding := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X12;
	        statStatesInCurrentMode.suspending := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X13;
	        statStatesInCurrentMode.unsuspending := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X14;
	        statStatesInCurrentMode.resetting := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X15;
	        statStatesInCurrentMode.completing := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X16;
	        statStatesInCurrentMode.completed := NOT statConfiguration.DisabledStatesCfg[statUnitMode].%X17;
	      END_IF; // End: state in target unit mode available
	    ELSE // (tempDWord1.%X0 = FALSE), i.e. the requested unit mode is not enabled
	      diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_REQ_MODE_NOT_CONFIGURED;
	      statUnitModeChangeNotAllowed := TRUE;
	    END_IF;
	  END_IF;
	  
	  // Set the minimum required states and correct the states configuration for the new current unit mode
	  IF NOT statStatesInCurrentMode.stopped OR
	    NOT statStatesInCurrentMode.idle OR
	    NOT statStatesInCurrentMode.execute OR
	    NOT statStatesInCurrentMode.aborted OR
	    (NOT statStatesInCurrentMode.held AND (statStatesInCurrentMode.holding OR statStatesInCurrentMode.unholding)) OR
	    (NOT statStatesInCurrentMode.suspended AND (statStatesInCurrentMode.suspending OR statStatesInCurrentMode.unsuspending)) OR
	    (NOT statStatesInCurrentMode.completed AND statStatesInCurrentMode.completing)
	  THEN
	    // Minimum required: Stopped, Idle, Execute, Aborted
	    statStatesInCurrentMode.stopped := TRUE;
	    statStatesInCurrentMode.idle    := TRUE;
	    statStatesInCurrentMode.execute := TRUE;
	    statStatesInCurrentMode.aborted := TRUE;
	
	    // Held branch (Held must be present, if Holding OR Unholding are configured)
	    IF NOT statStatesInCurrentMode.held
	      AND (statStatesInCurrentMode.holding OR statStatesInCurrentMode.unholding)
	    THEN
	      statStatesInCurrentMode.held := TRUE;
	    END_IF;
	
	    // Suspended branch (Suspended must be present, if Suspending OR Unsuspending are configured)
	    IF NOT statStatesInCurrentMode.suspended
	      AND (statStatesInCurrentMode.suspending OR statStatesInCurrentMode.unsuspending)
	    THEN
	      statStatesInCurrentMode.suspended := TRUE;
	    END_IF;
	
	    // Completed branch (Completed must be present, if Completing is configured)
	    IF NOT statStatesInCurrentMode.completed
	      AND statStatesInCurrentMode.completing
	    THEN
	      statStatesInCurrentMode.completed := TRUE;
	    END_IF;
	
	    statDiagnosticsBufferIndex := statDiagnosticsBufferIndex + 1; // Next buffer index
	    IF statDiagnosticsBufferIndex > LPMLV2022_LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
	      statDiagnosticsBufferIndex := 0;
	    END_IF;
	    
	    // Write diagnostics
	    //tempRetVal := RD_LOC_T(diagnostics.buffer[statDiagnosticsBufferIndex].timestamp);
		tempRetVal := GetLocalDateTime(value => tempSysTime);
		SplitDateAndTime(
			value := tempSysTime,
			year => tempYear,
			month => tempMonth,
			day => tempDay,
			hour => tempHour,
			minute => tempMinute,
			second => tempSecond,
			millisecond => tempMillisecond,
			microsecond => tempMicrosecond,
			nanosecond => tempNanosecond
		);
	    diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;

	    diagnostics.buffer[statDiagnosticsBufferIndex].UnitModeCurrent := TO_SINT(UnitModeCurrent);
	    diagnostics.buffer[statDiagnosticsBufferIndex].StateCurrent := TO_SINT(StateCurrent);
	    diagnostics.buffer[statDiagnosticsBufferIndex].UnitMode := TO_SINT(statUnitMode);
	    diagnostics.buffer[statDiagnosticsBufferIndex].CntrlCmd := TO_SINT(tempCntrlCmd);
	    diagnostics.buffer[statDiagnosticsBufferIndex].SC := SC;
	    diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_STATE_CONFIG_FORCED;
	  END_IF; // End: set the minimum required states for every unit mode
	  
	  UnitModeCurrent := statUnitModeCurrentInternal; // Write current unit mode on output
	  
	  // Write correct state configuration of current mode
	  CurDisabledStates.%X1 := NOT statStatesInCurrentMode.clearing;
	  CurDisabledStates.%X2 := NOT statStatesInCurrentMode.stopped;
	  CurDisabledStates.%X3 := NOT statStatesInCurrentMode.starting;
	  CurDisabledStates.%X4 := NOT statStatesInCurrentMode.idle;
	  CurDisabledStates.%X5 := NOT statStatesInCurrentMode.suspended;
	  CurDisabledStates.%X6 := NOT statStatesInCurrentMode.execute;
	  CurDisabledStates.%X7 := NOT statStatesInCurrentMode.stopping;
	  CurDisabledStates.%X8 := NOT statStatesInCurrentMode.aborting;
	  CurDisabledStates.%X9 := NOT statStatesInCurrentMode.aborted;
	  CurDisabledStates.%X10 := NOT statStatesInCurrentMode.holding;
	  CurDisabledStates.%X11 := NOT statStatesInCurrentMode.held;
	  CurDisabledStates.%X12 := NOT statStatesInCurrentMode.unholding;
	  CurDisabledStates.%X13 := NOT statStatesInCurrentMode.suspending;
	  CurDisabledStates.%X14 := NOT statStatesInCurrentMode.unsuspending;
	  CurDisabledStates.%X15 := NOT statStatesInCurrentMode.resetting;
	  CurDisabledStates.%X16 := NOT statStatesInCurrentMode.completing;
	  CurDisabledStates.%X17 := NOT statStatesInCurrentMode.completed;
	  
	  // Check in which states the Hold command is to be considered
	  IF statStatesInCurrentMode.held THEN // 1st condition: the Held state must be present
	    // 2nd condition: the corresponding state where Hold shall be considered must be present
	    statConsiderHoldCmdIn.starting     := statStatesInCurrentMode.starting     AND statConfiguration.holdCmdCfg.%X3;
	    statConsiderHoldCmdIn.idle         := statStatesInCurrentMode.idle         AND statConfiguration.holdCmdCfg.%X4;
	    statConsiderHoldCmdIn.suspended    := statStatesInCurrentMode.suspended    AND statConfiguration.holdCmdCfg.%X5;
	    statConsiderHoldCmdIn.execute      := statStatesInCurrentMode.execute      AND statConfiguration.holdCmdCfg.%X6;
	    statConsiderHoldCmdIn.unholding    := statStatesInCurrentMode.unholding    AND statConfiguration.holdCmdCfg.%X12;
	    statConsiderHoldCmdIn.suspending   := statStatesInCurrentMode.suspending   AND statConfiguration.holdCmdCfg.%X13;
	    statConsiderHoldCmdIn.unsuspending := statStatesInCurrentMode.unsuspending AND statConfiguration.holdCmdCfg.%X14;
	    statConsiderHoldCmdIn.completing   := statStatesInCurrentMode.completing   AND statConfiguration.holdCmdCfg.%X16;
	    statConsiderHoldCmdIn.completed    := statStatesInCurrentMode.completed    AND statConfiguration.holdCmdCfg.%X17;
	
	  ELSE // Held state is not present, i.e. Hold command is not allowed in any state
	    statConsiderHoldCmdIn.starting     := FALSE;
	    statConsiderHoldCmdIn.idle         := FALSE;
	    statConsiderHoldCmdIn.suspended    := FALSE;
	    statConsiderHoldCmdIn.execute      := FALSE;
	    statConsiderHoldCmdIn.unholding    := FALSE;
	    statConsiderHoldCmdIn.suspending   := FALSE;
	    statConsiderHoldCmdIn.unsuspending := FALSE;
	    statConsiderHoldCmdIn.completing   := FALSE;
	    statConsiderHoldCmdIn.completed    := FALSE;
	  END_IF;
	  
	  // Write correct state configuration where the Hold command is considered
	  curHoldCmdCfg := DWORD#16#0000_0000;
	  // curHoldCmdCfg.%X1  := FALSE;
	  // curHoldCmdCfg.%X2  := FALSE;
	  curHoldCmdCfg.%X3  := statConsiderHoldCmdIn.starting;
	  curHoldCmdCfg.%X4  := statConsiderHoldCmdIn.idle;
	  curHoldCmdCfg.%X5  := statConsiderHoldCmdIn.suspended;
	  curHoldCmdCfg.%X6  := statConsiderHoldCmdIn.execute;
	  // curHoldCmdCfg.%X7  := FALSE;
	  // curHoldCmdCfg.%X8  := FALSE;
	  // curHoldCmdCfg.%X9  := FALSE;
	  // curHoldCmdCfg.%X10 := FALSE;
	  // curHoldCmdCfg.%X11 := FALSE;
	  curHoldCmdCfg.%X12 := statConsiderHoldCmdIn.unholding;
	  curHoldCmdCfg.%X13 := statConsiderHoldCmdIn.suspending;
	  curHoldCmdCfg.%X14 := statConsiderHoldCmdIn.unsuspending;
	  // curHoldCmdCfg.%X15 := FALSE;
	  curHoldCmdCfg.%X16 := statConsiderHoldCmdIn.completing;
	  curHoldCmdCfg.%X17 := statConsiderHoldCmdIn.completed;
	  
	  // Check in which states the Complete command is to be considered
	  IF statStatesInCurrentMode.completed THEN // 1st condition: the Completed state must be present
	    // 2nd condition: the corresponding state where Complete shall be considered must be present
	    statConsiderCompleteCmdIn.suspended := statStatesInCurrentMode.suspended AND statConfiguration.completeCmdCfg.%X5;
	    statConsiderCompleteCmdIn.execute   := statStatesInCurrentMode.execute   AND statConfiguration.completeCmdCfg.%X6;
	    statConsiderCompleteCmdIn.held      := statStatesInCurrentMode.held      AND statConfiguration.completeCmdCfg.%X11;
	    
	  ELSE // Completed state is not present, i.e. Complete command is not allowed in any state
	    statConsiderCompleteCmdIn.suspended := FALSE;
	    statConsiderCompleteCmdIn.execute   := FALSE;
	    statConsiderCompleteCmdIn.held      := FALSE;
	  END_IF;
	  
	  // Write correct state configuration where the Complete command is considered
	  curCompleteCmdCfg := DWORD#16#0000_0000;
	  // curCompleteCmdCfg.%X1  := FALSE;
	  // curCompleteCmdCfg.%X2  := FALSE;
	  // curCompleteCmdCfg.%X3  := FALSE;
	  // curCompleteCmdCfg.%X4  := FALSE;
	  curCompleteCmdCfg.%X5  := statConsiderCompleteCmdIn.suspended;
	  curCompleteCmdCfg.%X6  := statConsiderCompleteCmdIn.execute;
	  // curCompleteCmdCfg.%X7  := FALSE;
	  // curCompleteCmdCfg.%X8  := FALSE;
	  // curCompleteCmdCfg.%X9  := FALSE;
	  // curCompleteCmdCfg.%X10 := FALSE;
	  curCompleteCmdCfg.%X11 := statConsiderCompleteCmdIn.held;
	  // curCompleteCmdCfg.%X12 := FALSE;
	  // curCompleteCmdCfg.%X13 := FALSE;
	  // curCompleteCmdCfg.%X14 := FALSE;
	  // curCompleteCmdCfg.%X15 := FALSE;
	  // curCompleteCmdCfg.%X16 := FALSE;
	  // curCompleteCmdCfg.%X17 := FALSE;
	
	  //-----------------------------------------------
	  // Message handling for mode manager: foot part
	  //-----------------------------------------------
	  IF NOT statFirstCycle THEN
	    IF diagnostics.buffer[statDiagnosticsBufferIndex].message = MSG_NO_MESSAGE THEN // ELSE: Unit mode wasn´t changed successfully
	      diagnostics.buffer[statDiagnosticsBufferIndex].message := MSG_MODE_CHANGED_SUCCESSFULLY;
	      statUnitModeChangeNotAllowed := FALSE;
	    END_IF;
	  END_IF;
	END_IF;// End: check if unit mode has to be changed
	// End: Unit mode manager
	
	//--------------------------------------------------------------------------------------------------
	// State manager
	//--------------------------------------------------------------------------------------------------
	IF NOT statFirstCycle THEN // As from second cycle
	  IF SC AND NOT statSCOld THEN // Detect a rising edge at state complete signal
	    tempSCInternal := TRUE;
	  ELSE
	    tempSCInternal := FALSE;
	  END_IF;
	  statSCOld := SC; // End: Detect a rising edge at state complete signal
	  
	  //---------------------------------------------------------------------
	  // Message handling for state manager: head part
	  //---------------------------------------------------------------------
	  IF tempSCInternal THEN // Check if rising edge of SC was detected
	    statDiagnosticsBufferIndex := statDiagnosticsBufferIndex + 1; // Next buffer index
	    IF statDiagnosticsBufferIndex > LPMLV2022_LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
	      statDiagnosticsBufferIndex := 0;
	    END_IF;
	    tempDiagnosticsBufferIndexSC := statDiagnosticsBufferIndex;
	    
	    // Write diagnostics
	    //tempRetVal := RD_LOC_T(diagnostics.buffer[tempDiagnosticsBufferIndexSC].timestamp);
		tempRetVal := GetLocalDateTime(value => tempSysTime);
		SplitDateAndTime(
			value := tempSysTime,
			year => tempYear,
			month => tempMonth,
			day => tempDay,
			hour => tempHour,
			minute => tempMinute,
			second => tempSecond,
			millisecond => tempMillisecond,
			microsecond => tempMicrosecond,
			nanosecond => tempNanosecond
		);
	    diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;

	    diagnostics.buffer[tempDiagnosticsBufferIndexSC].UnitModeCurrent := TO_SINT(UnitModeCurrent);
	    diagnostics.buffer[tempDiagnosticsBufferIndexSC].StateCurrent := TO_SINT(StateCurrent);
	    diagnostics.buffer[tempDiagnosticsBufferIndexSC].UnitMode := TO_SINT(statUnitMode);
	    diagnostics.buffer[tempDiagnosticsBufferIndexSC].CntrlCmd := TO_SINT(tempCntrlCmd);
	    diagnostics.buffer[tempDiagnosticsBufferIndexSC].SC := SC;
	    
	    // Check current state to use SC
	    IF statStateInternal = LPMLV2022_StateConstants#STATE_CLEARING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_STARTING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_STOPPING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_ABORTING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_HOLDING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_UNHOLDING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_SUSPENDING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_UNSUSPENDING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_RESETTING OR
	      statStateInternal = LPMLV2022_StateConstants#STATE_COMPLETING
	    THEN
	      diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_NO_MESSAGE;
	    ELSE
	      diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_SC_NOT_ALLOWED;
	    END_IF; // End: Check current state to use SC
	  END_IF;
	  
	  // Check if defined control command was sent correctly
	  IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN
	    statDiagnosticsBufferIndex := statDiagnosticsBufferIndex + 1; // Next buffer index
	    IF statDiagnosticsBufferIndex > LPMLV2022_LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
	      statDiagnosticsBufferIndex := 0;
	    END_IF;
	    tempDiagnosticsBufferIndexCmd := statDiagnosticsBufferIndex;
	
	    // Write diagnostics
	    //tempRetVal := RD_LOC_T(diagnostics.buffer[tempDiagnosticsBufferIndexCmd].timestamp);
		tempRetVal := GetLocalDateTime(value => tempSysTime);
		SplitDateAndTime(
			value := tempSysTime,
			year => tempYear,
			month => tempMonth,
			day => tempDay,
			hour => tempHour,
			minute => tempMinute,
			second => tempSecond,
			millisecond => tempMillisecond,
			microsecond => tempMicrosecond,
			nanosecond => tempNanosecond
		);
	    diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
		diagnostics.buffer[statDiagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;
		
	    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].UnitModeCurrent := TO_SINT(UnitModeCurrent);
	    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].StateCurrent := TO_SINT(StateCurrent);
	    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].UnitMode := TO_SINT(statUnitMode);
	    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].CntrlCmd := TO_SINT(tempCntrlCmd);
	    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].SC := SC;
	
	    IF (tempCntrlCmd >= LPMLV2022_CommandConstants#CMD_RESET) AND (tempCntrlCmd <= LPMLV2022_CommandConstants#CMD_COMPLETE)
	    THEN // A defined control command was sent (RESET, START, STOP, HOLD, UNHOLD, SUSPEND, UNSUSPEND, ABORT, CLEAR, COMPLETE)
	      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_NO_MESSAGE;
	
	      IF
	        // Throw message if any other CntrlCmd than Abort, Stop or Hold is triggered in the following acting states
	        ((statStateInternal = LPMLV2022_StateConstants#STATE_STARTING OR
	        statStateInternal = LPMLV2022_StateConstants#STATE_UNHOLDING OR
	        statStateInternal = LPMLV2022_StateConstants#STATE_SUSPENDING OR
	        statStateInternal = LPMLV2022_StateConstants#STATE_UNSUSPENDING OR
	        statStateInternal = LPMLV2022_StateConstants#STATE_COMPLETING) AND
	        NOT (tempCntrlCmd = LPMLV2022_CommandConstants#CMD_ABORT) AND NOT (tempCntrlCmd =LPMLV2022_CommandConstants#CMD_STOP) AND NOT (tempCntrlCmd = LPMLV2022_CommandConstants#CMD_HOLD)) OR
	        // Throw message if any other CntrlCmd than Abort or Stop is triggered in the following acting states
	        ((statStateInternal = LPMLV2022_StateConstants#STATE_HOLDING OR
	        statStateInternal = LPMLV2022_StateConstants#STATE_RESETTING) AND
	        NOT (tempCntrlCmd = LPMLV2022_CommandConstants#CMD_ABORT) AND NOT (tempCntrlCmd =LPMLV2022_CommandConstants#CMD_STOP)) OR
	        // Throw message if any other CntrlCmd than Abort is triggered in the following acting states
	        ((statStateInternal = LPMLV2022_StateConstants#STATE_STOPPING OR statStateInternal =LPMLV2022_StateConstants#STATE_CLEARING) AND NOT (tempCntrlCmd = LPMLV2022_CommandConstants#CMD_ABORT)) OR
	        // Throw message if any CntrlCmd is triggered in Aborting, because no CntrlCmd is allowed in Aborting
	        (statStateInternal = LPMLV2022_StateConstants#STATE_ABORTING)
	      THEN // Write message if CntrlCmd is not allowed
	        diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	        statCntrlCmdNotAllowed := TRUE;
	      END_IF;
	
	    ELSE // Not defined control command was sent
	      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_DEFINED;
	      statCntrlCmdNotAllowed := TRUE;
	    END_IF;
	  END_IF; // End: message handling for state manager: head part 
	
	  //---------------------------------------------------------------------
	  // State machine
	  //---------------------------------------------------------------------
	  IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd = LPMLV2022_CommandConstants#CMD_ABORT AND // Check if abort command was sent correctly
	    statStateInternal <> LPMLV2022_StateConstants#STATE_ABORTED AND
	    statStateInternal <> LPMLV2022_StateConstants#STATE_ABORTING
	  THEN
	    // Abort command was sent correctly
	    statStateRequested := LPMLV2022_StateConstants#STATE_ABORTED;
	    // Select next state
	    IF statStatesInCurrentMode.aborting THEN
	      StateChangeInProcess := TRUE;
	      statStateInternal := LPMLV2022_StateConstants#STATE_ABORTING;
	    ELSE
	      StateChangeInProcess := FALSE;
	      statStateInternal := LPMLV2022_StateConstants#STATE_ABORTED;
	    END_IF;
	    
	  ELSIF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd = LPMLV2022_CommandConstants#CMD_STOP AND // Check if correct stop command was sent
	    statStateInternal <> LPMLV2022_StateConstants#STATE_ABORTED AND
	    statStateInternal <> LPMLV2022_StateConstants#STATE_ABORTING AND
	    statStateInternal <> LPMLV2022_StateConstants#STATE_CLEARING AND
	    statStateInternal <> LPMLV2022_StateConstants#STATE_STOPPING AND
	    statStateInternal <> LPMLV2022_StateConstants#STATE_STOPPED
	  THEN
	    // Stop command was sent correctly
	    statStateRequested := LPMLV2022_StateConstants#STATE_STOPPED;
	    // Select next state
	    IF statStatesInCurrentMode.stopping THEN
	      StateChangeInProcess := TRUE;
	      statStateInternal := LPMLV2022_StateConstants#STATE_STOPPING;
	    ELSE
	      StateChangeInProcess := FALSE;
	      statStateInternal := LPMLV2022_StateConstants#STATE_STOPPED;
	    END_IF;
	  ELSE // Internal state machine
	    CASE statStateInternal OF
	      LPMLV2022_StateConstants#STATE_EXECUTE:
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN // Check if state change is requested
	          CASE tempCntrlCmd OF // Check control command
	            LPMLV2022_CommandConstants#CMD_COMPLETE:
	              IF statConsiderCompleteCmdIn.execute THEN
	                // Check if valid state for command is in use by current unit mode
	                IF statStatesInCurrentMode.completing THEN
	                  StateChangeInProcess := TRUE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_COMPLETED;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_COMPLETING;
	                ELSIF statStatesInCurrentMode.completed THEN
	                  StateChangeInProcess := FALSE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_COMPLETED;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_COMPLETED;
	                ELSE
	                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                  statCntrlCmdNotAllowed := TRUE;
	                END_IF;
	              ELSE // statConsiderCompleteCmdIn.execute = FALSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	              
	            LPMLV2022_CommandConstants#CMD_HOLD:
	              IF statConsiderHoldCmdIn.execute THEN
	                // Check if valid state for command is in use by current unit mode
	                IF statStatesInCurrentMode.holding THEN
	                  StateChangeInProcess := TRUE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HOLDING;
	                ELSIF statStatesInCurrentMode.held THEN
	                  StateChangeInProcess := FALSE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	                ELSE
	                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                  statCntrlCmdNotAllowed := TRUE;
	                END_IF;
	              ELSE // statConsiderHoldCmdIn.execute = FALSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            LPMLV2022_CommandConstants#CMD_SUSPEND:
	              // Check if valid state for command is in use by current unit mode
	              IF statStatesInCurrentMode.suspending THEN
	                StateChangeInProcess := TRUE;
	                statStateRequested := LPMLV2022_StateConstants#STATE_SUSPENDED;
	                statStateInternal := LPMLV2022_StateConstants#STATE_SUSPENDING;
	              ELSIF statStatesInCurrentMode.suspended THEN
	                StateChangeInProcess := FALSE;
	                statStateRequested := LPMLV2022_StateConstants#STATE_SUSPENDED;
	                statStateInternal := LPMLV2022_StateConstants#STATE_SUSPENDED;
	              ELSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	            ELSE
	              IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	          END_CASE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_COMPLETING:
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd = LPMLV2022_CommandConstants#CMD_HOLD THEN // Check if state change is requested
	          IF statConsiderHoldCmdIn.completing THEN
	            // Check if valid state for command is in use by current unit mode
	            IF statStatesInCurrentMode.holding THEN
	              StateChangeInProcess := TRUE;
	              statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	              statStateInternal := LPMLV2022_StateConstants#STATE_HOLDING;
	            ELSIF statStatesInCurrentMode.held THEN
	              StateChangeInProcess := FALSE;
	              statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	              statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	            ELSE
	              diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	              statCntrlCmdNotAllowed := TRUE;
	            END_IF;
	            
	          ELSE // statConsiderHoldCmdIn.completing = FALSE
	            diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	            statCntrlCmdNotAllowed := TRUE;
	          END_IF;
	        END_IF;
	
	        IF (statStateRequested <> LPMLV2022_StateConstants#STATE_HELD) THEN // Check SC only, if no successful Hold command has been triggered
	          // Check if state is completed
	          IF tempSCInternal AND statStatesInCurrentMode.completed THEN
	            StateChangeInProcess := FALSE;
	            statStateInternal := LPMLV2022_StateConstants#STATE_COMPLETED;
	          ELSIF tempSCInternal AND NOT statStatesInCurrentMode.completed THEN
	            diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_SC_NOT_ALLOWED;
	          END_IF;
	
	        ELSE // (statStateRequested = LPMLV2022_StateConstants#STATE_HELD), i.e. successful Hold command has been triggered
	          IF tempSCInternal THEN
	            diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_SC_OVERRIDDEN_BY_CMD_HOLD;
	          END_IF;
	        END_IF;
	
	      LPMLV2022_StateConstants#STATE_COMPLETED:
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN // Check if state change is requested
	          CASE tempCntrlCmd OF // Check control command
	            LPMLV2022_CommandConstants#CMD_RESET:
	              // Check if valid state for command is in use by current unit mode
	              IF statStatesInCurrentMode.resetting THEN
	                StateChangeInProcess := TRUE;
	                statStateRequested := LPMLV2022_StateConstants#STATE_IDLE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_RESETTING;
	              ELSIF statStatesInCurrentMode.idle THEN
	                StateChangeInProcess := FALSE;
	                statStateRequested := LPMLV2022_StateConstants#STATE_IDLE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_IDLE;
	              ELSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            LPMLV2022_CommandConstants#CMD_HOLD:
	              IF statConsiderHoldCmdIn.completed THEN
	                // Check if valid state for command is in use by current unit mode
	                IF statStatesInCurrentMode.holding THEN
	                  StateChangeInProcess := TRUE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HOLDING;
	                ELSIF statStatesInCurrentMode.held THEN
	                  StateChangeInProcess := FALSE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	                ELSE
	                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                  statCntrlCmdNotAllowed := TRUE;
	                END_IF;
	              ELSE // statConsiderHoldCmdIn.completed = FALSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            ELSE
	              IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	          END_CASE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_RESETTING:
	        // Check if state is completed
	        // No message handling needed -> Idle is minimum required state
	        IF tempSCInternal THEN // ELSE: Wait for state complete signal
	          StateChangeInProcess := FALSE;
	          statStateInternal := LPMLV2022_StateConstants#STATE_IDLE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_IDLE:
	        //  Check if valid command is sent
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN // Check if state change is requested
	          CASE tempCntrlCmd OF // Check control command
	              LPMLV2022_CommandConstants#CMD_START:
	              //  No message handling needed -> Execute is minimum required state
	              statStateRequested := LPMLV2022_StateConstants#STATE_EXECUTE;
	              // Check if valid state for command is in use by current mode
	              IF statStatesInCurrentMode.starting THEN
	                StateChangeInProcess := TRUE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_STARTING;
	              ELSE
	                StateChangeInProcess := FALSE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_EXECUTE;
	              END_IF;
	
	            LPMLV2022_CommandConstants#CMD_HOLD:
	              IF statConsiderHoldCmdIn.idle THEN
	                // Check if valid state for command is in use by current unit mode
	                IF statStatesInCurrentMode.holding THEN
	                  StateChangeInProcess := TRUE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HOLDING;
	                ELSIF statStatesInCurrentMode.held THEN
	                  StateChangeInProcess := FALSE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	                ELSE
	                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                  statCntrlCmdNotAllowed := TRUE;
	                END_IF;
	              ELSE // statConsiderHoldCmdIn.idle = FALSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            ELSE
	              IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	          END_CASE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_STARTING,
	      LPMLV2022_StateConstants#STATE_UNHOLDING,
	      LPMLV2022_StateConstants#STATE_UNSUSPENDING:
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd = LPMLV2022_CommandConstants#CMD_HOLD THEN // Check if state change is requested
	          IF (statConsiderHoldCmdIn.starting AND statStateInternal = LPMLV2022_StateConstants#STATE_STARTING) OR
	            (statConsiderHoldCmdIn.unholding AND statStateInternal = LPMLV2022_StateConstants#STATE_UNHOLDING) OR
	            (statConsiderHoldCmdIn.unsuspending AND statStateInternal = LPMLV2022_StateConstants#STATE_UNSUSPENDING)
	          THEN
	            // Check if valid state for command is in use by current unit mode
	            IF statStatesInCurrentMode.holding THEN
	              StateChangeInProcess := TRUE;
	              statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	              statStateInternal := LPMLV2022_StateConstants#STATE_HOLDING;
	            ELSIF statStatesInCurrentMode.held THEN
	              StateChangeInProcess := FALSE;
	              statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	              statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	            ELSE
	              diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	              statCntrlCmdNotAllowed := TRUE;
	            END_IF;
	
	          ELSE // statConsiderHoldCmdIn.xxx = FALSE
	            diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	            statCntrlCmdNotAllowed := TRUE;
	          END_IF;
	        END_IF;
	        
	        IF (statStateRequested <> LPMLV2022_StateConstants#STATE_HELD) THEN // Check SC only, if no successful Hold command has been triggered
	          // Check if state is completed
	          IF tempSCInternal THEN // ELSE: Wait for state complete signal
	            StateChangeInProcess := FALSE;
	            statStateInternal := LPMLV2022_StateConstants#STATE_EXECUTE;
	          END_IF;
	
	        ELSE // (statStateRequested = LPMLV2022_StateConstants#STATE_HELD), i.e. successful Hold command has been triggered
	          IF tempSCInternal THEN
	            diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_SC_OVERRIDDEN_BY_CMD_HOLD;
	          END_IF;
	        END_IF;
	
	      LPMLV2022_StateConstants#STATE_HOLDING:
	        // Check if state is completed
	        IF tempSCInternal AND statStatesInCurrentMode.held THEN // ELSE: Wait for state complete signal
	          StateChangeInProcess := FALSE;
	          statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	        ELSIF tempSCInternal AND NOT statStatesInCurrentMode.held THEN
	          diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_SC_NOT_ALLOWED;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_HELD:
	        //  Check if valid command is sent
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN // Check if state change is requested
	          CASE tempCntrlCmd OF // Check control command
	            LPMLV2022_CommandConstants#CMD_UNHOLD:
	              statStateRequested := LPMLV2022_StateConstants#STATE_EXECUTE;
	              // Check if valid state for command is in use by current mode
	              IF statStatesInCurrentMode.unholding THEN
	                StateChangeInProcess := TRUE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_UNHOLDING;
	              ELSE
	                StateChangeInProcess := FALSE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_EXECUTE;
	              END_IF;
	
	            LPMLV2022_CommandConstants#CMD_COMPLETE:
	              IF statConsiderCompleteCmdIn.held THEN
	                // Check if valid state for command is in use by current unit mode
	                IF statStatesInCurrentMode.completing THEN
	                  StateChangeInProcess := TRUE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_COMPLETED;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_COMPLETING;
	                ELSIF statStatesInCurrentMode.completed THEN
	                  StateChangeInProcess := FALSE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_COMPLETED;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_COMPLETED;
	                ELSE
	                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                  statCntrlCmdNotAllowed := TRUE;
	                END_IF;
	              ELSE // statConsiderCompleteCmdIn.held = FALSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            ELSE
	              IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	          END_CASE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_SUSPENDING:
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd = LPMLV2022_CommandConstants#CMD_HOLD THEN // Check if state change is requested
	          IF statConsiderHoldCmdIn.suspending THEN
	            // Check if valid state for command is in use by current unit mode
	            IF statStatesInCurrentMode.holding THEN
	              StateChangeInProcess := TRUE;
	              statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	              statStateInternal := LPMLV2022_StateConstants#STATE_HOLDING;
	            ELSIF statStatesInCurrentMode.held THEN
	              StateChangeInProcess := FALSE;
	              statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	              statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	            ELSE
	              diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	              statCntrlCmdNotAllowed := TRUE;
	            END_IF;
	
	          ELSE // statConsiderHoldCmdIn.suspending = FALSE
	            diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	            statCntrlCmdNotAllowed := TRUE;
	          END_IF;
	        END_IF;
	        
	        IF (statStateRequested <> LPMLV2022_StateConstants#STATE_HELD) THEN // Check SC only, if no successful Hold command has been triggered
	          // Check if state is completed
	          IF tempSCInternal AND statStatesInCurrentMode.suspended THEN // ELSE: Wait for state complete signal
	            StateChangeInProcess := FALSE;
	            statStateInternal := LPMLV2022_StateConstants#STATE_SUSPENDED;
	          ELSIF tempSCInternal AND NOT statStatesInCurrentMode.suspended THEN
	            diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_SC_NOT_ALLOWED;
	          END_IF;
	
	        ELSE // (statStateRequested = LPMLV2022_StateConstants#STATE_HELD), i.e. successful Hold command has been triggered
	          IF tempSCInternal THEN
	            diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_SC_OVERRIDDEN_BY_CMD_HOLD;
	          END_IF;
	        END_IF;
	
	      LPMLV2022_StateConstants#STATE_SUSPENDED:
	        //  Check if valid command is sent
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN // Check if state change is requested
	          CASE tempCntrlCmd OF // Check control command
	              LPMLV2022_CommandConstants#CMD_UNSUSPEND:
	              statStateRequested := LPMLV2022_StateConstants#STATE_EXECUTE;
	              // Check if valid state for command is in use by current mode
	              IF statStatesInCurrentMode.unsuspending THEN
	                StateChangeInProcess := TRUE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_UNSUSPENDING;
	              ELSE
	                StateChangeInProcess := FALSE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_EXECUTE;
	              END_IF;
	
	            LPMLV2022_CommandConstants#CMD_COMPLETE:
	              IF statConsiderCompleteCmdIn.suspended THEN
	                // Check if valid state for command is in use by current unit mode
	                IF statStatesInCurrentMode.completing THEN
	                  StateChangeInProcess := TRUE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_COMPLETED;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_COMPLETING;
	                ELSIF statStatesInCurrentMode.completed THEN
	                  StateChangeInProcess := FALSE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_COMPLETED;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_COMPLETED;
	                ELSE
	                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                  statCntrlCmdNotAllowed := TRUE;
	                END_IF;
	              ELSE // statConsiderCompleteCmdIn.suspended = FALSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            LPMLV2022_CommandConstants#CMD_HOLD:
	              IF statConsiderHoldCmdIn.suspended THEN
	                // Check if valid state for command is in use by current unit mode
	                IF statStatesInCurrentMode.holding THEN
	                  StateChangeInProcess := TRUE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HOLDING;
	                ELSIF statStatesInCurrentMode.held THEN
	                  StateChangeInProcess := FALSE;
	                  statStateRequested := LPMLV2022_StateConstants#STATE_HELD;
	                  statStateInternal := LPMLV2022_StateConstants#STATE_HELD;
	                ELSE
	                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                  statCntrlCmdNotAllowed := TRUE;
	                END_IF;
	              ELSE // statConsiderHoldCmdIn.suspended = FALSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            ELSE
	              IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	          END_CASE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_ABORTING:
	        // Check if state is completed
	        // No message handling needed -> Aborted is minimum required state
	        IF tempSCInternal THEN // ELSE: Wait for state complete signal
	          StateChangeInProcess := FALSE;
	          statStateInternal := LPMLV2022_StateConstants#STATE_ABORTED;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_ABORTED:
	        //  Check if valid command is sent
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN // Check if state change is requested
	          CASE tempCntrlCmd OF // Check control command
	            LPMLV2022_CommandConstants#CMD_CLEAR:
	              statStateRequested := LPMLV2022_StateConstants#STATE_STOPPED;
	              // Check if valid state for command is in use by current mode
	              IF statStatesInCurrentMode.clearing THEN
	                StateChangeInProcess := TRUE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_CLEARING;
	              ELSE
	                StateChangeInProcess := FALSE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_STOPPED;
	              END_IF;
	            ELSE
	              IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	          END_CASE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_CLEARING,
	      LPMLV2022_StateConstants#STATE_STOPPING:
	        // Check if state is completed
	        // No message handling needed -> Stopped is minimum required state
	        IF tempSCInternal THEN // ELSE: Wait for state complete signal
	          StateChangeInProcess := FALSE;
	          statStateInternal := LPMLV2022_StateConstants#STATE_STOPPED;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_STOPPED:
	        IF statCmdChangeRequest AND tempCntrlCmd <> statCntrlCmdOld AND tempCntrlCmd <> LPMLV2022_CommandConstants#CMD_UNDEFINED THEN // Check if state change is requested
	          // Check if valid command is sent
	          CASE tempCntrlCmd OF
	            LPMLV2022_CommandConstants#CMD_RESET:
	              // Check if valid state for command is in use by current unit mode
	              IF statStatesInCurrentMode.resetting THEN
	                StateChangeInProcess := TRUE;
	                statStateRequested := LPMLV2022_StateConstants#STATE_IDLE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_RESETTING;
	              ELSIF statStatesInCurrentMode.idle THEN
	                StateChangeInProcess := FALSE;
	                statStateRequested := LPMLV2022_StateConstants#STATE_IDLE;
	                statStateInternal := LPMLV2022_StateConstants#STATE_IDLE;
	              ELSE
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	
	            ELSE
	              IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
	                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_CMD_NOT_ALLOWED;
	                statCntrlCmdNotAllowed := TRUE;
	              END_IF;
	          END_CASE;
	        END_IF;
	        
	      LPMLV2022_StateConstants#STATE_UNDEFINED:
	        StateChangeInProcess := FALSE;
	        statStateRequested := LPMLV2022_StateConstants#STATE_STOPPED;
	        statStateInternal := LPMLV2022_StateConstants#STATE_STOPPED;
	
	      ELSE
	        ; // Undefined state
	    END_CASE;
	  END_IF; // End: state machine
	
	  //-------------------------------------------------
	  // Message handling for state manager: foot part
	  //-------------------------------------------------
	  IF statStateInternal <> statStateCurrentOld THEN // ELSE: States were not changed
	    IF tempDiagnosticsBufferIndexCmd >= 0 AND tempDiagnosticsBufferIndexCmd <= LPMLV2022_LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
	      IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = MSG_NO_MESSAGE THEN
	        diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := MSG_STATE_CHANGED_SUCCESSFULLY;
	        statCntrlCmdNotAllowed := FALSE;
	      END_IF;
	    END_IF;
	    IF tempDiagnosticsBufferIndexSC >= 0 AND tempDiagnosticsBufferIndexSC <= LPMLV2022_LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
	      IF diagnostics.buffer[tempDiagnosticsBufferIndexSC].message = MSG_NO_MESSAGE THEN
	        diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := MSG_STATE_CHANGED_SUCCESSFULLY;
	      END_IF;
	    END_IF;
	  END_IF; // End: message handling for state manager: foot part
	END_IF; // End: As from second cycle
	// End: State manager
	
	//--------------------------------------------------------------------------------------------------
	// Write outputs
	//--------------------------------------------------------------------------------------------------
	StateCurrent := statStateInternal; // Set output
	
	diagnostics.bufferIndex := statDiagnosticsBufferIndex; // Local variable is used during block execution -> Copy back/Set output
	IF statFirstCycle THEN
	  statFirstCycle := FALSE;
	END_IF;
	
	// Save values for edge detection
	IF statUnitModeChangeRequest THEN
	  statUnitModeOld := statUnitMode;
	END_IF;
	IF statCmdChangeRequest THEN
	  statCntrlCmdOld := tempCntrlCmd;
	END_IF;
	IF statStateInternal <> statStateCurrentOld THEN
	  statStateCurrentOld := statStateInternal;
	END_IF;
	
	StateRequested := statStateRequested;
	
	IF (statUnitModeChangeRequest = FALSE) OR (statUnitMode = LPMLV2022_ModeConstants#MODE_INVALID) THEN
	  statUnitModeChangeNotAllowed := FALSE;
	END_IF;
	IF (statCmdChangeRequest = FALSE) OR (tempCntrlCmd = LPMLV2022_CommandConstants#CMD_UNDEFINED) THEN
	  statCntrlCmdNotAllowed := FALSE;
	END_IF;
	
	unitModeChangeNotAllowed := statUnitModeChangeNotAllowed;
	cntrlCmdNotAllowed       := statCntrlCmdNotAllowed;
END_FUNCTION_BLOCK
END_NAMESPACE
