# typeCommand

## Description

Command structure containing all command tags used to control the operation of the unit/machine. This includes unit state commands for controlling state transitions and parameters for machine operation control.

## Structure

| Field | Type | Description |
| ------- | ------ | ------------- |
| `UnitMode` | `DINT` | Unit Mode Target (0: Invalid, 1: Production, 2: Maintenance, 3: Manual, 04 - 31: User Definable). Minimum required for supervisory control |
| `UnitModeChangeRequest` | `BOOL` | Request Unit Mode Change to Unit Mode Target. Minimum required for supervisory control |
| `MachSpeed` | `REAL` | Current Machine Speed Setpoint; Unit of Measure: Primary Packages/Minute. Minimum required for supervisory control |
| `MaterialInterlock` | `DWORD` | Materials Ready. It is comprised of a series of bits with 1 equaling ready or not low, 0 equaling not ready, or low. Each bit represents a different user material. Unused bits should be forced to a value of 1 or TRUE |
| `CntrlCmd` | `DINT` | Control Command (0: Undefined, 1: Reset, 2: Start, 3: Stop, 4: Hold, 5: UnHold, 6: Suspend, 7: UnSuspend, 8: Abort, 9: Clear, 10: Complete). Minimum required for supervisory control |
| `CmdChangeRequest` | `BOOL` | State Change Request. This CmdChangeRequest bit will command the machine to proceed to change the state to the target state. Minimum required for supervisory control |
| `Parameter_REAL` | `ARRAY[0..COMMAND_PARAMETER_REAL_UPPER_LIM] of typeParameter_REAL` | Structured Array of Unit/Machine Parameter information for values with REAL data type |
| `Parameter_STRING` | `ARRAY[0..COMMAND_PARAMETER_STRING_UPPER_LIM] of typeParameter_STRING` | Structured ARRAY of Unit/Machine Parameter information for values with STRING data type |
| `Parameter_LREAL` | `ARRAY[0..COMMAND_PARAMETER_LREAL_UPPER_LIM] of typeParameter_LREAL` | Structured Array of Unit/Machine Parameter information for values with LREAL data type |
| `Parameter_DINT` | `ARRAY[0..COMMAND_PARAMETER_DINT_UPPER_LIM] of typeParameter_DINT` | Structured Array of Unit/Machine Parameter information for values with DINT data type |
| `Parameter_BOOL` | `ARRAY[0..COMMAND_PARAMETER_BOOL_UPPER_LIM] of typeParameter_BOOL` | Structured Array of Unit/Machine Parameter information for values with BOOL data type |
| `SelectedRecipe` | `DINT` | Recipe Selection. This tag is used to designate which recipe should be run on the machine to produce the primary output product, according to a user-design recipe handling procedure. It is designed to correspond directly to the listing in the Recipe Array |
| `RecipeChangeRequest` | `BOOL` | Recipe change request. This tag is used to trigger a user-defined recipe changeover process that will configure the machine to produce the primary product designated in Command.SelectedRecipe |
| `Recipe` | `ARRAY[0..COMMAND_RECIPE_UPPER_LIM] of typeCommandRecipe` | Structured Array of Recipe Information. The recipe data type can be used for defining product ingredient and product processing parameter variables |

## Usage

This type is used within `typePackTags` to provide command interface for machine control. It contains all necessary tags for supervisory control systems to operate the machine according to PackML standards.
