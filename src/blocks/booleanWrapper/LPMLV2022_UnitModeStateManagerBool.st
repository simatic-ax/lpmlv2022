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
FUNCTION_BLOCK LPMLV2022_UnitModeStateManagerBool
{S7.extern = ReadWrite}
   VAR_INPUT
      ProductionModeRequest : Bool;   // Rising edge: Request change to unit mode Production
      MaintenanceModeRequest : Bool;   // Rising edge: Request change to unit mode Maintenance
      ManualModeRequest : Bool;   // Rising edge: Request change to unit mode Manual
      UserMode01Request : Bool;   // Rising edge: Request change to user-defined unit mode 01
      UserMode02Request : Bool;   // Rising edge: Request change to user-defined unit mode 02
      UserMode03Request : Bool;   // Rising edge: Request change to user-defined unit mode 03
      UserMode04Request : Bool;   // Rising edge: Request change to user-defined unit mode 04
      UserMode05Request : Bool;   // Rising edge: Request change to user-defined unit mode 05
      ResetCmdRequest : Bool;   // Rising edge: Request control command Reset
      StartCmdRequest : Bool;   // Rising edge: Request control command Start
      StopCmdRequest : Bool;   // Rising edge: Request control command Stop
      HoldCmdRequest : Bool;   // Rising edge: Request control command Hold
      UnholdCmdRequest : Bool;   // Rising edge: Request control command Unhold
      SuspendCmdRequest : Bool;   // Rising edge: Request control command Suspend
      UnsuspendCmdRequest : Bool;   // Rising edge: Request control command Unsuspend
      AbortCmdRequest : Bool;   // Rising edge: Request control command Abort
      ClearCmdRequest : Bool;   // Rising edge: Request control command Clear
      CompleteCmdRequest : Bool;   // Rising edge: Request control command Complete
      SC : Bool;   // State change from FALSE to TRUE (rising edge) triggers state complete signal
      config : LPMLV2022_typeConfiguration := (
		DisabledStatesCfg := [32(DWORD#16#0)],
		ModeTransitionCfg := [DWORD#0, 31(DWORD#16#00000214)]);   // FB config (is taken into account in first call after STOP/RUN)
   END_VAR


{S7.extern = ReadOnly}
   VAR_OUTPUT
      UnitModeCurrent : DInt := LPMLV2022_ModeConstants#MODE_INVALID;   // Current unit mode
      StateCurrent : DInt := LPMLV2022_StateConstants#STATE_UNDEFINED;   // Current state
      ProductionModeActive : Bool;   // TRUE: Unit mode Production is currently active
      MaintenanceModeActive : Bool;   // TRUE: Unit mode Maintenance is currently active
      ManualModeActive : Bool;   // TRUE: Unit mode Manual is currently active
      UserMode01Active : Bool;   // TRUE: User-defined unit mode 01 is currently active
      UserMode02Active : Bool;   // TRUE: User-defined unit mode 02 is currently active
      UserMode03Active : Bool;   // TRUE: User-defined unit mode 03 is currently active
      UserMode04Active : Bool;   // TRUE: User-defined unit mode 04 is currently active
      UserMode05Active : Bool;   // TRUE: User-defined unit mode 05 is currently active
      ClearingStateActive : Bool;   // TRUE: State Clearing is currently active
      StoppedStateActive : Bool;   // TRUE: State Stopped is currently active
      StartingStateActive : Bool;   // TRUE: State Starting is currently active
      IdleStateActive : Bool;   // TRUE: State Idle is currently active
      SuspendedStateActive : Bool;   // TRUE: State Suspended is currently active
      ExecuteStateActive : Bool;   // TRUE: State Execute is currently active
      StoppingStateActive : Bool;   // TRUE: State Stopping is currently active
      AbortingStateActive : Bool;   // TRUE: State Aborting is currently active
      AbortedStateActive : Bool;   // TRUE: State Aborted is currently active
      HoldingStateActive : Bool;   // TRUE: State Holding is currently active
      HeldStateActive : Bool;   // TRUE: State Held is currently active
      UnholdingStateActive : Bool;   // TRUE: State Unholding is currently active
      SuspendingStateActive : Bool;   // TRUE: State Suspending is currently active
      UnsuspendingStateActive : Bool;   // TRUE: State Unsuspending is currently active
      ResettingStateActive : Bool;   // TRUE: State Resetting is currently active
      CompletingStateActive : Bool;   // TRUE: State Completing is currently active
      CompletedStateActive : Bool;   // TRUE: State Completed is currently active
      unitModeChangeNotAllowed : Bool;   // TRUE: Requested unit mode change is not allowed (output is reset with the next successful unit mode change or if all corresponding request inputs are set to FALSE)
      cntrlCmdNotAllowed : Bool;   // TRUE: Control command is not allowed (output is reset with the next successful control command or if all corresponding request inputs are set to FALSE)
   END_VAR

   VAR
	{S7.extern = ReadOnly}
      instUnitModeStateManager : LPMLV2022_UnitModeStateManager;   // Instance of LPMLV2022_UnitModeStateManager
      statFirstCycle : Bool := TRUE;   // First cycle of run
      statUnitModeCurrentInternalOld : DInt := LPMLV2022_ModeConstants#MODE_INVALID;   // For edge detection
      statStateInternalOld : DInt := LPMLV2022_StateConstants#STATE_UNDEFINED;   // For edge detection
      statBooleanInterfaceModeOld : DWord;   // For edge detection
      statBooleanInterfaceCmdOld : Word;   // For edge detection
   END_VAR

   VAR_TEMP
      tempBooleanInterfaceMode : DWord;   // Status of boolean Mode inputs
      tempBooleanInterfaceCmd : Word;   // Status of boolean Cmd inputs except abort and stop
   END_VAR


	
	
	
	IF statFirstCycle THEN // Initialize values in first cycle
	  instUnitModeStateManager.config := config; // Copy config from input
	  statFirstCycle := FALSE;
	
	ELSE // As from second cycle
	  //--------------------------------------------------------------------------------------------------
	  // Evaluation of input parameters
	  //--------------------------------------------------------------------------------------------------
	  instUnitModeStateManager.UnitModeChangeRequest := TRUE; // Change request static TRUE
	
	  // Collect unit mode from boolean inputs
	  tempBooleanInterfaceMode.%X1  := ProductionModeRequest;
	  tempBooleanInterfaceMode.%X2  := MaintenanceModeRequest;
	  tempBooleanInterfaceMode.%X3  := ManualModeRequest;
	  tempBooleanInterfaceMode.%X4  := UserMode01Request;
	  tempBooleanInterfaceMode.%X5  := UserMode02Request;
	  tempBooleanInterfaceMode.%X6  := UserMode03Request;
	  tempBooleanInterfaceMode.%X7  := UserMode04Request;
	  tempBooleanInterfaceMode.%X8  := UserMode05Request;
	// tempBooleanInterfaceMode.%X9  := UserMode06Request;
	// tempBooleanInterfaceMode.%X10 := UserMode07Request;
	// tempBooleanInterfaceMode.%X11 := UserMode08Request;
	// tempBooleanInterfaceMode.%X12 := UserMode09Request;
	// tempBooleanInterfaceMode.%X13 := UserMode10Request;
	// tempBooleanInterfaceMode.%X14 := UserMode11Request;
	// tempBooleanInterfaceMode.%X15 := UserMode12Request;
	// tempBooleanInterfaceMode.%X16 := UserMode13Request;
	// tempBooleanInterfaceMode.%X17 := UserMode14Request;
	// tempBooleanInterfaceMode.%X18 := UserMode15Request;
	// tempBooleanInterfaceMode.%X19 := UserMode16Request;
	// tempBooleanInterfaceMode.%X20 := UserMode17Request;
	// tempBooleanInterfaceMode.%X21 := UserMode18Request;
	// tempBooleanInterfaceMode.%X22 := UserMode19Request;
	// tempBooleanInterfaceMode.%X23 := UserMode20Request;
	// tempBooleanInterfaceMode.%X24 := UserMode21Request;
	// tempBooleanInterfaceMode.%X25 := UserMode22Request;
	// tempBooleanInterfaceMode.%X26 := UserMode23Request;
	// tempBooleanInterfaceMode.%X27 := UserMode24Request;
	// tempBooleanInterfaceMode.%X28 := UserMode25Request;
	// tempBooleanInterfaceMode.%X29 := UserMode26Request;
	// tempBooleanInterfaceMode.%X30 := UserMode27Request;
	// tempBooleanInterfaceMode.%X31 := UserMode28Request;
	    
	  // Selection indicator: Rising edge at input, Priority (in case of multiple selection): Manual, Maintenance, User Mode 01..28, Production
	  IF tempBooleanInterfaceMode.%X3 AND NOT statBooleanInterfaceModeOld.%X3 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_MANUAL;
	  ELSIF tempBooleanInterfaceMode.%X2 AND NOT statBooleanInterfaceModeOld.%X2 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_MAINTENANCE;
	  ELSIF tempBooleanInterfaceMode.%X4 AND NOT statBooleanInterfaceModeOld.%X4 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_01;
	  ELSIF tempBooleanInterfaceMode.%X5 AND NOT statBooleanInterfaceModeOld.%X5 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_02;
	  ELSIF tempBooleanInterfaceMode.%X6 AND NOT statBooleanInterfaceModeOld.%X6 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_03;
	  ELSIF tempBooleanInterfaceMode.%X7 AND NOT statBooleanInterfaceModeOld.%X7 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_04;
	  ELSIF tempBooleanInterfaceMode.%X8 AND NOT statBooleanInterfaceModeOld.%X8 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_05;
	// ELSIF tempBooleanInterfaceMode.%X9 AND NOT statBooleanInterfaceModeOld.%X9 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_06;
	// ELSIF tempBooleanInterfaceMode.%X10 AND NOT statBooleanInterfaceModeOld.%X10 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_07;
	// ELSIF tempBooleanInterfaceMode.%X11 AND NOT statBooleanInterfaceModeOld.%X11 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_08;
	// ELSIF tempBooleanInterfaceMode.%X12 AND NOT statBooleanInterfaceModeOld.%X12 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_09;
	// ELSIF tempBooleanInterfaceMode.%X13 AND NOT statBooleanInterfaceModeOld.%X13 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_10;
	// ELSIF tempBooleanInterfaceMode.%X14 AND NOT statBooleanInterfaceModeOld.%X14 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_11;
	// ELSIF tempBooleanInterfaceMode.%X15 AND NOT statBooleanInterfaceModeOld.%X15 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_12;
	// ELSIF tempBooleanInterfaceMode.%X16 AND NOT statBooleanInterfaceModeOld.%X16 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_13;
	// ELSIF tempBooleanInterfaceMode.%X17 AND NOT statBooleanInterfaceModeOld.%X17 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_14;
	// ELSIF tempBooleanInterfaceMode.%X18 AND NOT statBooleanInterfaceModeOld.%X18 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_15;
	// ELSIF tempBooleanInterfaceMode.%X19 AND NOT statBooleanInterfaceModeOld.%X19 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_16;
	// ELSIF tempBooleanInterfaceMode.%X20 AND NOT statBooleanInterfaceModeOld.%X20 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_17;
	// ELSIF tempBooleanInterfaceMode.%X21 AND NOT statBooleanInterfaceModeOld.%X21 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_18;
	// ELSIF tempBooleanInterfaceMode.%X22 AND NOT statBooleanInterfaceModeOld.%X22 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_19;
	// ELSIF tempBooleanInterfaceMode.%X23 AND NOT statBooleanInterfaceModeOld.%X23 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_20;
	// ELSIF tempBooleanInterfaceMode.%X24 AND NOT statBooleanInterfaceModeOld.%X24 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_21;
	// ELSIF tempBooleanInterfaceMode.%X25 AND NOT statBooleanInterfaceModeOld.%X25 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_22;
	// ELSIF tempBooleanInterfaceMode.%X26 AND NOT statBooleanInterfaceModeOld.%X26 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_23;
	// ELSIF tempBooleanInterfaceMode.%X27 AND NOT statBooleanInterfaceModeOld.%X27 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_24;
	// ELSIF tempBooleanInterfaceMode.%X28 AND NOT statBooleanInterfaceModeOld.%X28 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_25;
	// ELSIF tempBooleanInterfaceMode.%X29 AND NOT statBooleanInterfaceModeOld.%X29 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_26;
	// ELSIF tempBooleanInterfaceMode.%X30 AND NOT statBooleanInterfaceModeOld.%X30 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_27;
	// ELSIF tempBooleanInterfaceMode.%X31 AND NOT statBooleanInterfaceModeOld.%X31 THEN
	//   instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_USER_28;
	  ELSIF tempBooleanInterfaceMode.%X1 AND NOT statBooleanInterfaceModeOld.%X1 THEN
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_PRODUCTION;
	  ELSIF tempBooleanInterfaceMode = DWORD#16#0000_0000 THEN // all corresponding boolean request inputs are FALSE
	    instUnitModeStateManager.UnitMode := LPMLV2022_ModeConstants#MODE_INVALID;
	  END_IF;
	  
	  statBooleanInterfaceModeOld := tempBooleanInterfaceMode; // Save values for edge detection
	  
	  // State complete signal
	  instUnitModeStateManager.SC := SC;
	  
	  // Evaluate CntrlCmd in boolean interface; priority descending: abort, stop, other commands
	  instUnitModeStateManager.CmdChangeRequest := TRUE; // Change request static TRUE
	  
	  tempBooleanInterfaceCmd.%X1 := ResetCmdRequest;
	  tempBooleanInterfaceCmd.%X2 := StartCmdRequest;
	  tempBooleanInterfaceCmd.%X3 := StopCmdRequest;
	  tempBooleanInterfaceCmd.%X4 := HoldCmdRequest;
	  tempBooleanInterfaceCmd.%X5 := UnholdCmdRequest;
	  tempBooleanInterfaceCmd.%X6 := SuspendCmdRequest;
	  tempBooleanInterfaceCmd.%X7 := UnsuspendCmdRequest;
	  tempBooleanInterfaceCmd.%X8 := AbortCmdRequest;
	  tempBooleanInterfaceCmd.%X9 := ClearCmdRequest;
	  tempBooleanInterfaceCmd.%X10 := CompleteCmdRequest;
	  
	  // Selection indicator: Rising edge at input, Priority (in case of multiple selection): abort, stop, complete, reset, start, hold, unhold, suspend, unsuspend, clear
	  IF tempBooleanInterfaceCmd.%X8 AND NOT statBooleanInterfaceCmdOld.%X8 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_ABORT;
	  ELSIF tempBooleanInterfaceCmd.%X3 AND NOT statBooleanInterfaceCmdOld.%X3 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_STOP;
	  ELSIF tempBooleanInterfaceCmd.%X10 AND NOT statBooleanInterfaceCmdOld.%X10 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_COMPLETE;
	  ELSIF tempBooleanInterfaceCmd.%X1 AND NOT statBooleanInterfaceCmdOld.%X1 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_RESET;
	  ELSIF tempBooleanInterfaceCmd.%X2 AND NOT statBooleanInterfaceCmdOld.%X2 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_START;
	  ELSIF tempBooleanInterfaceCmd.%X4 AND NOT statBooleanInterfaceCmdOld.%X4 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_HOLD;
	  ELSIF tempBooleanInterfaceCmd.%X5 AND NOT statBooleanInterfaceCmdOld.%X5 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_UNHOLD;
	  ELSIF tempBooleanInterfaceCmd.%X6 AND NOT statBooleanInterfaceCmdOld.%X6 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_SUSPEND;
	  ELSIF tempBooleanInterfaceCmd.%X7 AND NOT statBooleanInterfaceCmdOld.%X7 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_UNSUSPEND;
	  ELSIF tempBooleanInterfaceCmd.%X9 AND NOT statBooleanInterfaceCmdOld.%X9 THEN
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_CLEAR;
	  ELSIF tempBooleanInterfaceCmd = DWORD#16#0000_0000 THEN // all corresponding boolean request inputs are FALSE
	    instUnitModeStateManager.CntrlCmd := LPMLV2022_CommandConstants#CMD_UNDEFINED;
	  END_IF;
	  
	  statBooleanInterfaceCmdOld := tempBooleanInterfaceCmd; // Save values for edge detection
	END_IF;
	
	//--------------------------------------------------------------------------------------------------
	// Call unit mode state manager
	//--------------------------------------------------------------------------------------------------
	instUnitModeStateManager();
	
	//--------------------------------------------------------------------------------------------------
	// Write outputs including boolean interface outputs 
	//--------------------------------------------------------------------------------------------------
	UnitModeCurrent := instUnitModeStateManager.UnitModeCurrent;
	StateCurrent    := instUnitModeStateManager.StateCurrent;
	
	IF instUnitModeStateManager.UnitModeCurrent <> statUnitModeCurrentInternalOld THEN // Check if new unit mode is selected
	  ProductionModeActive := FALSE;
	  MaintenanceModeActive := FALSE;
	  ManualModeActive := FALSE;
	  UserMode01Active := FALSE;
	  UserMode02Active := FALSE;
	  UserMode03Active := FALSE;
	  UserMode04Active := FALSE;
	  UserMode05Active := FALSE;
	  // UserMode06Active := FALSE;
	  // UserMode07Active := FALSE;
	  // UserMode08Active := FALSE;
	  // UserMode09Active := FALSE;
	  // UserMode10Active := FALSE;
	  // UserMode11Active := FALSE;
	  // UserMode12Active := FALSE;
	  // UserMode13Active := FALSE;
	  // UserMode14Active := FALSE;
	  // UserMode15Active := FALSE;
	  // UserMode16Active := FALSE;
	  // UserMode17Active := FALSE;
	  // UserMode18Active := FALSE;
	  // UserMode19Active := FALSE;
	  // UserMode20Active := FALSE;
	  // UserMode21Active := FALSE;
	  // UserMode22Active := FALSE;
	  // UserMode23Active := FALSE;
	  // UserMode24Active := FALSE;
	  // UserMode25Active := FALSE;
	  // UserMode26Active := FALSE;
	  // UserMode27Active := FALSE;
	  // UserMode28Active := FALSE;
	  
	  CASE instUnitModeStateManager.UnitModeCurrent OF // Set new bit for current unit mode
	    LPMLV2022_ModeConstants#MODE_PRODUCTION:
	      ProductionModeActive := TRUE;
	    LPMLV2022_ModeConstants#MODE_MAINTENANCE:
	      MaintenanceModeActive := TRUE;
	    LPMLV2022_ModeConstants#MODE_MANUAL:
	      ManualModeActive := TRUE;
	    LPMLV2022_ModeConstants#MODE_USER_01:
	      UserMode01Active := TRUE;
	    LPMLV2022_ModeConstants#MODE_USER_02:
	      UserMode02Active := TRUE;
	    LPMLV2022_ModeConstants#MODE_USER_03:
	      UserMode03Active := TRUE;
	    LPMLV2022_ModeConstants#MODE_USER_04:
	      UserMode04Active := TRUE;
	    LPMLV2022_ModeConstants#MODE_USER_05:
	      UserMode05Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_06:
	    //   UserMode06Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_07:
	    //   UserMode07Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_08:
	    //   UserMode08Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_09:
	    //   UserMode09Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_10:
	    //   UserMode10Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_11:
	    //   UserMode11Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_12:
	    //   UserMode12Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_13:
	    //   UserMode13Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_14:
	    //   UserMode14Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_15:
	    //   UserMode15Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_16:
	    //   UserMode16Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_17:
	    //   UserMode17Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_18:
	    //   UserMode18Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_19:
	    //   UserMode19Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_20:
	    //   UserMode20Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_21:
	    //   UserMode21Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_22:
	    //   UserMode22Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_23:
	    //   UserMode23Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_24:
	    //   UserMode24Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_25:
	    //   UserMode25Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_26:
	    //   UserMode26Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_27:
	    //   UserMode27Active := TRUE;
	    // LPMLV2022_ModeConstants#MODE_USER_28:
	    //   UserMode28Active := TRUE;
	    ELSE
	      ; // No bit is set
	  END_CASE;
	  
	  statUnitModeCurrentInternalOld := instUnitModeStateManager.UnitModeCurrent;
	END_IF;
	
	IF instUnitModeStateManager.StateCurrent <> statStateInternalOld THEN // Check if new state is selected 
	  // Set states of boolean interface outputs
	  // Delete old state
	  ClearingStateActive := FALSE;
	  StoppedStateActive := FALSE;
	  StartingStateActive := FALSE;
	  IdleStateActive := FALSE;
	  SuspendedStateActive := FALSE;
	  ExecuteStateActive := FALSE;
	  StoppingStateActive := FALSE;
	  AbortingStateActive := FALSE;
	  AbortedStateActive := FALSE;
	  HoldingStateActive := FALSE;
	  HeldStateActive := FALSE;
	  UnholdingStateActive := FALSE;
	  SuspendingStateActive := FALSE;
	  UnsuspendingStateActive := FALSE;
	  ResettingStateActive := FALSE;
	  CompletingStateActive := FALSE;
	  CompletedStateActive := FALSE;
	  
	  // Set new state
	  CASE instUnitModeStateManager.StateCurrent OF
	    LPMLV2022_StateConstants#STATE_CLEARING:
	      ClearingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_STOPPED:
	      StoppedStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_STARTING:
	      StartingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_IDLE:
	      IdleStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_SUSPENDED:
	      SuspendedStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_EXECUTE:
	      ExecuteStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_STOPPING:
	      StoppingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_ABORTING:
	      AbortingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_ABORTED:
	      AbortedStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_HOLDING:
	      HoldingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_HELD:
	      HeldStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_UNHOLDING:
	      UnholdingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_SUSPENDING:
	      SuspendingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_UNSUSPENDING:
	      UnsuspendingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_RESETTING:
	      ResettingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_COMPLETING:
	      CompletingStateActive := TRUE;
	    LPMLV2022_StateConstants#STATE_COMPLETED:
	      CompletedStateActive := TRUE;
	    ELSE
	      ;
	  END_CASE; // End: Set new state
	  
	  statStateInternalOld := instUnitModeStateManager.StateCurrent;
	END_IF;// End: Write boolean interface outputs
	
	unitModeChangeNotAllowed := instUnitModeStateManager.unitModeChangeNotAllowed;
	cntrlCmdNotAllowed       := instUnitModeStateManager.cntrlCmdNotAllowed;
END_FUNCTION_BLOCK
END_NAMESPACE
