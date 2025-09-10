# LPMLV2022_ConfigureDisabledStatesCfg

## Principle of operation

This function allows the user to set the state configuration for every unit mode in the `LPMLV2022_UnitModeStateManager` and the `LPMLV2022_UnitModeStateManagerBool` easily. Of course, it is also possible to set the state configurations directly in the `LPMLV2022_UnitModeStateManager` configuration.

With the function, the user has to set the associated inputs for the different states to "TRUE", e.g. "Held := TRUE" for disabling the state Held.

The function generates a DWord value which represents the state configuration for one unit mode. This value is bit coded and means that every bit represents a switch where states can be disabled or enabled for a unit mode, e.g. disabling the state _Held_ the bit number 11 has to be set to _TRUE_. As can be seen in the example the state numbers according to the OMAC standard also define the bit numbers in the DWord value. (TODO: LinkToTable)

To write the state configuration from the function output to the according "Unit Mode and State Manager", the output `DisabledStatesCfg` has to be connected to the configuration of the corresponding `LPMLV2022_UnitModeStateManager`.

> NOTE
>
> According to the OMAC standard some states are mandatory (Stopped, Idle, Execute and Aborted) and cannot be disabled. If they are nevertheless disabled, the "Unit Mode and State Manager" will enable these states automatically and provide the corrected configuration as a DWord value at output `CurDisabledStates`.
>

## Interface

### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| Clearing | `BOOL` | TRUE: Disable state Clearing |
| Starting | `BOOL` | TRUE: Disable state Starting |
| Suspended | `BOOL` | TRUE: Disable state Suspended |
| Stopping | `BOOL` | TRUE: Disable state Stopping |
| Aborting | `BOOL` | TRUE: Disable state Aborting |
| Holding | `BOOL` | TRUE: Disable state Holding |
| Held | `BOOL` | TRUE: Disable state Held |
| Unholding | `BOOL` | TRUE: Disable state Unholding |
| Suspending | `BOOL` | TRUE: Disable state Suspending |
| Unsuspending | `BOOL` | TRUE: Disable state Unsuspending |
| Resetting | `BOOL` | TRUE: Disable state Resetting |
| Completing | `BOOL` | TRUE: Disable state Completing |
| Completed | `BOOL` | TRUE: Disable state Completed |

### Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `DisabledStatesCfg` | `DWord` | Disabled states configuration for one unit mode for direct connection with the input `config.DisabledStatesCfg[<unit mode>]` of the desired `LPMLV2022_UnitModeStateManager` instance. Bit locations within the DWORD value represent State numbers |
