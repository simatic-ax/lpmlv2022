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
FUNCTION_BLOCK UnitModeStateManagerBool
{S7.extern = ReadWrite}
   VAR_INPUT
      /// Rising edge: Request change to unit mode Production
      ProductionModeRequest : Bool;
      /// Rising edge: Request change to unit mode Maintenance
      MaintenanceModeRequest : Bool;
      /// Rising edge: Request change to unit mode Manual
      ManualModeRequest : Bool;
      /// Rising edge: Request change to user-defined unit mode 01
      UserMode01Request : Bool;
      /// Rising edge: Request change to user-defined unit mode 02
      UserMode02Request : Bool;
      /// Rising edge: Request change to user-defined unit mode 03
      UserMode03Request : Bool;
      /// Rising edge: Request change to user-defined unit mode 04
      UserMode04Request : Bool;
      /// Rising edge: Request change to user-defined unit mode 05
      UserMode05Request : Bool;
      /// Rising edge: Request control command Reset
      ResetCmdRequest : Bool;
      /// Rising edge: Request control command Start
      StartCmdRequest : Bool;
      /// Rising edge: Request control command Stop
      StopCmdRequest : Bool;
      /// Rising edge: Request control command Hold
      HoldCmdRequest : Bool;
      /// Rising edge: Request control command Unhold
      UnholdCmdRequest : Bool;
      /// Rising edge: Request control command Suspend
      SuspendCmdRequest : Bool;
      /// Rising edge: Request control command Unsuspend
      UnsuspendCmdRequest : Bool;
      /// Rising edge: Request control command Abort
      AbortCmdRequest : Bool;
      /// Rising edge: Request control command Clear
      ClearCmdRequest : Bool;
      /// Rising edge: Request control command Complete
      CompleteCmdRequest : Bool;
      /// State change from FALSE to TRUE (rising edge) triggers state complete signal
      SC : Bool;
      /// FB config (is taken into account in first call after STOP/RUN)
      config : typeConfiguration := (
        DisabledStatesCfg := [32(DWORD#16#0)],
        ModeTransitionCfg := [DWORD#0, 31(DWORD#16#00000214)]);
   END_VAR


{S7.extern = ReadOnly}
   VAR_OUTPUT
      /// Current unit mode
      UnitModeCurrent : Mode := Mode#INVALID;
      /// Current state
      StateCurrent : State := State#UNDEFINED;
      /// TRUE: Unit mode Production is currently active
      ProductionModeActive : Bool;
      /// TRUE: Unit mode Maintenance is currently active
      MaintenanceModeActive : Bool;
      /// TRUE: Unit mode Manual is currently active
      ManualModeActive : Bool;
      /// TRUE: User-defined unit mode 01 is currently active
      UserMode01Active : Bool;
      /// TRUE: User-defined unit mode 02 is currently active
      UserMode02Active : Bool;
      /// TRUE: User-defined unit mode 03 is currently active
      UserMode03Active : Bool;
      /// TRUE: User-defined unit mode 04 is currently active
      UserMode04Active : Bool;
      /// TRUE: User-defined unit mode 05 is currently active
      UserMode05Active : Bool;
      /// TRUE: State Clearing is currently active
      ClearingStateActive : Bool;
      /// TRUE: State Stopped is currently active
      StoppedStateActive : Bool;
      /// TRUE: State Starting is currently active
      StartingStateActive : Bool;
      /// TRUE: State Idle is currently active
      IdleStateActive : Bool;
      /// TRUE: State Suspended is currently active
      SuspendedStateActive : Bool;
      /// TRUE: State Execute is currently active
      ExecuteStateActive : Bool;
      /// TRUE: State Stopping is currently active
      StoppingStateActive : Bool;
      /// TRUE: State Aborting is currently active
      AbortingStateActive : Bool;
      /// TRUE: State Aborted is currently active
      AbortedStateActive : Bool;
      /// TRUE: State Holding is currently active
      HoldingStateActive : Bool;
      /// TRUE: State Held is currently active
      HeldStateActive : Bool;
      /// TRUE: State Unholding is currently active
      UnholdingStateActive : Bool;
      /// TRUE: State Suspending is currently active
      SuspendingStateActive : Bool;
      /// TRUE: State Unsuspending is currently active
      UnsuspendingStateActive : Bool;
      /// TRUE: State Resetting is currently active
      ResettingStateActive : Bool;
      /// TRUE: State Completing is currently active
      CompletingStateActive : Bool;
      /// TRUE: State Completed is currently active
      CompletedStateActive : Bool;
      /// TRUE: Requested unit mode change is not allowed (output is reset with the next successful unit mode change or if all corresponding request inputs are set to FALSE)
      unitModeChangeNotAllowed : Bool;
      /// TRUE: Control command is not allowed (output is reset with the next successful control command or if all corresponding request inputs are set to FALSE)
      cntrlCmdNotAllowed : Bool;
   END_VAR

   VAR
    {S7.extern = ReadOnly}
      _instUnitModeStateManager : UnitModeStateManager;   // Instance of UnitModeStateManager
      _firstCycle : Bool := TRUE;   // First cycle of run
      _unitModeCurrentInternalOld : Mode := Mode#INVALID;   // For edge detection
      _stateInternalOld : State := State#UNDEFINED;   // For edge detection
      _booleanInterfaceModeOld : DWord;   // For edge detection
      _booleanInterfaceCmdOld : Word;   // For edge detection
   END_VAR

   VAR_TEMP
      tempBooleanInterfaceMode : DWord;   // Status of boolean Mode inputs
      tempBooleanInterfaceCmd : Word;   // Status of boolean Cmd inputs except abort and stop
   END_VAR

    IF _firstCycle THEN // Initialize values in first cycle
      _instUnitModeStateManager.config := config; // Copy config from input
      _firstCycle := FALSE;

    ELSE // As from second cycle
      //--------------------------------------------------------------------------------------------------
      // Evaluation of input parameters
      //--------------------------------------------------------------------------------------------------
      _instUnitModeStateManager.UnitModeChangeRequest := TRUE; // Change request static TRUE

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
      IF tempBooleanInterfaceMode.%X3 AND NOT _booleanInterfaceModeOld.%X3 THEN
        _instUnitModeStateManager.UnitMode := Mode#MANUAL;
      ELSIF tempBooleanInterfaceMode.%X2 AND NOT _booleanInterfaceModeOld.%X2 THEN
        _instUnitModeStateManager.UnitMode := Mode#MAINTENANCE;
      ELSIF tempBooleanInterfaceMode.%X4 AND NOT _booleanInterfaceModeOld.%X4 THEN
        _instUnitModeStateManager.UnitMode := Mode#USER_01;
      ELSIF tempBooleanInterfaceMode.%X5 AND NOT _booleanInterfaceModeOld.%X5 THEN
        _instUnitModeStateManager.UnitMode := Mode#USER_02;
      ELSIF tempBooleanInterfaceMode.%X6 AND NOT _booleanInterfaceModeOld.%X6 THEN
        _instUnitModeStateManager.UnitMode := Mode#USER_03;
      ELSIF tempBooleanInterfaceMode.%X7 AND NOT _booleanInterfaceModeOld.%X7 THEN
        _instUnitModeStateManager.UnitMode := Mode#USER_04;
      ELSIF tempBooleanInterfaceMode.%X8 AND NOT _booleanInterfaceModeOld.%X8 THEN
        _instUnitModeStateManager.UnitMode := Mode#USER_05;
    // ELSIF tempBooleanInterfaceMode.%X9 AND NOT statBooleanInterfaceModeOld.%X9 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_06;
    // ELSIF tempBooleanInterfaceMode.%X10 AND NOT statBooleanInterfaceModeOld.%X10 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_07;
    // ELSIF tempBooleanInterfaceMode.%X11 AND NOT statBooleanInterfaceModeOld.%X11 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_08;
    // ELSIF tempBooleanInterfaceMode.%X12 AND NOT statBooleanInterfaceModeOld.%X12 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_09;
    // ELSIF tempBooleanInterfaceMode.%X13 AND NOT statBooleanInterfaceModeOld.%X13 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_10;
    // ELSIF tempBooleanInterfaceMode.%X14 AND NOT statBooleanInterfaceModeOld.%X14 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_11;
    // ELSIF tempBooleanInterfaceMode.%X15 AND NOT statBooleanInterfaceModeOld.%X15 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_12;
    // ELSIF tempBooleanInterfaceMode.%X16 AND NOT statBooleanInterfaceModeOld.%X16 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_13;
    // ELSIF tempBooleanInterfaceMode.%X17 AND NOT statBooleanInterfaceModeOld.%X17 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_14;
    // ELSIF tempBooleanInterfaceMode.%X18 AND NOT statBooleanInterfaceModeOld.%X18 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_15;
    // ELSIF tempBooleanInterfaceMode.%X19 AND NOT statBooleanInterfaceModeOld.%X19 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_16;
    // ELSIF tempBooleanInterfaceMode.%X20 AND NOT statBooleanInterfaceModeOld.%X20 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_17;
    // ELSIF tempBooleanInterfaceMode.%X21 AND NOT statBooleanInterfaceModeOld.%X21 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_18;
    // ELSIF tempBooleanInterfaceMode.%X22 AND NOT statBooleanInterfaceModeOld.%X22 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_19;
    // ELSIF tempBooleanInterfaceMode.%X23 AND NOT statBooleanInterfaceModeOld.%X23 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_20;
    // ELSIF tempBooleanInterfaceMode.%X24 AND NOT statBooleanInterfaceModeOld.%X24 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_21;
    // ELSIF tempBooleanInterfaceMode.%X25 AND NOT statBooleanInterfaceModeOld.%X25 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_22;
    // ELSIF tempBooleanInterfaceMode.%X26 AND NOT statBooleanInterfaceModeOld.%X26 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_23;
    // ELSIF tempBooleanInterfaceMode.%X27 AND NOT statBooleanInterfaceModeOld.%X27 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_24;
    // ELSIF tempBooleanInterfaceMode.%X28 AND NOT statBooleanInterfaceModeOld.%X28 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_25;
    // ELSIF tempBooleanInterfaceMode.%X29 AND NOT statBooleanInterfaceModeOld.%X29 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_26;
    // ELSIF tempBooleanInterfaceMode.%X30 AND NOT statBooleanInterfaceModeOld.%X30 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_27;
    // ELSIF tempBooleanInterfaceMode.%X31 AND NOT statBooleanInterfaceModeOld.%X31 THEN
    //   instUnitModeStateManager.UnitMode := Mode#USER_28;
      ELSIF tempBooleanInterfaceMode.%X1 AND NOT _booleanInterfaceModeOld.%X1 THEN
        _instUnitModeStateManager.UnitMode := Mode#PRODUCTION;
      ELSIF tempBooleanInterfaceMode = DWORD#16#0000_0000 THEN // all corresponding boolean request inputs are FALSE
        _instUnitModeStateManager.UnitMode := Mode#INVALID;
      END_IF;

      _booleanInterfaceModeOld := tempBooleanInterfaceMode; // Save values for edge detection

      // State complete signal
      _instUnitModeStateManager.SC := SC;

      // Evaluate CntrlCmd in boolean interface; priority descending: abort, stop, other commands
      _instUnitModeStateManager.CmdChangeRequest := TRUE; // Change request static TRUE

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
      IF tempBooleanInterfaceCmd.%X8 AND NOT _booleanInterfaceCmdOld.%X8 THEN
        _instUnitModeStateManager.CntrlCmd := Command#ABORT;
      ELSIF tempBooleanInterfaceCmd.%X3 AND NOT _booleanInterfaceCmdOld.%X3 THEN
        _instUnitModeStateManager.CntrlCmd := Command#STOP;
      ELSIF tempBooleanInterfaceCmd.%X10 AND NOT _booleanInterfaceCmdOld.%X10 THEN
        _instUnitModeStateManager.CntrlCmd := Command#COMPLETE;
      ELSIF tempBooleanInterfaceCmd.%X1 AND NOT _booleanInterfaceCmdOld.%X1 THEN
        _instUnitModeStateManager.CntrlCmd := Command#RESET;
      ELSIF tempBooleanInterfaceCmd.%X2 AND NOT _booleanInterfaceCmdOld.%X2 THEN
        _instUnitModeStateManager.CntrlCmd := Command#START;
      ELSIF tempBooleanInterfaceCmd.%X4 AND NOT _booleanInterfaceCmdOld.%X4 THEN
        _instUnitModeStateManager.CntrlCmd := Command#HOLD;
      ELSIF tempBooleanInterfaceCmd.%X5 AND NOT _booleanInterfaceCmdOld.%X5 THEN
        _instUnitModeStateManager.CntrlCmd := Command#UNHOLD;
      ELSIF tempBooleanInterfaceCmd.%X6 AND NOT _booleanInterfaceCmdOld.%X6 THEN
        _instUnitModeStateManager.CntrlCmd := Command#SUSPEND;
      ELSIF tempBooleanInterfaceCmd.%X7 AND NOT _booleanInterfaceCmdOld.%X7 THEN
        _instUnitModeStateManager.CntrlCmd := Command#UNSUSPEND;
      ELSIF tempBooleanInterfaceCmd.%X9 AND NOT _booleanInterfaceCmdOld.%X9 THEN
        _instUnitModeStateManager.CntrlCmd := Command#CLEAR;
      ELSIF tempBooleanInterfaceCmd = DWORD#16#0000_0000 THEN // all corresponding boolean request inputs are FALSE
        _instUnitModeStateManager.CntrlCmd := Command#UNDEFINED;
      END_IF;

      _booleanInterfaceCmdOld := tempBooleanInterfaceCmd; // Save values for edge detection
    END_IF;

    //--------------------------------------------------------------------------------------------------
    // Call unit mode state manager
    //--------------------------------------------------------------------------------------------------
    _instUnitModeStateManager();

    //--------------------------------------------------------------------------------------------------
    // Write outputs including boolean interface outputs
    //--------------------------------------------------------------------------------------------------
    UnitModeCurrent := _instUnitModeStateManager.UnitModeCurrent;
    StateCurrent    := _instUnitModeStateManager.StateCurrent;

    IF _instUnitModeStateManager.UnitModeCurrent <> _unitModeCurrentInternalOld THEN // Check if new unit mode is selected
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

      CASE _instUnitModeStateManager.UnitModeCurrent OF // Set new bit for current unit mode
        Mode#PRODUCTION:
          ProductionModeActive := TRUE;
        Mode#MAINTENANCE:
          MaintenanceModeActive := TRUE;
        Mode#MANUAL:
          ManualModeActive := TRUE;
        Mode#USER_01:
          UserMode01Active := TRUE;
        Mode#USER_02:
          UserMode02Active := TRUE;
        Mode#USER_03:
          UserMode03Active := TRUE;
        Mode#USER_04:
          UserMode04Active := TRUE;
        Mode#USER_05:
          UserMode05Active := TRUE;
        // Mode#USER_06:
        //   UserMode06Active := TRUE;
        // Mode#USER_07:
        //   UserMode07Active := TRUE;
        // Mode#USER_08:
        //   UserMode08Active := TRUE;
        // Mode#USER_09:
        //   UserMode09Active := TRUE;
        // Mode#USER_10:
        //   UserMode10Active := TRUE;
        // Mode#USER_11:
        //   UserMode11Active := TRUE;
        // Mode#USER_12:
        //   UserMode12Active := TRUE;
        // Mode#USER_13:
        //   UserMode13Active := TRUE;
        // Mode#USER_14:
        //   UserMode14Active := TRUE;
        // Mode#USER_15:
        //   UserMode15Active := TRUE;
        // Mode#USER_16:
        //   UserMode16Active := TRUE;
        // Mode#USER_17:
        //   UserMode17Active := TRUE;
        // Mode#USER_18:
        //   UserMode18Active := TRUE;
        // Mode#USER_19:
        //   UserMode19Active := TRUE;
        // Mode#USER_20:
        //   UserMode20Active := TRUE;
        // Mode#USER_21:
        //   UserMode21Active := TRUE;
        // Mode#USER_22:
        //   UserMode22Active := TRUE;
        // Mode#USER_23:
        //   UserMode23Active := TRUE;
        // Mode#USER_24:
        //   UserMode24Active := TRUE;
        // Mode#USER_25:
        //   UserMode25Active := TRUE;
        // Mode#USER_26:
        //   UserMode26Active := TRUE;
        // Mode#USER_27:
        //   UserMode27Active := TRUE;
        // Mode#USER_28:
        //   UserMode28Active := TRUE;
        ELSE
          ; // No bit is set
      END_CASE;

      _unitModeCurrentInternalOld := _instUnitModeStateManager.UnitModeCurrent;
    END_IF;

    IF _instUnitModeStateManager.StateCurrent <> _stateInternalOld THEN // Check if new state is selected
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
      CASE _instUnitModeStateManager.StateCurrent OF
        State#CLEARING:
          ClearingStateActive := TRUE;
        State#STOPPED:
          StoppedStateActive := TRUE;
        State#STARTING:
          StartingStateActive := TRUE;
        State#IDLE:
          IdleStateActive := TRUE;
        State#SUSPENDED:
          SuspendedStateActive := TRUE;
        State#EXECUTE:
          ExecuteStateActive := TRUE;
        State#STOPPING:
          StoppingStateActive := TRUE;
        State#ABORTING:
          AbortingStateActive := TRUE;
        State#ABORTED:
          AbortedStateActive := TRUE;
        State#HOLDING:
          HoldingStateActive := TRUE;
        State#HELD:
          HeldStateActive := TRUE;
        State#UNHOLDING:
          UnholdingStateActive := TRUE;
        State#SUSPENDING:
          SuspendingStateActive := TRUE;
        State#UNSUSPENDING:
          UnsuspendingStateActive := TRUE;
        State#RESETTING:
          ResettingStateActive := TRUE;
        State#COMPLETING:
          CompletingStateActive := TRUE;
        State#COMPLETED:
          CompletedStateActive := TRUE;
        ELSE
          ;
      END_CASE; // End: Set new state

      _stateInternalOld := _instUnitModeStateManager.StateCurrent;
    END_IF;// End: Write boolean interface outputs

    unitModeChangeNotAllowed := _instUnitModeStateManager.unitModeChangeNotAllowed;
    cntrlCmdNotAllowed       := _instUnitModeStateManager.cntrlCmdNotAllowed;
END_FUNCTION_BLOCK
END_NAMESPACE
