# typeConfiguration

## Description

Configuration structure for the LPMLV2022 Unit Mode State Manager. This type contains all configuration parameters needed to set up the behavior of the state machine, including enabled modes, disabled states, mode transitions, and command configurations.

## Structure

| Field | Type | Description |
| ------- | ------ | ------------- |
| `EnabledModesCfg` | `DWORD` | Bit locations within the DWORD represent Mode numbers. A value of 1 in a bit location [0-31] indicates that the corresponding Mode number is enabled. Mode 0 is an Invalid Mode, therefore bit 0 is unused<br>**(default: 16#0000_01FE)**<br>Note: 16#0000_01FE → Production, Maintenance, Manual, UserMode01..05 |
| `DisabledStatesCfg` | `ARRAY[0..MAX_MODES_UPPER_LIM] of DWORD` | The array index represents the Mode number. Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that the corresponding state number is disabled. State 0 is an Undefined State, therefore bit 0 is unused<br>**(default: 16#0000_0000)** |
| `ModeTransitionCfg` | `ARRAY[0..MAX_MODES_UPPER_LIM] of DWORD` | The array index represents the Mode number. Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that a mode transition from the corresponding state number is allowed<br>**(default: 16#0000_0214)**<br>Note: 16#0000_0214 → Stopped, Idle, Aborted |
| `holdCmdCfg` | `DWORD` | Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that the Hold control command is taken into account in the corresponding state. Note: a state change is only performed if the Holding/Held states are not disabled. The 'holdCmdCfg' can only be activated for the following states: Idle, Starting, Execute, Completing, Completed, Suspending, Suspended, Unsuspending, Unholding<br>**(default: 16#0000_0060)**<br>Note: 16#0000_0060 → Suspended, Execute |
| `completeCmdCfg` | `DWORD` | Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that the Complete control command is taken into account in the corresponding state. Note: a state change is only performed if the Completing/Completed states are not disabled. The 'completeCmdCfg' can only be activated for the following states: Execute, Suspended, Held<br>**(default: 16#0000_0860)**<br>Note: 16#0000_0860 → Suspended, Execute, Held |

## Usage

This type is used as input parameter for the `UnitModeStateManager` function block to configure its behavior. The configuration is taken into account during the first call after STOP/RUN.
