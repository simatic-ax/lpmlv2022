# LPMLV2022_ConfigureHoldCmdCfg

## Principle of operation

This function allows the user to set the Hold control command configuration for all unit modes of the `LPMLV2022_UnitModeStateManager` easily (one configuration for all modes). The output of this function can directly be assigned to the `LPMLV2022_UnitModeStateManager` configuration `holdCmdCfg`. The bit locations within the `holdCmdCfg` DWord represent state numbers. A set bit means, that the Hold command is taken into account by the `LPMLV2022_UnitModeStateManager` in the corresponding state.

With the function, the user has to set the associated inputs for the different states to "TRUE", e.g. "Execute := TRUE" for enabling the Hold control command to be taken into account in state Execute.

To write the Hold control command configuration from the function output to the according "Unit Mode and State Manager", the output `holdCmdCfg` has to be assigned to the configuration of the corresponding `LPMLV2022_UnitModeStateManager`.

> NOTE
>
> This function is only needed, if another configuration than the default configuration of the `holdCmdCfg` of the `LPMLV2022_UnitModeStateManager` shall be used (default: 16#0000_0060, i.e. only the bits for the states Suspended and Execute are set to comply with ANSI/ISA-TR88.00.02-2022).
>

## Interface

### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| Starting | `BOOL` | TRUE: The Hold control command is taken into account in state Starting |
| Idle | `BOOL` | TRUE: The Hold control command is taken into account in state Idle |
| Suspended | `BOOL` | TRUE: The Hold control command is taken into account in state Suspended |
| Execute | `BOOL` | TRUE: The Hold control command is taken into account in state Execute |
| Unholding | `BOOL` | TRUE: The Hold control command is taken into account in state Unholding |
| Suspending | `BOOL` | TRUE: The Hold control command is taken into account in state Suspending |
| Unsuspending | `BOOL` | TRUE: The Hold control command is taken into account in state Unsuspending |
| Completing | `BOOL` | TRUE: The Hold control command is taken into account in state Completing |
| Completed | `BOOL` | TRUE: The Hold control command is taken into account in state Completed |

### Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `holdCmdCfg` | `DWord` | Hold control command configuration for all unit modes (one config. for all modes) for direct connection with the input `config.holdCmdCfg` of the desired `LPMLV2022_UnitModeStateManager` instance. Bit locations within the DWORD value represent State numbers |
