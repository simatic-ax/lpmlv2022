# typeStatus

## Description

Status structure containing all status tags used to describe the operation of the unit/machine. This includes current state information, machine parameters, and operational data for monitoring and information purposes.

## Structure

| Field | Type | Description |
| ------- | ------ | ------------- |
| `UnitModeCurrent` | `DINT` | Current Unit Mode Number (0: Invalid, 1: Production, 2: Maintenance, 3: Manual, 04 - 31: User Definable). Minimum required for information/machine monitoring |
| `UnitModeRequested` | `BOOL` | Requested Unit Mode Change. When a unit mode request takes place a numerical value must be present in the unit mode target to change the unit mode |
| `UnitModeChangeInProcess` | `BOOL` | Requested Unit Mode Change In Process |
| `StateCurrent` | `DINT` | Current State Number (0: Undefined, 1: CLEARING, 2: STOPPED, 3: STARTING, 4: IDLE, 5: SUSPENDED, 6: EXECUTE, 7: STOPPING, 8: ABORTING, 9: ABORTED; 10: HOLDING, 11: HELD, 12: UNHOLDING, 13: SUSPENDING, 14: UNSUSPENDING, 15: RESETTING, 16: COMPLETING, 17: COMPLETED). Minimum required for information/machine monitoring |
| `StateRequested` | `DINT` | Target State. This value is used for state transition checking, to ensure that transition to a target state can be achieved |
| `StateChangeInProcess` | `BOOL` | State Change in Process. This bit indicates that a change in state is in progress following a state change request command |
| `MachSpeed` | `REAL` | Current Machine Speed Setpoint. This describes the set point for the current speed of the machine in primary packages per minute. Minimum required for information/machine monitoring |
| `CurMachSpeed` | `REAL` | Current Actual Machine Speed. This is the actual value of the machine speed in primary packages per minute. Minimum required for information/machine monitoring |
| `MaterialInterlock` | `DWORD` | Materials Ready. MaterialInterlock describes the status of the materials that are ready for processing. It is comprised of a series of bits with 1 equaling ready or not low, 0 equaling not ready, or low. Each bit represents a different user material |
| `EquipmentInterlock` | `typeEquipmentInterlock` | Is a collection of tags that are used to provide an indicator of Blocked or Starved conditions at the machine unit when integrated into a complete production line |
| `Parameter_REAL` | `ARRAY[0..STATUS_PARAMETER_REAL_UPPER_LIM] of typeParameter_REAL` | Structured Array of Unit/Machine Parameter information for values with REAL data type |
| `Parameter_STRING` | `ARRAY[0..STATUS_PARAMETER_STRING_UPPER_LIM] of typeParameter_STRING` | Structured Array of Unit/Machine Parameter information for values with STRING data type |
| `Parameter_LREAL` | `ARRAY[0..STATUS_PARAMETER_LREAL_UPPER_LIM] of typeParameter_LREAL` | Structured Array of Unit/Machine Parameter information for values with LREAL data type |
| `Parameter_DINT` | `ARRAY[0..STATUS_PARAMETER_DINT_UPPER_LIM] of typeParameter_DINT` | Structured Array of Unit/Machine Parameter information for values with DINT data type |
| `Parameter_BOOL` | `ARRAY[0..STATUS_PARAMETER_BOOL_UPPER_LIM] of typeParameter_BOOL` | Structured Array of Unit/Machine Parameter information for values with BOOL data type |
| `RecipeCurrent` | `DINT` | The recipe currently running in production |
| `RecipeRequested` | `DINT` | A reflection of the recipe currently selected for production |
| `RecipeChangeInProcess` | `BOOL` | An indicator for the user-defined recipe changeover process |
| `Recipe` | `ARRAY[0..STATUS_RECIPE_UPPER_LIM] of typeStatusRecipe` | Structured Array of Recipe Information. The recipe data type can be used for defining product ingredient and product processing parameter variables |
| `Stacklight` | `ARRAY[0..STATUS_STACK_LIGHT_UPPER_LIM] of DWORD` | Indicator for the current stacklight status. This tag can be used simultaneously for reporting stacklight conditions and as control bits for physical outputs. The status of a light in the stack is associated to a particular bit location within the register (Bit 0: Red Solid, 1: Red Flashing, 2: Amber Solid, 3: Amber Flashing, 4: Blue Solid, 5: Blue Flashing, 6: Green Solid, 7: Green Flashing, 8: Horn Solid, 9: Horn Flashing, 10..31: User-Defined) |

## Usage

This type is used within `typePackTags` to provide status interface for machine monitoring. It contains all necessary tags for supervisory systems to monitor machine operation according to PackML standards.
