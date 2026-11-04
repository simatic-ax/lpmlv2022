# LPMLV2022 Library for SIMATIC AX

## Overview

The LPMLV2022 library provides a user-friendly basis for the implementation of an OMAC PackML compliant mode and state manager for SIMATIC controllers.

## Library Overview

Fundamental information about the library can be found in the [library overview](./libraryOverview.md):

## Library Structure

The library is organized into the following main components:

### State Manager Function Blocks

- [`UnitModeStateManager`](./function-blocks/UnitModeStateManager.md): Machine and Unit State Manager according to ANSI/ISA-TR88.00.02-2022

### Additional Function Blocks

- [`Stacklight`](./function-blocks/Stacklight.md): Stacklight status according to ANSI/ISA-TR88.00.02-2022

### Examples

- [Boolean wrapper](./exampleBooleanWrapper.md): Source code example of a boolean interface for the unit state manager

### Configuration Functions

- [`ConfigureEnabledModesCfg`](./functions/ConfigureEnabledModesCfg.md): Setting the unit mode configuration for enabled modes
- [`ConfigureDisabledStatesCfg`](./functions/ConfigureDisabledStatesCfg.md): Setting the state configuration for disabled states
- [`ConfigureModeTransitionCfg`](./functions/ConfigureModeTransitionCfg.md): Setting mode transition configuration for a unit mode
- [`ConfigureHoldCmdCfg`](./functions/ConfigureHoldCmdCfg.md): Setting hold control command configuration for all unit modes
- [`ConfigureCompleteCmdCfg`](./functions/ConfigureCompleteCmdCfg.md): Setting the complete control command configuration

### Data Types

- [`typeConfiguration`](./types/typeConfiguration.md)
- [`typeDiagnostics`](./types/typeDiagnostics.md)
- [`typeDiagnosticsEntry`](./types/typeDiagnosticsEntry.md)

### Constants

- [`LPMLV2022.Command`](./constants/CommandConstants.md): OMAC PackML V2022 command constants
- [`LPMLV2022.LimitConstants`](./constants/LimitConstants.md): Array boundary constants
- [`LPMLV2022.Mode`](./constants/ModeConstants.md): OMAC PackML V2022 unit mode constants
- [`LPMLV2022.State`](./constants/StateConstants.md): OMAC PackML V2022 state constants
- [`LPMLV2022.Message`](./constants/MessageConstants.md): Message constants for the diagnostic buffer
