# LPMLV2022_ConfigureModeTransitionCfg

## Principle of operation

This function allows the user to set the Mode Transition Configuration for one unit mode of the `LPMLV2022_UnitModeStateManager` and the `LPMLV2022_UnitModeStateManagerBool` easily. The output of this function can directly be assigned to the `LPMLV2022_UnitModeStateManager` configuration `ModeTransitionCfg[<unit mode>]`. The bit locations within the `ModeTransitionCfg` DWord represent state numbers. A set bit means, that a mode transition to or from the corresponding state is allowed.
Note, that the corresponding state bit must be set for both the current mode and the requested mode.

> NOTE
>
> This function is only needed, if another configuration than the default configuration of the `completeCmdCfg` of the `LPMLV2022_UnitModeStateManager` shall be used (default: 16#0000_0860, i.e. the bits for the states Suspended, Execute and Held are set to comply with ANSI/ISA-TR88.00.02-2022).
>

## Interface

### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| Clearing | `BOOL` | TRUE: Allow a mode transition to/from state Clearing |
| Stopped | `BOOL` | TRUE: Allow a mode transition to/from state Stopped |
| Starting | `BOOL` | TRUE: Allow a mode transition to/from state Starting |
| Idle | `BOOL` | TRUE: Allow a mode transition to/from state Idle |
| Suspended | `BOOL` | TRUE: Allow a mode transition to/from state Suspended |
| Execute | `BOOL` | TRUE: Allow a mode transition to/from state Execute |
| Stopping | `BOOL` | TRUE: Allow a mode transition to/from state Stopping |
| Aborting | `BOOL` | TRUE: Allow a mode transition to/from state Aborting |
| Aborted | `BOOL` | TRUE: Allow a mode transition to/from state Aborted |
| Holding | `BOOL` | TRUE: Allow a mode transition to/from state Holding |
| Held | `BOOL` | TRUE: Allow a mode transition to/from state Held |
| Unholding | `BOOL` | TRUE: Allow a mode transition to/from state Unholding |
| Suspending | `BOOL` | TRUE: Allow a mode transition to/from state Suspending |
| Unsuspending | `BOOL` | TRUE: Allow a mode transition to/from state Unsuspending |
| Resetting | `BOOL` | TRUE: Allow a mode transition to/from state Resetting |
| Completing | `BOOL` | TRUE: Allow a mode transition to/from state Completing |
| Completed | `BOOL` | TRUE: Allow a mode transition to/from state Completed |

### Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ModeTransitionCfg` | `DWORD` | Mode Transition Configuration for one unit mode for direct connection with the input `config.ModeTransitionCfg[<unit mode>]` of the desired instance of the `LPMLV2022_UnitModeStateManager`. Bit locations within the DWORD value represent State numbers |
