USING Siemens.Simatic.Clocks;
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
FUNCTION_BLOCK UnitModeStateManager
    {S7.extern = ReadWrite}
    VAR_INPUT
        /// Requested unit mode
        UnitMode : Mode := Mode#INVALID;
        /// TRUE: Request unit mode
        UnitModeChangeRequest : Bool;
        /// Request control command
        CntrlCmd : Command := Command#UNDEFINED;
        /// TRUE: Enable change into requested state
        CmdChangeRequest : Bool;
        /// State change from FALSE to TRUE (rising edge) triggers state complete signal
        SC : Bool;
        /// FB configuration (is taken into account in first call after STOP/RUN)
        config : typeConfiguration := (
          DisabledStatesCfg := [32(DWORD#16#0)],
          ModeTransitionCfg := [DWORD#0, 31(DWORD#16#00000214)]);
    END_VAR

   {S7.extern = ReadOnly}
   VAR_OUTPUT
        /// Current unit mode
        UnitModeCurrent  : Mode := Mode#MANUAL;
        /// Current state
        StateCurrent  : State := State#STOPPED;
        /// Requested state
        StateRequested  : State := State#STOPPED;
        /// State change in process
        StateChangeInProcess  : Bool;
        /// Disabled states in current unit mode
        CurDisabledStates  : DWord;
        /// Bit locations within the DWORD represent State numbers. A value of 1 in a bit location indicates that the Hold control command is taken into account in the corresponding state
        curHoldCmdCfg  : DWord;
        /// Bit locations within the DWORD represent State numbers. A value of 1 in a bit location indicates that the Complete control command is taken into account in the corresponding state
        curCompleteCmdCfg  : DWord;
        /// TRUE: Requested unit mode change is not allowed (output is reset with the next successful unit mode change or if input 'UnitMode' is set to 0 or if input 'UnitModeChangeRequest' is set to FALSE)
        unitModeChangeNotAllowed  : Bool;
        /// TRUE: Control command is not allowed (output is reset with the next successful CntrlCmd or if input 'CntrlCmd' is set to 0 or if input 'CmdChangeRequest' is set to FALSE)
        cntrlCmdNotAllowed  : Bool;
        /// Diagnostics information of FB
        diagnostics  : typeDiagnostics;
    END_VAR

    VAR
        _configuration  : typeConfiguration := (
          DisabledStatesCfg := [32(DWORD#16#0)],
          ModeTransitionCfg := [DWORD#0, 31(DWORD#16#00000214)]);   // FB configuration
        _unitModeChangeRequest  : Bool;   // TRUE: Enable change into requested unit mode
        _cmdChangeRequest  : Bool;   // TRUE: Enable change into requested state
        _firstCycle  : Bool := TRUE;   // First cycle of run
        _scOld  : Bool;   // For edge detection
        _unitMode  : Mode := Mode#MANUAL;   // Current command mode
        _unitModeOld  : Mode := Mode#MANUAL;   // For edge detection
        _unitModeCurrentInternal  : Mode := Mode#MANUAL;   // Current internal mode
        _unitModeCurrentInternalOld  : Mode := Mode#INVALID;   // For edge detection
        _stateCurrentOld  : State := State#STOPPED;   // For edge detection
        _stateInternal  : State := State#STOPPED;   // Current internal state
        _stateInternalOld  : State := State#UNDEFINED;   // For edge detection
        _cntrlCmdOld  : Command := Command#UNDEFINED;   // For edge detection
        _statesInCurrentMode  : typeStatesInCurrentMode;   // Copied from configuration
        _considerHoldCmdIn  : typeConsiderHoldCmdIn;   // Copied from configuration
        _considerCompleteCmdIn  : typeConsiderCompleteCmdIn;   // Copied from configuration
        _cmdChangeRequestOld  : Bool;   // For edge detection
        _unitModeChangeRequestOld  : Bool;   // For edge detection
        _diagnosticsBufferIndex  : Int := -1;   // Index of actual diagnostics buffer entry
        _stateRequested  : State := State#STOPPED;   // Static variable for requested state
        _unitModeChangeNotAllowed  : Bool;   // Static value for output 'unitModeChangeNotAllowed'
        _cntrlCmdNotAllowed  : Bool;   // Static value for output 'cntrlCmdNotAllowed'
    END_VAR

    VAR_TEMP
        tempDWord1 : DWord;
        tempDWord2 : DWord;
        tempCntrlCmd : Command;   // Temporary control command
        tempSCInternal : Bool;   // Internal state complete
        tempRetVal : Word;   // Tag for system function
        tempDiagnosticsBufferIndexSC : Int;   // Index of actual diagnostics buffer entry for SC messages
        tempDiagnosticsBufferIndexCmd : Int;   // Index of actual diagnostics buffer entry for control command messages
        tempSysTime : LDATE_AND_TIME; // for parsing to DTL type
        tempYear, tempMonth, tempDay, tempWeekday, tempHour, tempMinute, tempSecond, tempMillisecond, tempMicrosecond, tempNanosecond : INT;
    END_VAR

    IF NOT _cmdChangeRequest AND _cmdChangeRequestOld THEN // Falling edge CmdChangeRequest
      _cntrlCmdOld := Command#UNDEFINED;
    END_IF;
    _cmdChangeRequestOld := _cmdChangeRequest;

    IF NOT _unitModeChangeRequest AND _unitModeChangeRequestOld THEN // Falling edge UnitModeChangeRequest
      _unitModeOld := Mode#INVALID;
    END_IF;
    _unitModeChangeRequestOld := _unitModeChangeRequest;

    diagnostics.bufferIndex := _diagnosticsBufferIndex;
    tempDiagnosticsBufferIndexSC  := -1;
    tempDiagnosticsBufferIndexCmd := -1;

    StateCurrent    := _stateInternal;
    UnitModeCurrent := _unitModeCurrentInternal;

    IF _firstCycle THEN // Initialize values in first cycle
      _configuration := config; // Copy configuration from input
      _configuration.EnabledModesCfg.%X3 := TRUE; // Unit mode Manual is mandatory

    //--------------------------------------------------------------------------------------------------
    // Unit mode manager
    //--------------------------------------------------------------------------------------------------
    ELSE // As from second cycle
      //------------------------------------------------
      // Evaluation of input parameters -> UnitMode, CntrlCmd
      //------------------------------------------------
      _unitMode := UnitMode;
      tempCntrlCmd := CntrlCmd;

      // Set change requests from input
      _unitModeChangeRequest := UnitModeChangeRequest;
      _cmdChangeRequest      := CmdChangeRequest;

      //------------------------------------------------
      //Message handling for mode manager: head part
      //------------------------------------------------
      IF _unitModeChangeRequest AND _unitMode <> _unitModeOld AND _unitMode <> Mode#INVALID THEN
        _diagnosticsBufferIndex := _diagnosticsBufferIndex + 1; // Next buffer index
        IF _diagnosticsBufferIndex > LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
          _diagnosticsBufferIndex := 0;
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
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;


        diagnostics.buffer[_diagnosticsBufferIndex].UnitModeCurrent := TO_SINT(UnitModeCurrent);
        diagnostics.buffer[_diagnosticsBufferIndex].StateCurrent := TO_SINT(StateCurrent);
        diagnostics.buffer[_diagnosticsBufferIndex].UnitMode := TO_SINT(_unitMode);
        diagnostics.buffer[_diagnosticsBufferIndex].CntrlCmd := TO_SINT(tempCntrlCmd);
        diagnostics.buffer[_diagnosticsBufferIndex].SC := SC;
        diagnostics.buffer[_diagnosticsBufferIndex].message := Message#NO_MESSAGE;

        IF _unitMode < Mode#INVALID OR _unitMode > Mode#USER_28 THEN
          diagnostics.buffer[_diagnosticsBufferIndex].message := Message#MODE_NOT_DEFINED;
          _unitModeChangeNotAllowed := TRUE;
        ELSIF _unitMode = _unitModeCurrentInternal THEN
          diagnostics.buffer[_diagnosticsBufferIndex].message := Message#MODE_ALREADY_ACTIVE;
          _unitModeChangeNotAllowed := TRUE;
        END_IF;
      END_IF; // End: message handling for mode manager: head part
    END_IF;

    //------------------------------------------------
    // Unit mode machine
    //------------------------------------------------
    // Check if unit mode has to be changed
    IF (_unitModeChangeRequest AND
      _unitMode <> _unitModeCurrentInternal AND
      _unitMode <> _unitModeOld AND
      _unitMode > Mode#INVALID AND
      _unitMode <= Mode#USER_28
      ) OR
      _firstCycle
    THEN
      // Is a mode transition in the current state allowed?
      // -> Check mode transition config. The corresponding state bit for statStateInternal must be present in ModeTransitionCfg[statUnitMode] AND ModeTransitionCfg[statUnitModeCurrentInternal]
      tempDWord1 := SHR(_configuration.ModeTransitionCfg[_unitMode], TO_UINT(_stateInternal)); // Shift the bit, whose bit position corresponds to the value of statStateInternal to bit position zero (tempDWord1.%X0)
      tempDWord2 := SHR(_configuration.ModeTransitionCfg[_unitModeCurrentInternal], TO_UINT(_stateInternal)); // Shift the bit, whose bit position corresponds to the value of statStateInternal to bit position zero (tempDWord2.%X0)

      IF (tempDWord1.%X0 = FALSE OR tempDWord2.%X0 = FALSE) AND NOT _firstCycle THEN // Mode transition is not allowed
        diagnostics.buffer[_diagnosticsBufferIndex].message := Message#MODE_TRANSITION_NOT_ALLOWED;
        _unitModeChangeNotAllowed := TRUE;

      ELSE // (tempDWord1.%X0 = TRUE AND tempDWord2.%X0 = TRUE) -> The state bit of the current state is set in both mode transition config DWords, i.e. mode transition is allowed
        // Requested unit mode enabled? -> Is the corresponding bit set in the EnabledModesCfg DWord?
        tempDWord1 := SHR(_configuration.EnabledModesCfg, TO_UINT(_unitMode)); // Shift the bit, whose bit position corresponds to the value of statUnitMode to bit position zero (tempDWord1.%X0)

        IF (tempDWord1.%X0 = TRUE) THEN // Requested unit mode is enabled
          // State in requested unit mode available or rather not disabled? (Stopped, Idle, Execute and Aborted are always present. They cannot be disabled. Every acting state can be disabled)
          IF ((_stateInternal = State#CLEARING)     AND (_configuration.DisabledStatesCfg[_unitMode].%X1 = TRUE))  OR
             ((_stateInternal = State#STARTING)     AND (_configuration.DisabledStatesCfg[_unitMode].%X3 = TRUE))  OR
             ((_stateInternal = State#SUSPENDED)    AND (_configuration.DisabledStatesCfg[_unitMode].%X13 = TRUE) AND (_configuration.DisabledStatesCfg[_unitMode].%X14 = TRUE) AND (_configuration.DisabledStatesCfg[_unitMode].%X5 = TRUE)) OR
             ((_stateInternal = State#STOPPING)     AND (_configuration.DisabledStatesCfg[_unitMode].%X7 = TRUE))  OR
             ((_stateInternal = State#ABORTING)     AND (_configuration.DisabledStatesCfg[_unitMode].%X8 = TRUE))  OR
             ((_stateInternal = State#HOLDING)      AND (_configuration.DisabledStatesCfg[_unitMode].%X10 = TRUE)) OR
             ((_stateInternal = State#HELD)         AND (_configuration.DisabledStatesCfg[_unitMode].%X10 = TRUE) AND (_configuration.DisabledStatesCfg[_unitMode].%X12 = TRUE) AND (_configuration.DisabledStatesCfg[_unitMode].%X11 = TRUE)) OR
             ((_stateInternal = State#UNHOLDING)    AND (_configuration.DisabledStatesCfg[_unitMode].%X12 = TRUE)) OR
             ((_stateInternal = State#SUSPENDING)   AND (_configuration.DisabledStatesCfg[_unitMode].%X13 = TRUE)) OR
             ((_stateInternal = State#UNSUSPENDING) AND (_configuration.DisabledStatesCfg[_unitMode].%X14 = TRUE)) OR
             ((_stateInternal = State#RESETTING)    AND (_configuration.DisabledStatesCfg[_unitMode].%X15 = TRUE)) OR
             ((_stateInternal = State#COMPLETING)   AND (_configuration.DisabledStatesCfg[_unitMode].%X16 = TRUE)) OR
             ((_stateInternal = State#COMPLETED)    AND (_configuration.DisabledStatesCfg[_unitMode].%X16 = TRUE) AND (_configuration.DisabledStatesCfg[_unitMode].%X17 = TRUE))
          THEN // Error - state is not available in target unit mode
            diagnostics.buffer[_diagnosticsBufferIndex].message := Message#MODE_TRANSITION_NOT_POSSIBLE;
            _unitModeChangeNotAllowed := TRUE;

          ELSE // State in requested unit mode is available (or is going to be available, because the state configuration is adapted afterwards)
            // Set internal variable
            _unitModeCurrentInternal := _unitMode;

            // Read current configuration for the states
            _statesInCurrentMode.clearing := NOT _configuration.DisabledStatesCfg[_unitMode].%X1;
            _statesInCurrentMode.stopped := NOT _configuration.DisabledStatesCfg[_unitMode].%X2;
            _statesInCurrentMode.starting := NOT _configuration.DisabledStatesCfg[_unitMode].%X3;
            _statesInCurrentMode.idle := NOT _configuration.DisabledStatesCfg[_unitMode].%X4;
            _statesInCurrentMode.suspended := NOT _configuration.DisabledStatesCfg[_unitMode].%X5;
            _statesInCurrentMode.execute := NOT _configuration.DisabledStatesCfg[_unitMode].%X6;
            _statesInCurrentMode.stopping := NOT _configuration.DisabledStatesCfg[_unitMode].%X7;
            _statesInCurrentMode.aborting := NOT _configuration.DisabledStatesCfg[_unitMode].%X8;
            _statesInCurrentMode.aborted := NOT _configuration.DisabledStatesCfg[_unitMode].%X9;
            _statesInCurrentMode.holding := NOT _configuration.DisabledStatesCfg[_unitMode].%X10;
            _statesInCurrentMode.held := NOT _configuration.DisabledStatesCfg[_unitMode].%X11;
            _statesInCurrentMode.unholding := NOT _configuration.DisabledStatesCfg[_unitMode].%X12;
            _statesInCurrentMode.suspending := NOT _configuration.DisabledStatesCfg[_unitMode].%X13;
            _statesInCurrentMode.unsuspending := NOT _configuration.DisabledStatesCfg[_unitMode].%X14;
            _statesInCurrentMode.resetting := NOT _configuration.DisabledStatesCfg[_unitMode].%X15;
            _statesInCurrentMode.completing := NOT _configuration.DisabledStatesCfg[_unitMode].%X16;
            _statesInCurrentMode.completed := NOT _configuration.DisabledStatesCfg[_unitMode].%X17;
          END_IF; // End: state in target unit mode available
        ELSE // (tempDWord1.%X0 = FALSE), i.e. the requested unit mode is not enabled
          diagnostics.buffer[_diagnosticsBufferIndex].message := Message#REQ_MODE_NOT_CONFIGURED;
          _unitModeChangeNotAllowed := TRUE;
        END_IF;
      END_IF;

      // Set the minimum required states and correct the states configuration for the new current unit mode
      IF NOT _statesInCurrentMode.stopped OR
        NOT _statesInCurrentMode.idle OR
        NOT _statesInCurrentMode.execute OR
        NOT _statesInCurrentMode.aborted OR
        (NOT _statesInCurrentMode.held AND (_statesInCurrentMode.holding OR _statesInCurrentMode.unholding)) OR
        (NOT _statesInCurrentMode.suspended AND (_statesInCurrentMode.suspending OR _statesInCurrentMode.unsuspending)) OR
        (NOT _statesInCurrentMode.completed AND _statesInCurrentMode.completing)
      THEN
        // Minimum required: Stopped, Idle, Execute, Aborted
        _statesInCurrentMode.stopped := TRUE;
        _statesInCurrentMode.idle    := TRUE;
        _statesInCurrentMode.execute := TRUE;
        _statesInCurrentMode.aborted := TRUE;

        // Held branch (Held must be present, if Holding OR Unholding are configured)
        IF NOT _statesInCurrentMode.held
          AND (_statesInCurrentMode.holding OR _statesInCurrentMode.unholding)
        THEN
          _statesInCurrentMode.held := TRUE;
        END_IF;

        // Suspended branch (Suspended must be present, if Suspending OR Unsuspending are configured)
        IF NOT _statesInCurrentMode.suspended
          AND (_statesInCurrentMode.suspending OR _statesInCurrentMode.unsuspending)
        THEN
          _statesInCurrentMode.suspended := TRUE;
        END_IF;

        // Completed branch (Completed must be present, if Completing is configured)
        IF NOT _statesInCurrentMode.completed
          AND _statesInCurrentMode.completing
        THEN
          _statesInCurrentMode.completed := TRUE;
        END_IF;

        _diagnosticsBufferIndex := _diagnosticsBufferIndex + 1; // Next buffer index
        IF _diagnosticsBufferIndex > LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
          _diagnosticsBufferIndex := 0;
        END_IF;

        // Write diagnostics
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
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;

        diagnostics.buffer[_diagnosticsBufferIndex].UnitModeCurrent := TO_SINT(UnitModeCurrent);
        diagnostics.buffer[_diagnosticsBufferIndex].StateCurrent := TO_SINT(StateCurrent);
        diagnostics.buffer[_diagnosticsBufferIndex].UnitMode := TO_SINT(_unitMode);
        diagnostics.buffer[_diagnosticsBufferIndex].CntrlCmd := TO_SINT(tempCntrlCmd);
        diagnostics.buffer[_diagnosticsBufferIndex].SC := SC;
        diagnostics.buffer[_diagnosticsBufferIndex].message := Message#STATE_CONFIG_FORCED;
      END_IF; // End: set the minimum required states for every unit mode

      UnitModeCurrent := _unitModeCurrentInternal; // Write current unit mode on output

      // Write correct state configuration of current mode
      CurDisabledStates.%X1 := NOT _statesInCurrentMode.clearing;
      CurDisabledStates.%X2 := NOT _statesInCurrentMode.stopped;
      CurDisabledStates.%X3 := NOT _statesInCurrentMode.starting;
      CurDisabledStates.%X4 := NOT _statesInCurrentMode.idle;
      CurDisabledStates.%X5 := NOT _statesInCurrentMode.suspended;
      CurDisabledStates.%X6 := NOT _statesInCurrentMode.execute;
      CurDisabledStates.%X7 := NOT _statesInCurrentMode.stopping;
      CurDisabledStates.%X8 := NOT _statesInCurrentMode.aborting;
      CurDisabledStates.%X9 := NOT _statesInCurrentMode.aborted;
      CurDisabledStates.%X10 := NOT _statesInCurrentMode.holding;
      CurDisabledStates.%X11 := NOT _statesInCurrentMode.held;
      CurDisabledStates.%X12 := NOT _statesInCurrentMode.unholding;
      CurDisabledStates.%X13 := NOT _statesInCurrentMode.suspending;
      CurDisabledStates.%X14 := NOT _statesInCurrentMode.unsuspending;
      CurDisabledStates.%X15 := NOT _statesInCurrentMode.resetting;
      CurDisabledStates.%X16 := NOT _statesInCurrentMode.completing;
      CurDisabledStates.%X17 := NOT _statesInCurrentMode.completed;

      // Check in which states the Hold command is to be considered
      IF _statesInCurrentMode.held THEN // 1st condition: the Held state must be present
        // 2nd condition: the corresponding state where Hold shall be considered must be present
        _considerHoldCmdIn.starting     := _statesInCurrentMode.starting     AND _configuration.holdCmdCfg.%X3;
        _considerHoldCmdIn.idle         := _statesInCurrentMode.idle         AND _configuration.holdCmdCfg.%X4;
        _considerHoldCmdIn.suspended    := _statesInCurrentMode.suspended    AND _configuration.holdCmdCfg.%X5;
        _considerHoldCmdIn.execute      := _statesInCurrentMode.execute      AND _configuration.holdCmdCfg.%X6;
        _considerHoldCmdIn.unholding    := _statesInCurrentMode.unholding    AND _configuration.holdCmdCfg.%X12;
        _considerHoldCmdIn.suspending   := _statesInCurrentMode.suspending   AND _configuration.holdCmdCfg.%X13;
        _considerHoldCmdIn.unsuspending := _statesInCurrentMode.unsuspending AND _configuration.holdCmdCfg.%X14;
        _considerHoldCmdIn.completing   := _statesInCurrentMode.completing   AND _configuration.holdCmdCfg.%X16;
        _considerHoldCmdIn.completed    := _statesInCurrentMode.completed    AND _configuration.holdCmdCfg.%X17;

      ELSE // Held state is not present, i.e. Hold command is not allowed in any state
        _considerHoldCmdIn.starting     := FALSE;
        _considerHoldCmdIn.idle         := FALSE;
        _considerHoldCmdIn.suspended    := FALSE;
        _considerHoldCmdIn.execute      := FALSE;
        _considerHoldCmdIn.unholding    := FALSE;
        _considerHoldCmdIn.suspending   := FALSE;
        _considerHoldCmdIn.unsuspending := FALSE;
        _considerHoldCmdIn.completing   := FALSE;
        _considerHoldCmdIn.completed    := FALSE;
      END_IF;

      // Write correct state configuration where the Hold command is considered
      curHoldCmdCfg := DWORD#16#0000_0000;
      // curHoldCmdCfg.%X1  := FALSE;
      // curHoldCmdCfg.%X2  := FALSE;
      curHoldCmdCfg.%X3  := _considerHoldCmdIn.starting;
      curHoldCmdCfg.%X4  := _considerHoldCmdIn.idle;
      curHoldCmdCfg.%X5  := _considerHoldCmdIn.suspended;
      curHoldCmdCfg.%X6  := _considerHoldCmdIn.execute;
      // curHoldCmdCfg.%X7  := FALSE;
      // curHoldCmdCfg.%X8  := FALSE;
      // curHoldCmdCfg.%X9  := FALSE;
      // curHoldCmdCfg.%X10 := FALSE;
      // curHoldCmdCfg.%X11 := FALSE;
      curHoldCmdCfg.%X12 := _considerHoldCmdIn.unholding;
      curHoldCmdCfg.%X13 := _considerHoldCmdIn.suspending;
      curHoldCmdCfg.%X14 := _considerHoldCmdIn.unsuspending;
      // curHoldCmdCfg.%X15 := FALSE;
      curHoldCmdCfg.%X16 := _considerHoldCmdIn.completing;
      curHoldCmdCfg.%X17 := _considerHoldCmdIn.completed;

      // Check in which states the Complete command is to be considered
      IF _statesInCurrentMode.completed THEN // 1st condition: the Completed state must be present
        // 2nd condition: the corresponding state where Complete shall be considered must be present
        _considerCompleteCmdIn.suspended := _statesInCurrentMode.suspended AND _configuration.completeCmdCfg.%X5;
        _considerCompleteCmdIn.execute   := _statesInCurrentMode.execute   AND _configuration.completeCmdCfg.%X6;
        _considerCompleteCmdIn.held      := _statesInCurrentMode.held      AND _configuration.completeCmdCfg.%X11;

      ELSE // Completed state is not present, i.e. Complete command is not allowed in any state
        _considerCompleteCmdIn.suspended := FALSE;
        _considerCompleteCmdIn.execute   := FALSE;
        _considerCompleteCmdIn.held      := FALSE;
      END_IF;

      // Write correct state configuration where the Complete command is considered
      curCompleteCmdCfg := DWORD#16#0000_0000;
      // curCompleteCmdCfg.%X1  := FALSE;
      // curCompleteCmdCfg.%X2  := FALSE;
      // curCompleteCmdCfg.%X3  := FALSE;
      // curCompleteCmdCfg.%X4  := FALSE;
      curCompleteCmdCfg.%X5  := _considerCompleteCmdIn.suspended;
      curCompleteCmdCfg.%X6  := _considerCompleteCmdIn.execute;
      // curCompleteCmdCfg.%X7  := FALSE;
      // curCompleteCmdCfg.%X8  := FALSE;
      // curCompleteCmdCfg.%X9  := FALSE;
      // curCompleteCmdCfg.%X10 := FALSE;
      curCompleteCmdCfg.%X11 := _considerCompleteCmdIn.held;
      // curCompleteCmdCfg.%X12 := FALSE;
      // curCompleteCmdCfg.%X13 := FALSE;
      // curCompleteCmdCfg.%X14 := FALSE;
      // curCompleteCmdCfg.%X15 := FALSE;
      // curCompleteCmdCfg.%X16 := FALSE;
      // curCompleteCmdCfg.%X17 := FALSE;

      //-----------------------------------------------
      // Message handling for mode manager: foot part
      //-----------------------------------------------
      IF NOT _firstCycle THEN
        IF diagnostics.buffer[_diagnosticsBufferIndex].message = Message#NO_MESSAGE THEN // ELSE: Unit mode wasn´t changed successfully
          diagnostics.buffer[_diagnosticsBufferIndex].message := Message#MODE_CHANGED_SUCCESSFULLY;
          _unitModeChangeNotAllowed := FALSE;
        END_IF;
      END_IF;
    END_IF;// End: check if unit mode has to be changed
    // End: Unit mode manager

    //--------------------------------------------------------------------------------------------------
    // State manager
    //--------------------------------------------------------------------------------------------------
    IF NOT _firstCycle THEN // As from second cycle
      IF SC AND NOT _scOld THEN // Detect a rising edge at state complete signal
        tempSCInternal := TRUE;
      ELSE
        tempSCInternal := FALSE;
      END_IF;
      _scOld := SC; // End: Detect a rising edge at state complete signal

      //---------------------------------------------------------------------
      // Message handling for state manager: head part
      //---------------------------------------------------------------------
      IF tempSCInternal THEN // Check if rising edge of SC was detected
        _diagnosticsBufferIndex := _diagnosticsBufferIndex + 1; // Next buffer index
        IF _diagnosticsBufferIndex > LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
          _diagnosticsBufferIndex := 0;
        END_IF;
        tempDiagnosticsBufferIndexSC := _diagnosticsBufferIndex;

        // Write diagnostics
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
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;

        diagnostics.buffer[tempDiagnosticsBufferIndexSC].UnitModeCurrent := TO_SINT(UnitModeCurrent);
        diagnostics.buffer[tempDiagnosticsBufferIndexSC].StateCurrent := TO_SINT(StateCurrent);
        diagnostics.buffer[tempDiagnosticsBufferIndexSC].UnitMode := TO_SINT(_unitMode);
        diagnostics.buffer[tempDiagnosticsBufferIndexSC].CntrlCmd := TO_SINT(tempCntrlCmd);
        diagnostics.buffer[tempDiagnosticsBufferIndexSC].SC := SC;

        // Check current state to use SC
        IF _stateInternal = State#CLEARING OR
          _stateInternal = State#STARTING OR
          _stateInternal = State#STOPPING OR
          _stateInternal = State#ABORTING OR
          _stateInternal = State#HOLDING OR
          _stateInternal = State#UNHOLDING OR
          _stateInternal = State#SUSPENDING OR
          _stateInternal = State#UNSUSPENDING OR
          _stateInternal = State#RESETTING OR
          _stateInternal = State#COMPLETING
        THEN
          diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#NO_MESSAGE;
        ELSE
          diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#SC_NOT_ALLOWED;
        END_IF; // End: Check current state to use SC
      END_IF;

      // Check if defined control command was sent correctly
      IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN
        _diagnosticsBufferIndex := _diagnosticsBufferIndex + 1; // Next buffer index
        IF _diagnosticsBufferIndex > LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
          _diagnosticsBufferIndex := 0;
        END_IF;
        tempDiagnosticsBufferIndexCmd := _diagnosticsBufferIndex;

        // Write diagnostics
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
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.YEAR := TO_UINT(tempYear);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MONTH := TO_USINT(tempMonth);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.DAY := TO_USINT(tempDay);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.WEEKDAY := TO_USINT(GetDayOfWeek(tempSysTime)) + USINT#1; // +1 as DTL in TIA uses 1 (Sunday) to 7 (Saturday) and GetDayOfWeek uses 0 (Sunday) to 6 (Saturday);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.HOUR := TO_USINT(tempHour);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.MINUTE := TO_USINT(tempMinute);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.SECOND := TO_USINT(tempSecond);
        diagnostics.buffer[_diagnosticsBufferIndex].timestamp.NANOSECOND := TO_UDINT(tempNanosecond) + TO_UDINT(tempMicrosecond) * UDINT#1000 + TO_UDINT(tempMillisecond) * UDINT#1000000;

        diagnostics.buffer[tempDiagnosticsBufferIndexCmd].UnitModeCurrent := TO_SINT(UnitModeCurrent);
        diagnostics.buffer[tempDiagnosticsBufferIndexCmd].StateCurrent := TO_SINT(StateCurrent);
        diagnostics.buffer[tempDiagnosticsBufferIndexCmd].UnitMode := TO_SINT(_unitMode);
        diagnostics.buffer[tempDiagnosticsBufferIndexCmd].CntrlCmd := TO_SINT(tempCntrlCmd);
        diagnostics.buffer[tempDiagnosticsBufferIndexCmd].SC := SC;

        IF (tempCntrlCmd >= Command#RESET) AND (tempCntrlCmd <= Command#COMPLETE)
        THEN // A defined control command was sent (RESET, START, STOP, HOLD, UNHOLD, SUSPEND, UNSUSPEND, ABORT, CLEAR, COMPLETE)
          diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#NO_MESSAGE;

          IF
            // Throw message if any other CntrlCmd than Abort, Stop or Hold is triggered in the following acting states
            ((_stateInternal = State#STARTING OR
            _stateInternal = State#UNHOLDING OR
            _stateInternal = State#SUSPENDING OR
            _stateInternal = State#UNSUSPENDING OR
            _stateInternal = State#COMPLETING) AND
            NOT (tempCntrlCmd = Command#ABORT) AND NOT (tempCntrlCmd =Command#STOP) AND NOT (tempCntrlCmd = Command#HOLD)) OR
            // Throw message if any other CntrlCmd than Abort or Stop is triggered in the following acting states
            ((_stateInternal = State#HOLDING OR
            _stateInternal = State#RESETTING) AND
            NOT (tempCntrlCmd = Command#ABORT) AND NOT (tempCntrlCmd =Command#STOP)) OR
            // Throw message if any other CntrlCmd than Abort is triggered in the following acting states
            ((_stateInternal = State#STOPPING OR _stateInternal =State#CLEARING) AND NOT (tempCntrlCmd = Command#ABORT)) OR
            // Throw message if any CntrlCmd is triggered in Aborting, because no CntrlCmd is allowed in Aborting
            (_stateInternal = State#ABORTING)
          THEN // Write message if CntrlCmd is not allowed
            diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
            _cntrlCmdNotAllowed := TRUE;
          END_IF;

        ELSE // Not defined control command was sent
          diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_DEFINED;
          _cntrlCmdNotAllowed := TRUE;
        END_IF;
      END_IF; // End: message handling for state manager: head part

      //---------------------------------------------------------------------
      // State machine
      //---------------------------------------------------------------------
      IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd = Command#ABORT AND // Check if abort command was sent correctly
        _stateInternal <> State#ABORTED AND
        _stateInternal <> State#ABORTING
      THEN
        // Abort command was sent correctly
        _stateRequested := State#ABORTED;
        // Select next state
        IF _statesInCurrentMode.aborting THEN
          StateChangeInProcess := TRUE;
          _stateInternal := State#ABORTING;
        ELSE
          StateChangeInProcess := FALSE;
          _stateInternal := State#ABORTED;
        END_IF;

      ELSIF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd = Command#STOP AND // Check if correct stop command was sent
        _stateInternal <> State#ABORTED AND
        _stateInternal <> State#ABORTING AND
        _stateInternal <> State#CLEARING AND
        _stateInternal <> State#STOPPING AND
        _stateInternal <> State#STOPPED
      THEN
        // Stop command was sent correctly
        _stateRequested := State#STOPPED;
        // Select next state
        IF _statesInCurrentMode.stopping THEN
          StateChangeInProcess := TRUE;
          _stateInternal := State#STOPPING;
        ELSE
          StateChangeInProcess := FALSE;
          _stateInternal := State#STOPPED;
        END_IF;
      ELSE // Internal state machine
        CASE _stateInternal OF
          State#EXECUTE:
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN // Check if state change is requested
              CASE tempCntrlCmd OF // Check control command
                Command#COMPLETE:
                  IF _considerCompleteCmdIn.execute THEN
                    // Check if valid state for command is in use by current unit mode
                    IF _statesInCurrentMode.completing THEN
                      StateChangeInProcess := TRUE;
                      _stateRequested := State#COMPLETED;
                      _stateInternal := State#COMPLETING;
                    ELSIF _statesInCurrentMode.completed THEN
                      StateChangeInProcess := FALSE;
                      _stateRequested := State#COMPLETED;
                      _stateInternal := State#COMPLETED;
                    ELSE
                      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                      _cntrlCmdNotAllowed := TRUE;
                    END_IF;
                  ELSE // statConsiderCompleteCmdIn.execute = FALSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                Command#HOLD:
                  IF _considerHoldCmdIn.execute THEN
                    // Check if valid state for command is in use by current unit mode
                    IF _statesInCurrentMode.holding THEN
                      StateChangeInProcess := TRUE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HOLDING;
                    ELSIF _statesInCurrentMode.held THEN
                      StateChangeInProcess := FALSE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HELD;
                    ELSE
                      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                      _cntrlCmdNotAllowed := TRUE;
                    END_IF;
                  ELSE // statConsiderHoldCmdIn.execute = FALSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                Command#SUSPEND:
                  // Check if valid state for command is in use by current unit mode
                  IF _statesInCurrentMode.suspending THEN
                    StateChangeInProcess := TRUE;
                    _stateRequested := State#SUSPENDED;
                    _stateInternal := State#SUSPENDING;
                  ELSIF _statesInCurrentMode.suspended THEN
                    StateChangeInProcess := FALSE;
                    _stateRequested := State#SUSPENDED;
                    _stateInternal := State#SUSPENDED;
                  ELSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
                ELSE
                  IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
              END_CASE;
            END_IF;

          State#COMPLETING:
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd = Command#HOLD THEN // Check if state change is requested
              IF _considerHoldCmdIn.completing THEN
                // Check if valid state for command is in use by current unit mode
                IF _statesInCurrentMode.holding THEN
                  StateChangeInProcess := TRUE;
                  _stateRequested := State#HELD;
                  _stateInternal := State#HOLDING;
                ELSIF _statesInCurrentMode.held THEN
                  StateChangeInProcess := FALSE;
                  _stateRequested := State#HELD;
                  _stateInternal := State#HELD;
                ELSE
                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                  _cntrlCmdNotAllowed := TRUE;
                END_IF;

              ELSE // statConsiderHoldCmdIn.completing = FALSE
                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                _cntrlCmdNotAllowed := TRUE;
              END_IF;
            END_IF;

            IF (_stateRequested <> State#HELD) THEN // Check SC only, if no successful Hold command has been triggered
              // Check if state is completed
              IF tempSCInternal AND _statesInCurrentMode.completed THEN
                StateChangeInProcess := FALSE;
                _stateInternal := State#COMPLETED;
              ELSIF tempSCInternal AND NOT _statesInCurrentMode.completed THEN
                diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#SC_NOT_ALLOWED;
              END_IF;

            ELSE // (statStateRequested = State#HELD), i.e. successful Hold command has been triggered
              IF tempSCInternal THEN
                diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#SC_OVERRIDDEN_BY_CMD_HOLD;
              END_IF;
            END_IF;

          State#COMPLETED:
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN // Check if state change is requested
              CASE tempCntrlCmd OF // Check control command
                Command#RESET:
                  // Check if valid state for command is in use by current unit mode
                  IF _statesInCurrentMode.resetting THEN
                    StateChangeInProcess := TRUE;
                    _stateRequested := State#IDLE;
                    _stateInternal := State#RESETTING;
                  ELSIF _statesInCurrentMode.idle THEN
                    StateChangeInProcess := FALSE;
                    _stateRequested := State#IDLE;
                    _stateInternal := State#IDLE;
                  ELSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                Command#HOLD:
                  IF _considerHoldCmdIn.completed THEN
                    // Check if valid state for command is in use by current unit mode
                    IF _statesInCurrentMode.holding THEN
                      StateChangeInProcess := TRUE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HOLDING;
                    ELSIF _statesInCurrentMode.held THEN
                      StateChangeInProcess := FALSE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HELD;
                    ELSE
                      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                      _cntrlCmdNotAllowed := TRUE;
                    END_IF;
                  ELSE // statConsiderHoldCmdIn.completed = FALSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                ELSE
                  IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
              END_CASE;
            END_IF;

          State#RESETTING:
            // Check if state is completed
            // No message handling needed -> Idle is minimum required state
            IF tempSCInternal THEN // ELSE: Wait for state complete signal
              StateChangeInProcess := FALSE;
              _stateInternal := State#IDLE;
            END_IF;

          State#IDLE:
            //  Check if valid command is sent
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN // Check if state change is requested
              CASE tempCntrlCmd OF // Check control command
                  Command#START:
                  //  No message handling needed -> Execute is minimum required state
                  _stateRequested := State#EXECUTE;
                  // Check if valid state for command is in use by current mode
                  IF _statesInCurrentMode.starting THEN
                    StateChangeInProcess := TRUE;
                    _stateInternal := State#STARTING;
                  ELSE
                    StateChangeInProcess := FALSE;
                    _stateInternal := State#EXECUTE;
                  END_IF;

                Command#HOLD:
                  IF _considerHoldCmdIn.idle THEN
                    // Check if valid state for command is in use by current unit mode
                    IF _statesInCurrentMode.holding THEN
                      StateChangeInProcess := TRUE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HOLDING;
                    ELSIF _statesInCurrentMode.held THEN
                      StateChangeInProcess := FALSE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HELD;
                    ELSE
                      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                      _cntrlCmdNotAllowed := TRUE;
                    END_IF;
                  ELSE // statConsiderHoldCmdIn.idle = FALSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                ELSE
                  IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
              END_CASE;
            END_IF;

          State#STARTING,
          State#UNHOLDING,
          State#UNSUSPENDING:
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd = Command#HOLD THEN // Check if state change is requested
              IF (_considerHoldCmdIn.starting AND _stateInternal = State#STARTING) OR
                (_considerHoldCmdIn.unholding AND _stateInternal = State#UNHOLDING) OR
                (_considerHoldCmdIn.unsuspending AND _stateInternal = State#UNSUSPENDING)
              THEN
                // Check if valid state for command is in use by current unit mode
                IF _statesInCurrentMode.holding THEN
                  StateChangeInProcess := TRUE;
                  _stateRequested := State#HELD;
                  _stateInternal := State#HOLDING;
                ELSIF _statesInCurrentMode.held THEN
                  StateChangeInProcess := FALSE;
                  _stateRequested := State#HELD;
                  _stateInternal := State#HELD;
                ELSE
                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                  _cntrlCmdNotAllowed := TRUE;
                END_IF;

              ELSE // statConsiderHoldCmdIn.xxx = FALSE
                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                _cntrlCmdNotAllowed := TRUE;
              END_IF;
            END_IF;

            IF (_stateRequested <> State#HELD) THEN // Check SC only, if no successful Hold command has been triggered
              // Check if state is completed
              IF tempSCInternal THEN // ELSE: Wait for state complete signal
                StateChangeInProcess := FALSE;
                _stateInternal := State#EXECUTE;
              END_IF;

            ELSE // (statStateRequested = State#HELD), i.e. successful Hold command has been triggered
              IF tempSCInternal THEN
                diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#SC_OVERRIDDEN_BY_CMD_HOLD;
              END_IF;
            END_IF;

          State#HOLDING:
            // Check if state is completed
            IF tempSCInternal AND _statesInCurrentMode.held THEN // ELSE: Wait for state complete signal
              StateChangeInProcess := FALSE;
              _stateInternal := State#HELD;
            ELSIF tempSCInternal AND NOT _statesInCurrentMode.held THEN
              diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#SC_NOT_ALLOWED;
            END_IF;

          State#HELD:
            //  Check if valid command is sent
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN // Check if state change is requested
              CASE tempCntrlCmd OF // Check control command
                Command#UNHOLD:
                  _stateRequested := State#EXECUTE;
                  // Check if valid state for command is in use by current mode
                  IF _statesInCurrentMode.unholding THEN
                    StateChangeInProcess := TRUE;
                    _stateInternal := State#UNHOLDING;
                  ELSE
                    StateChangeInProcess := FALSE;
                    _stateInternal := State#EXECUTE;
                  END_IF;

                Command#COMPLETE:
                  IF _considerCompleteCmdIn.held THEN
                    // Check if valid state for command is in use by current unit mode
                    IF _statesInCurrentMode.completing THEN
                      StateChangeInProcess := TRUE;
                      _stateRequested := State#COMPLETED;
                      _stateInternal := State#COMPLETING;
                    ELSIF _statesInCurrentMode.completed THEN
                      StateChangeInProcess := FALSE;
                      _stateRequested := State#COMPLETED;
                      _stateInternal := State#COMPLETED;
                    ELSE
                      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                      _cntrlCmdNotAllowed := TRUE;
                    END_IF;
                  ELSE // statConsiderCompleteCmdIn.held = FALSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                ELSE
                  IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
              END_CASE;
            END_IF;

          State#SUSPENDING:
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd = Command#HOLD THEN // Check if state change is requested
              IF _considerHoldCmdIn.suspending THEN
                // Check if valid state for command is in use by current unit mode
                IF _statesInCurrentMode.holding THEN
                  StateChangeInProcess := TRUE;
                  _stateRequested := State#HELD;
                  _stateInternal := State#HOLDING;
                ELSIF _statesInCurrentMode.held THEN
                  StateChangeInProcess := FALSE;
                  _stateRequested := State#HELD;
                  _stateInternal := State#HELD;
                ELSE
                  diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                  _cntrlCmdNotAllowed := TRUE;
                END_IF;

              ELSE // statConsiderHoldCmdIn.suspending = FALSE
                diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                _cntrlCmdNotAllowed := TRUE;
              END_IF;
            END_IF;

            IF (_stateRequested <> State#HELD) THEN // Check SC only, if no successful Hold command has been triggered
              // Check if state is completed
              IF tempSCInternal AND _statesInCurrentMode.suspended THEN // ELSE: Wait for state complete signal
                StateChangeInProcess := FALSE;
                _stateInternal := State#SUSPENDED;
              ELSIF tempSCInternal AND NOT _statesInCurrentMode.suspended THEN
                diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#SC_NOT_ALLOWED;
              END_IF;

            ELSE // (statStateRequested = State#HELD), i.e. successful Hold command has been triggered
              IF tempSCInternal THEN
                diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#SC_OVERRIDDEN_BY_CMD_HOLD;
              END_IF;
            END_IF;

          State#SUSPENDED:
            //  Check if valid command is sent
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN // Check if state change is requested
              CASE tempCntrlCmd OF // Check control command
                  Command#UNSUSPEND:
                  _stateRequested := State#EXECUTE;
                  // Check if valid state for command is in use by current mode
                  IF _statesInCurrentMode.unsuspending THEN
                    StateChangeInProcess := TRUE;
                    _stateInternal := State#UNSUSPENDING;
                  ELSE
                    StateChangeInProcess := FALSE;
                    _stateInternal := State#EXECUTE;
                  END_IF;

                Command#COMPLETE:
                  IF _considerCompleteCmdIn.suspended THEN
                    // Check if valid state for command is in use by current unit mode
                    IF _statesInCurrentMode.completing THEN
                      StateChangeInProcess := TRUE;
                      _stateRequested := State#COMPLETED;
                      _stateInternal := State#COMPLETING;
                    ELSIF _statesInCurrentMode.completed THEN
                      StateChangeInProcess := FALSE;
                      _stateRequested := State#COMPLETED;
                      _stateInternal := State#COMPLETED;
                    ELSE
                      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                      _cntrlCmdNotAllowed := TRUE;
                    END_IF;
                  ELSE // statConsiderCompleteCmdIn.suspended = FALSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                Command#HOLD:
                  IF _considerHoldCmdIn.suspended THEN
                    // Check if valid state for command is in use by current unit mode
                    IF _statesInCurrentMode.holding THEN
                      StateChangeInProcess := TRUE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HOLDING;
                    ELSIF _statesInCurrentMode.held THEN
                      StateChangeInProcess := FALSE;
                      _stateRequested := State#HELD;
                      _stateInternal := State#HELD;
                    ELSE
                      diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                      _cntrlCmdNotAllowed := TRUE;
                    END_IF;
                  ELSE // statConsiderHoldCmdIn.suspended = FALSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                ELSE
                  IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
              END_CASE;
            END_IF;

          State#ABORTING:
            // Check if state is completed
            // No message handling needed -> Aborted is minimum required state
            IF tempSCInternal THEN // ELSE: Wait for state complete signal
              StateChangeInProcess := FALSE;
              _stateInternal := State#ABORTED;
            END_IF;

          State#ABORTED:
            //  Check if valid command is sent
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN // Check if state change is requested
              CASE tempCntrlCmd OF // Check control command
                Command#CLEAR:
                  _stateRequested := State#STOPPED;
                  // Check if valid state for command is in use by current mode
                  IF _statesInCurrentMode.clearing THEN
                    StateChangeInProcess := TRUE;
                    _stateInternal := State#CLEARING;
                  ELSE
                    StateChangeInProcess := FALSE;
                    _stateInternal := State#STOPPED;
                  END_IF;
                ELSE
                  IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
              END_CASE;
            END_IF;

          State#CLEARING,
          State#STOPPING:
            // Check if state is completed
            // No message handling needed -> Stopped is minimum required state
            IF tempSCInternal THEN // ELSE: Wait for state complete signal
              StateChangeInProcess := FALSE;
              _stateInternal := State#STOPPED;
            END_IF;

          State#STOPPED:
            IF _cmdChangeRequest AND tempCntrlCmd <> _cntrlCmdOld AND tempCntrlCmd <> Command#UNDEFINED THEN // Check if state change is requested
              // Check if valid command is sent
              CASE tempCntrlCmd OF
                Command#RESET:
                  // Check if valid state for command is in use by current unit mode
                  IF _statesInCurrentMode.resetting THEN
                    StateChangeInProcess := TRUE;
                    _stateRequested := State#IDLE;
                    _stateInternal := State#RESETTING;
                  ELSIF _statesInCurrentMode.idle THEN
                    StateChangeInProcess := FALSE;
                    _stateRequested := State#IDLE;
                    _stateInternal := State#IDLE;
                  ELSE
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;

                ELSE
                  IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN // ELSE: Message was already written in head part of message handling
                    diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#CMD_NOT_ALLOWED;
                    _cntrlCmdNotAllowed := TRUE;
                  END_IF;
              END_CASE;
            END_IF;

          State#UNDEFINED:
            StateChangeInProcess := FALSE;
            _stateRequested := State#STOPPED;
            _stateInternal := State#STOPPED;

          ELSE
            ; // Undefined state
        END_CASE;
      END_IF; // End: state machine

      //-------------------------------------------------
      // Message handling for state manager: foot part
      //-------------------------------------------------
      IF _stateInternal <> _stateCurrentOld THEN // ELSE: States were not changed
        IF tempDiagnosticsBufferIndexCmd >= 0 AND tempDiagnosticsBufferIndexCmd <= LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
          IF diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message = Message#NO_MESSAGE THEN
            diagnostics.buffer[tempDiagnosticsBufferIndexCmd].message := Message#STATE_CHANGED_SUCCESSFULLY;
            _cntrlCmdNotAllowed := FALSE;
          END_IF;
        END_IF;
        IF tempDiagnosticsBufferIndexSC >= 0 AND tempDiagnosticsBufferIndexSC <= LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
          IF diagnostics.buffer[tempDiagnosticsBufferIndexSC].message = Message#NO_MESSAGE THEN
            diagnostics.buffer[tempDiagnosticsBufferIndexSC].message := Message#STATE_CHANGED_SUCCESSFULLY;
          END_IF;
        END_IF;
      END_IF; // End: message handling for state manager: foot part
    END_IF; // End: As from second cycle
    // End: State manager

    //--------------------------------------------------------------------------------------------------
    // Write outputs
    //--------------------------------------------------------------------------------------------------
    StateCurrent := _stateInternal; // Set output

    diagnostics.bufferIndex := _diagnosticsBufferIndex; // Local variable is used during block execution -> Copy back/Set output
    IF _firstCycle THEN
      _firstCycle := FALSE;
    END_IF;

    // Save values for edge detection
    IF _unitModeChangeRequest THEN
      _unitModeOld := _unitMode;
    END_IF;
    IF _cmdChangeRequest THEN
      _cntrlCmdOld := tempCntrlCmd;
    END_IF;
    IF _stateInternal <> _stateCurrentOld THEN
      _stateCurrentOld := _stateInternal;
    END_IF;

    StateRequested := _stateRequested;

    IF (_unitModeChangeRequest = FALSE) OR (_unitMode = Mode#INVALID) THEN
      _unitModeChangeNotAllowed := FALSE;
    END_IF;
    IF (_cmdChangeRequest = FALSE) OR (tempCntrlCmd = Command#UNDEFINED) THEN
      _cntrlCmdNotAllowed := FALSE;
    END_IF;

    unitModeChangeNotAllowed := _unitModeChangeNotAllowed;
    cntrlCmdNotAllowed       := _cntrlCmdNotAllowed;
END_FUNCTION_BLOCK
END_NAMESPACE
