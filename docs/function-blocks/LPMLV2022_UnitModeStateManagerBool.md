# LPMLV2022_UnitModeStateManagerBool

## Principle of operation

The function block `LPMLV2022_UnitModeStateManagerBool` is a wrapping function block with a boolean interface. The `LPMLV2022_UnitModeStateManager` function block is called internally.

> NOTE
>
> The number of user-defined unit modes can be extended (up to 28). Therefore, the corresponding inputs and outputs have to be added at the `LPMLV2022_UnitModeStateManagerBool` block. Also the prepared corresponding lines of code within the source code of this block must be uncommented. No modifications are necessary to be made at the `LPMLV2022_UnitModeStateManager` block. Typically, the value of the constant `LPMLV2022_LimitConstants#MODES_UPPER_LIM` must be extended (relevant for example for the block `LPMLV2022_UnitModeStateTimes`).
>
> These adaptations need to be performed before compiling the library / application. Therefore, the user needs to import the source code library into their project and perform the alterations there.

## Interface

### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| ProductionModeRequest | Bool |  Rising edge: Request change to unit mode Production |
| MaintenanceModeRequest | Bool |  Rising edge: Request change to unit mode Maintenance |
| ManualModeRequest | Bool |  Rising edge: Request change to unit mode Manual |
| UserMode01Request | Bool |  Rising edge: Request change to user-defined unit mode 01 |
| UserMode02Request | Bool |  Rising edge: Request change to user-defined unit mode 02 |
| UserMode03Request | Bool |  Rising edge: Request change to user-defined unit mode 03 |
| UserMode04Request | Bool |  Rising edge: Request change to user-defined unit mode 04 |
| UserMode05Request | Bool |  Rising edge: Request change to user-defined unit mode 05 |
| ResetCmdRequest | Bool |  Rising edge: Request control command Reset |
| StartCmdRequest | Bool |  Rising edge: Request control command Start |
| StopCmdRequest | Bool |  Rising edge: Request control command Stop |
| HoldCmdRequest | Bool |  Rising edge: Request control command Hold |
| UnholdCmdRequest | Bool |  Rising edge: Request control command Unhold |
| SuspendCmdRequest | Bool |  Rising edge: Request control command Suspend |
| UnsuspendCmdRequest | Bool |  Rising edge: Request control command Unsuspend |
| AbortCmdRequest | Bool |  Rising edge: Request control command Abort |
| ClearCmdRequest | Bool |  Rising edge: Request control command Clear |
| CompleteCmdRequest | Bool |  Rising edge: Request control command Complete |
| SC | Bool |  State change from FALSE to TRUE (rising edge) triggers state complete signal |
| config | `LPMLV2022_typeConfiguration` |  FB config (is taken into account in first call after STOP/RUN) |

### Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| UnitModeCurrent |  DInt | Current unit mode |
| StateCurrent |  DInt | Current state |
| ProductionModeActive |  Bool | TRUE: Unit mode Production is currently active |
| MaintenanceModeActive |  Bool | TRUE: Unit mode Maintenance is currently active |
| ManualModeActive |  Bool | TRUE: Unit mode Manual is currently active |
| UserMode01Active |  Bool | TRUE: User-defined unit mode 01 is currently active |
| UserMode02Active |  Bool | TRUE: User-defined unit mode 02 is currently active |
| UserMode03Active |  Bool | TRUE: User-defined unit mode 03 is currently active |
| UserMode04Active |  Bool | TRUE: User-defined unit mode 04 is currently active |
| UserMode05Active |  Bool | TRUE: User-defined unit mode 05 is currently active |
| ClearingStateActive |  Bool | TRUE: State Clearing is currently active |
| StoppedStateActive |  Bool | TRUE: State Stopped is currently active |
| StartingStateActive |  Bool | TRUE: State Starting is currently active |
| IdleStateActive |  Bool | TRUE: State Idle is currently active |
| SuspendedStateActive |  Bool | TRUE: State Suspended is currently active |
| ExecuteStateActive |  Bool | TRUE: State Execute is currently active |
| StoppingStateActive |  Bool | TRUE: State Stopping is currently active |
| AbortingStateActive |  Bool | TRUE: State Aborting is currently active |
| AbortedStateActive |  Bool | TRUE: State Aborted is currently active |
| HoldingStateActive |  Bool | TRUE: State Holding is currently active |
| HeldStateActive |  Bool | TRUE: State Held is currently active |
| UnholdingStateActive |  Bool | TRUE: State Unholding is currently active |
| SuspendingStateActive |  Bool | TRUE: State Suspending is currently active |
| UnsuspendingStateActive |  Bool | TRUE: State Unsuspending is currently active |
| ResettingStateActive |  Bool | TRUE: State Resetting is currently active |
| CompletingStateActive |  Bool | TRUE: State Completing is currently active |
| CompletedStateActive |  Bool | TRUE: State Completed is currently active |
| unitModeChangeNotAllowed |  Bool | TRUE: Requested unit mode change is not allowed (output is reset with the next successful unit mode change or if all corresponding request inputs are set to FALSE) |
| cntrlCmdNotAllowed |  Bool | TRUE: Control command is not allowed (output is reset with the next successful control command or if all corresponding request inputs are set to FALSE) |

### Status and error codes

See [LPMLV2022_UnitModeStateManager](LPMLV2022_UnitModeStateManager.md).
