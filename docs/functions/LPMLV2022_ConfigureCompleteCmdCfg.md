# LPMLV2022_ConfigureCompleteCmdCfg

## Principle of operation

This function allows the user to set the Complete control command configuration for all unit modes of the `LPMLV2022_UnitModeStateManager` and the `LPMLV2022_UnitModeStateManagerBool` easily (one configuration for all modes). The output of this function can directly be assigned to the `LPMLV2022_UnitModeStateManager` configuration `completeCmdCfg`. The bit locations within the `completeCmdCfg` DWord represent state numbers. A set bit means, that the Complete command is taken into account by the `LPMLV2022_UnitModeStateManager` in the corresponding state.

With the function, the user has to set the associated inputs for the different states to "TRUE", e.g. "Execute := TRUE" for enabling the Complete control command to be taken into account in state Execute.

To write the Complete control command configuration from the function output to the according "Unit Mode and State Manager", the output `completeCmdCfg` has to be assigned to the configuration of the corresponding `LPMLV2022_UnitModeStateManager`.

> NOTE
>
> This function is only needed, if another configuration than the default configuration of the `completeCmdCfg` of the `LPMLV2022_UnitModeStateManager` shall be used (default: 16#0000_0860, i.e. the bits for the states Suspended, Execute and Held are set to comply with ANSI/ISA-TR88.00.02-2022).
>

## Interface

### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| Suspended | `BOOL` | TRUE: The Complete control command is taken into account in state Suspended |
| Execute | `BOOL` | TRUE: The Complete control command is taken into account in state Execute |
| Held | `BOOL` | TRUE: The Complete control command is taken into account in state Held |

### Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `completeCmdCfg` | `DWord` | Complete control command configuration for all unit modes (one config. for all modes) for direct connection with the input `config.completeCmdCfg` of the desired `LPMLV2022_UnitModeStateManager` instance. Bit locations within the DWORD value represent State numbers |
