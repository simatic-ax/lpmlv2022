# LPMLV2022_typeDiagnosticsEntry

## Description

Individual diagnostics entry structure that contains information about a specific event or operation in the LPMLV2022 Unit Mode State Manager. Each entry captures the context and details of state machine operations for debugging and monitoring purposes.

## Structure

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | `DTL` | Timestamp for this entry<br>**(default: DTL#1970-01-01-00:00:00)** |
| `UnitModeCurrent` | `SInt` | Current unit mode<br>**(default: 0)** |
| `StateCurrent` | `SInt` | Current state<br>**(default: 0)** |
| `UnitMode` | `SInt` | Requested unit mode<br>**(default: 0)** |
| `CntrlCmd` | `SInt` | Request control command<br>**(default: 0)** |
| `SC` | `Bool` | State complete signal<br>**(default: FALSE)** |
| `message` | `Byte` | Message for this entry<br>**(default: 16#00)** |

## Usage

This type is used as elements in the diagnostics buffer array within `LPMLV2022_typeDiagnostics`. Each entry provides a snapshot of the state machine context when a significant event occurred, including timestamps, current states, requested operations, and associated message codes.
