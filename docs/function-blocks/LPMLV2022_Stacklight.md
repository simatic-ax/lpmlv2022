# Stacklight

## Principle of operation

The function block `Stacklight` can be used to generate the stacklight status information according to ISA TR88.00.02-2022.

| Machine Condition | Aborting | Clearing | Aborted | Completed | Stopped | Stopping | Resetting | Idle | Starting | Execute | Completing | Holding | Held (No Product.) | Unholding | Suspending | Suspended | Unsuspending | Lamp Behavior |
| ------------------ | --------- | --------- | -------- | ---------- | -------- | --------- | ---------- | ----- | --------- | -------- | ----------- | -------- | ------------------ | ---------- | ----------- | ---------- | ------------- | -------------- |
| Abnormal Stop | F | F | F | | | | | | | | | | | | | | | Red Lamp Flashing |
| Controlled Stop | | | | S | S | S | S | | | | | | | | | | | Red Lamp Solid |
| Starved Upstream | | | | | | | | | | | | | | | F | F | | Amber Lamp Flashing |
| Blocked Downstream | | | | | | | | | | | | | | | S | S | | Amber Lamp Solid |
| Low Material | F | F | F | F | F | F | F | F | F | F | F | | | F | F | F | F | Blue Lamp Flashing |
| Material Exhausted | | | | | | | | | | | | S | S | | | | | Blue Lamp Solid |
| Ready to Start | | | | | | | | F | | | | | | | | | | Green Lamp Flashing |
| Running | | | | | | | | | S | S | S | | | S | | | S | Green Lamp Solid |
| Starting/Restarting | | | | | | | | | F | | | | | F | | | F | Horn |

### Legend

- **F** = Flashing
- **S** = Solid

## Interface

### Input Parameters

| Parameter | Type | Description |
| ---------- | ----- | ------------ |
| StateCurrent | State | Current state |
| starvedUpstream | BOOL | TRUE: upstream system is not able to supply products |
| blockedDownstream | BOOL | TRUE: downstream system is not able to accept products |
| materialLow | BOOL | TRUE: low material |
| materialExhausted | BOOL | TRUE: material exhausted |

### Output Parameters

| Parameter | Type | Description |
| ---------- | ----- | ------------ |
| StacklightStatus | DWORD | Indicator for the current stacklight status -> PackTags |
| redSolid | BOOL | Status of stacklight bit 0 |
| redFlashing | BOOL | Status of stacklight bit 1 |
| amberSolid | BOOL | Status of stacklight bit 2 |
| amberFlashing | BOOL | Status of stacklight bit 3 |
| blueSolid | BOOL | Status of stacklight bit 4 |
| blueFlashing | BOOL | Status of stacklight bit 5 |
| greenSolid | BOOL | Status of stacklight bit 6 |
| greenFlashing | BOOL | Status of stacklight bit 7 |
| hornFlashing | BOOL | Status of stacklight bit 9 |
