# LPMLV2022_ConfigureEnabledModesCfg

## Principle of operation

This function allows the user to set the unit mode configuration for `LPMLV2022_UnitModeStateManager` and the `LPMLV2022_UnitModeStateManagerBool` easily. Of course, it is also possible to set the unit mode configuration directly in the `LPMLV2022_UnitModeStateManager` configuration.

With the function, the user has to set the associated inputs for the different unit modes to “TRUE”, e.g. “MaintenanceMode := TRUE” for enabling the unit mode Maintenance.
To write the unit mode configuration from the function output to the according “Unit Mode and State Manager”, the output `EnabledModesCfg` has to be assigned to the configuration of the corresponding `LPMLV2022_UnitModeStateManager`.

> NOTE
>
> The unit mode `Manual` is mandatory and is therefore always enabled, i.e. no input exists at the `LPMLV2022_ConfigureEnabledModesCfg` for mode `Manual`. If the mode `Manual` is nevertheless disabled at the “Unit Mode and State Manager”, it will automatically be enabled.
>

## Interface

### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| ProductionMode | `BOOL` |  TRUE: Enable unit mode Production |
| MaintenanceMode | `BOOL` |  TRUE: Enable unit mode Maintenance |
| UserMode01 | `BOOL` |  TRUE: Enable user-defined unit mode 01 |
| UserMode02 | `BOOL` |  TRUE: Enable user-defined unit mode 02 |
| UserMode03 | `BOOL` |  TRUE: Enable user-defined unit mode 03 |
| UserMode04 | `BOOL` |  TRUE: Enable user-defined unit mode 04 |
| UserMode05 | `BOOL` |  TRUE: Enable user-defined unit mode 05 |
| UserMode06 | `BOOL` |  TRUE: Enable user-defined unit mode 06 |
| UserMode07 | `BOOL` |  TRUE: Enable user-defined unit mode 07 |
| UserMode08 | `BOOL` |  TRUE: Enable user-defined unit mode 08 |
| UserMode09 | `BOOL` |  TRUE: Enable user-defined unit mode 09 |
| UserMode10 | `BOOL` |  TRUE: Enable user-defined unit mode 10 |
| UserMode11 | `BOOL` |  TRUE: Enable user-defined unit mode 11 |
| UserMode12 | `BOOL` |  TRUE: Enable user-defined unit mode 12 |
| UserMode13 | `BOOL` |  TRUE: Enable user-defined unit mode 13 |
| UserMode14 | `BOOL` |  TRUE: Enable user-defined unit mode 14 |
| UserMode15 | `BOOL` |  TRUE: Enable user-defined unit mode 15 |
| UserMode16 | `BOOL` |  TRUE: Enable user-defined unit mode 16 |
| UserMode17 | `BOOL` |  TRUE: Enable user-defined unit mode 17 |
| UserMode18 | `BOOL` |  TRUE: Enable user-defined unit mode 18 |
| UserMode19 | `BOOL` |  TRUE: Enable user-defined unit mode 19 |
| UserMode20 | `BOOL` |  TRUE: Enable user-defined unit mode 20 |
| UserMode21 | `BOOL` |  TRUE: Enable user-defined unit mode 21 |
| UserMode22 | `BOOL` |  TRUE: Enable user-defined unit mode 22 |
| UserMode23 | `BOOL` |  TRUE: Enable user-defined unit mode 23 |
| UserMode24 | `BOOL` |  TRUE: Enable user-defined unit mode 24 |
| UserMode25 | `BOOL` |  TRUE: Enable user-defined unit mode 25 |
| UserMode26 | `BOOL` |  TRUE: Enable user-defined unit mode 26 |
| UserMode27 | `BOOL` |  TRUE: Enable user-defined unit mode 27 |
| UserMode28 | `BOOL` |  TRUE: Enable user-defined unit mode 28 |

### Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `EnabledModesCfg` | `DWord` | Enabled unit modes configuration for direct connection with the input `config.EnabledModesCfg` of the desired `LPMLV2022_UnitModeStateManager` instance |
