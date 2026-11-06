# typeDiagnosticsEntry

## Description

Individual diagnostics entry structure that contains information about a specific event or operation in the LPMLV2022 Unit Mode State Manager. Each entry captures the context and details of state machine operations for debugging and monitoring purposes.

## Structure

| Field | Type | Description |
| ------- | ------ | ------------- |
| `timestamp` | `DTL` | Timestamp for this entry<br>**(default: DTL#1970-01-01-00:00:00)** |
| `UnitModeCurrent` | `SINT` | Current unit mode<br>**(default: 0)** |
| `StateCurrent` | `SINT` | Current state<br>**(default: 0)** |
| `UnitMode` | `SINT` | Requested unit mode<br>**(default: 0)** |
| `CntrlCmd` | `SINT` | Request control command<br>**(default: 0)** |
| `SC` | `BOOL` | State complete signal<br>**(default: FALSE)** |
| `message` | `Message` | Message for this entry<br>**(default: 16#00)** |

## Usage

This type is used as elements in the diagnostics buffer array within `typeDiagnostics`. Each entry provides a snapshot of the state machine context when a significant event occurred, including timestamps, current states, requested operations, and associated message codes.
