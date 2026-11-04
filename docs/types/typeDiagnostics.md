# typeDiagnostics

## Description

Diagnostics structure that contains a buffer of diagnostic entries for the LPMLV2022 Unit Mode State Manager. This type provides information about events, errors, and state changes that occur during operation.

## Structure

| Field | Type | Description |
| ------- | ------ | ------------- |
| `bufferIndex` | `INT` | Index of actual buffer entry<br>**(default: -1)** |
| `buffer` | `ARRAY[0..DIAG_BUFFER_UPPER_LIM] of typeDiagnosticsEntry` | Diagnostics information buffer |

## Usage

This type is used as output parameter from the `UnitModeStateManager` function block to provide diagnostic information about the state machine operation. The buffer contains a circular array of diagnostic entries with the current index pointing to the most recent entry.
