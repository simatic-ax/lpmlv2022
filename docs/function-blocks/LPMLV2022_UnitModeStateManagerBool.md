# UnitModeStateManagerBool

## Principle of operation

The function block `UnitModeStateManagerBool` is a wrapping function block with a boolean interface. The `UnitModeStateManager` function block is called internally.

> NOTE
>
> The number of user-defined unit modes can be extended (up to 28). Therefore, the corresponding inputs and outputs have to be added at the `UnitModeStateManagerBool` block. Also the prepared corresponding lines of code within the source code of this block must be uncommented. No modifications are necessary to be made at the `UnitModeStateManager` block. Typically, the value of the constant `LimitConstants#MODES_UPPER_LIM` must be extended (relevant for example for the block `UnitModeStateTimes`).
>
> These adaptations need to be performed before compiling the library / application. Therefore, the user needs to import the source code library into their project and perform the alterations there.

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

See [UnitModeStateManager](LPMLV2022_UnitModeStateManager.md).
