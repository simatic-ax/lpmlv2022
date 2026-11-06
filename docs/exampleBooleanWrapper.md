# Example - Boolean wrapper for the UnitModeStateManager

## Principle of operation

The function block `UnitModeStateManagerBool` is a wrapping function block with a boolean interface. The `UnitModeStateManager` function block is called internally.

> NOTE
>
> This block is not part of the library. Copy the [source code](#source-code) below into your own project and adapt it to the needs of your machine. It only uses the public interface of `UnitModeStateManager`.
>
> The example provides request and active signals for the modes Production, Maintenance, Manual and the user-defined modes 01 to 05. The `UnitModeStateManager` itself supports up to 28 user-defined modes. To support more, add the corresponding inputs and outputs and extend the marked sections in the code (mode collection, mode selection and the `CASE` for the active mode flags).
>
> The mode and command priorities in case of multiple simultaneous requests are defined in the code and can be changed there.

## Interface

### Input Parameters

| Parameter | Type | Description |
| ---------- | ----- | ------------ |
| ProductionModeRequest | BOOL | Rising edge: Request change to unit mode Production |
| MaintenanceModeRequest | BOOL | Rising edge: Request change to unit mode Maintenance |
| ManualModeRequest | BOOL | Rising edge: Request change to unit mode Manual |
| UserMode01Request | BOOL | Rising edge: Request change to user-defined unit mode 01 |
| UserMode02Request | BOOL | Rising edge: Request change to user-defined unit mode 02 |
| UserMode03Request | BOOL | Rising edge: Request change to user-defined unit mode 03 |
| UserMode04Request | BOOL | Rising edge: Request change to user-defined unit mode 04 |
| UserMode05Request | BOOL | Rising edge: Request change to user-defined unit mode 05 |
| ResetCmdRequest | BOOL | Rising edge: Request control command Reset |
| StartCmdRequest | BOOL | Rising edge: Request control command Start |
| StopCmdRequest | BOOL | Rising edge: Request control command Stop |
| HoldCmdRequest | BOOL | Rising edge: Request control command Hold |
| UnholdCmdRequest | BOOL | Rising edge: Request control command Unhold |
| SuspendCmdRequest | BOOL | Rising edge: Request control command Suspend |
| UnsuspendCmdRequest | BOOL | Rising edge: Request control command Unsuspend |
| AbortCmdRequest | BOOL | Rising edge: Request control command Abort |
| ClearCmdRequest | BOOL | Rising edge: Request control command Clear |
| CompleteCmdRequest | BOOL | Rising edge: Request control command Complete |
| SC | BOOL | State change from FALSE to TRUE (rising edge) triggers state complete signal |
| config | `typeConfiguration` | FB config (is taken into account in first call after STOP/RUN) |

### Output Parameters

| Parameter | Type | Description |
| ---------- | ----- | ------------ |
| UnitModeCurrent | Mode | Current unit mode |
| StateCurrent | State | Current state |
| ProductionModeActive | BOOL | TRUE: Unit mode Production is currently active |
| MaintenanceModeActive | BOOL | TRUE: Unit mode Maintenance is currently active |
| ManualModeActive | BOOL | TRUE: Unit mode Manual is currently active |
| UserMode01Active | BOOL | TRUE: User-defined unit mode 01 is currently active |
| UserMode02Active | BOOL | TRUE: User-defined unit mode 02 is currently active |
| UserMode03Active | BOOL | TRUE: User-defined unit mode 03 is currently active |
| UserMode04Active | BOOL | TRUE: User-defined unit mode 04 is currently active |
| UserMode05Active | BOOL | TRUE: User-defined unit mode 05 is currently active |
| ClearingStateActive | BOOL | TRUE: State Clearing is currently active |
| StoppedStateActive | BOOL | TRUE: State Stopped is currently active |
| StartingStateActive | BOOL | TRUE: State Starting is currently active |
| IdleStateActive | BOOL | TRUE: State Idle is currently active |
| SuspendedStateActive | BOOL | TRUE: State Suspended is currently active |
| ExecuteStateActive | BOOL | TRUE: State Execute is currently active |
| StoppingStateActive | BOOL | TRUE: State Stopping is currently active |
| AbortingStateActive | BOOL | TRUE: State Aborting is currently active |
| AbortedStateActive | BOOL | TRUE: State Aborted is currently active |
| HoldingStateActive | BOOL | TRUE: State Holding is currently active |
| HeldStateActive | BOOL | TRUE: State Held is currently active |
| UnholdingStateActive | BOOL | TRUE: State Unholding is currently active |
| SuspendingStateActive | BOOL | TRUE: State Suspending is currently active |
| UnsuspendingStateActive | BOOL | TRUE: State Unsuspending is currently active |
| ResettingStateActive | BOOL | TRUE: State Resetting is currently active |
| CompletingStateActive | BOOL | TRUE: State Completing is currently active |
| CompletedStateActive | BOOL | TRUE: State Completed is currently active |
| unitModeChangeNotAllowed | BOOL | TRUE: Requested unit mode change is not allowed (output is reset with the next successful unit mode change or if all corresponding request inputs are set to FALSE) |
| cntrlCmdNotAllowed | BOOL | TRUE: Control command is not allowed (output is reset with the next successful control command or if all corresponding request inputs are set to FALSE) |

### Status and error codes

See [UnitModeStateManager](./function-blocks/UnitModeStateManager.md).

## Source code

<details>
<summary>UnitModeStateManagerBool</summary>

```iecst
USING Simatic.Ax.LPMLV2022;

FUNCTION_BLOCK UnitModeStateManagerBool
    VAR_INPUT
        ProductionModeRequest : Bool;
        MaintenanceModeRequest : Bool;
        ManualModeRequest : Bool;
        UserMode01Request : Bool;
        UserMode02Request : Bool;
        UserMode03Request : Bool;
        UserMode04Request : Bool;
        UserMode05Request : Bool;
        // EXTEND: add UserMode06Request .. UserMode28Request here
        ResetCmdRequest : Bool;
        StartCmdRequest : Bool;
        StopCmdRequest : Bool;
        HoldCmdRequest : Bool;
        UnholdCmdRequest : Bool;
        SuspendCmdRequest : Bool;
        UnsuspendCmdRequest : Bool;
        AbortCmdRequest : Bool;
        ClearCmdRequest : Bool;
        CompleteCmdRequest : Bool;
        SC : Bool;
        config : typeConfiguration := (
            DisabledStatesCfg := [32(DWORD#16#0)],
            ModeTransitionCfg := [DWORD#0, 31(DWORD#16#00000214)]);
    END_VAR

    VAR_OUTPUT
        UnitModeCurrent : Mode := Mode#INVALID;
        StateCurrent : State := State#UNDEFINED;
        ProductionModeActive : Bool;
        MaintenanceModeActive : Bool;
        ManualModeActive : Bool;
        UserMode01Active : Bool;
        UserMode02Active : Bool;
        UserMode03Active : Bool;
        UserMode04Active : Bool;
        UserMode05Active : Bool;
        // EXTEND: add UserMode06Active .. UserMode28Active here
        ClearingStateActive : Bool;
        StoppedStateActive : Bool;
        StartingStateActive : Bool;
        IdleStateActive : Bool;
        SuspendedStateActive : Bool;
        ExecuteStateActive : Bool;
        StoppingStateActive : Bool;
        AbortingStateActive : Bool;
        AbortedStateActive : Bool;
        HoldingStateActive : Bool;
        HeldStateActive : Bool;
        UnholdingStateActive : Bool;
        SuspendingStateActive : Bool;
        UnsuspendingStateActive : Bool;
        ResettingStateActive : Bool;
        CompletingStateActive : Bool;
        CompletedStateActive : Bool;
        unitModeChangeNotAllowed : Bool;
        cntrlCmdNotAllowed : Bool;
    END_VAR

    VAR
        _instUnitModeStateManager : UnitModeStateManager;
        _firstCycle : Bool := TRUE;
        _unitModeCurrentInternalOld : Mode := Mode#INVALID;
        _stateInternalOld : State := State#UNDEFINED;
        _booleanInterfaceModeOld : DWord;
        _booleanInterfaceCmdOld : Word;
    END_VAR

    VAR_TEMP
        tempBooleanInterfaceMode : DWord;
        tempBooleanInterfaceCmd : Word;
    END_VAR

    IF _firstCycle THEN
        _instUnitModeStateManager.config := config;
        _firstCycle := FALSE;

    ELSE
        //--------------------------------------------------------------------------------------------------
        // Evaluation of input parameters
        //--------------------------------------------------------------------------------------------------
        _instUnitModeStateManager.UnitModeChangeRequest := TRUE;

        // Collect unit mode from boolean inputs (bit number = Mode value)
        tempBooleanInterfaceMode.%X1 := ProductionModeRequest;
        tempBooleanInterfaceMode.%X2 := MaintenanceModeRequest;
        tempBooleanInterfaceMode.%X3 := ManualModeRequest;
        tempBooleanInterfaceMode.%X4 := UserMode01Request;
        tempBooleanInterfaceMode.%X5 := UserMode02Request;
        tempBooleanInterfaceMode.%X6 := UserMode03Request;
        tempBooleanInterfaceMode.%X7 := UserMode04Request;
        tempBooleanInterfaceMode.%X8 := UserMode05Request;
        // EXTEND: tempBooleanInterfaceMode.%X9 := UserMode06Request; ... %X31 := UserMode28Request;

        // Rising edge selects the mode. Priority: Manual, Maintenance, User 01..28, Production
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
        // EXTEND: ELSIF tempBooleanInterfaceMode.%X9 AND NOT _booleanInterfaceModeOld.%X9 THEN
        //             _instUnitModeStateManager.UnitMode := Mode#USER_06; ... up to %X31 / Mode#USER_28
        ELSIF tempBooleanInterfaceMode.%X1 AND NOT _booleanInterfaceModeOld.%X1 THEN
            _instUnitModeStateManager.UnitMode := Mode#PRODUCTION;
        ELSIF tempBooleanInterfaceMode = DWORD#16#0000_0000 THEN
            _instUnitModeStateManager.UnitMode := Mode#INVALID;
        END_IF;

        _booleanInterfaceModeOld := tempBooleanInterfaceMode;

        _instUnitModeStateManager.SC := SC;

        _instUnitModeStateManager.CmdChangeRequest := TRUE;

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

        // Rising edge selects the command. Priority: abort, stop, complete, reset, start, hold, unhold, suspend, unsuspend, clear
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
        ELSIF tempBooleanInterfaceCmd = WORD#16#0000 THEN
            _instUnitModeStateManager.CntrlCmd := Command#UNDEFINED;
        END_IF;

        _booleanInterfaceCmdOld := tempBooleanInterfaceCmd;
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

    IF _instUnitModeStateManager.UnitModeCurrent <> _unitModeCurrentInternalOld THEN
        ProductionModeActive := FALSE;
        MaintenanceModeActive := FALSE;
        ManualModeActive := FALSE;
        UserMode01Active := FALSE;
        UserMode02Active := FALSE;
        UserMode03Active := FALSE;
        UserMode04Active := FALSE;
        UserMode05Active := FALSE;
        // EXTEND: reset UserMode06Active .. UserMode28Active

        CASE _instUnitModeStateManager.UnitModeCurrent OF
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
            // EXTEND: Mode#USER_06: UserMode06Active := TRUE; ... Mode#USER_28
            ELSE
                ;
        END_CASE;

        _unitModeCurrentInternalOld := _instUnitModeStateManager.UnitModeCurrent;
    END_IF;

    IF _instUnitModeStateManager.StateCurrent <> _stateInternalOld THEN
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
        END_CASE;

        _stateInternalOld := _instUnitModeStateManager.StateCurrent;
    END_IF;

    unitModeChangeNotAllowed := _instUnitModeStateManager.unitModeChangeNotAllowed;
    cntrlCmdNotAllowed       := _instUnitModeStateManager.cntrlCmdNotAllowed;
END_FUNCTION_BLOCK
```
</details>
