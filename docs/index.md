# LPMLV2022 Library for SIMATIC AX

## Overview

The LPMLV2022 library provides a user-friendly basis for the implementation of an OMAC PackML compliant mode and state manager including _PackTags_ for the machine data interface for SIMATIC controllers.

## Library Overview

Fundamental information about the library can be found in the [library overview](./libraryOverview.md):

## Library Structure

The library is organized into the following main components:

### State Manager Function Blocks

- [`UnitModeStateManager`](./function-blocks/LPMLV2022_UnitModeStateManager.md): Machine and Unit State Manager according to ANSI/ISA-TR88.00.02-2022
- [`UnitModeStateManagerBool`](./function-blocks/LPMLV2022_UnitModeStateManagerBool.md): Boolean wrapper for the unit state manager

### Additional Function Blocks

- [`Stacklight`](./function-blocks/LPMLV2022_Stacklight.md): Stacklight status according to ANSI/ISA-TR88.00.02-2022

### Configuration Functions

- [`ConfigureEnabledModesCfg`](./functions/LPMLV2022_ConfigureEnabledModesCfg.md): Setting the unit mode configuration for enabled modes
- [`ConfigureDisabledStatesCfg`](./functions/LPMLV2022_ConfigureDisabledStatesCfg.md): Setting the state configuration for disabled states
- [`ConfigureModeTransitionCfg`](./functions/LPMLV2022_ConfigureModeTransitionCfg.md): Setting mode transition configuration for a unit mode
- [`ConfigureHoldCmdCfg`](./functions/LPMLV2022_ConfigureHoldCmdCfg.md): Setting hold control command configuration for all unit modes
- [`ConfigureCompleteCmdCfg`](./functions/LPMLV2022_ConfigureCompleteCmdCfg.md): Setting the complete control command configuration

### Data Types

- [`typeConfiguration`](./types/LPMLV2022_typeConfiguration.md)
- [`typeDiagnostics`](./types/LPMLV2022_typeDiagnostics.md)
- [`typeDiagnosticsEntry`](./types/LPMLV2022_typeDiagnosticsEntry.md)

### Constants

- [`LPMLV2022.Command`](./constants/LPMLV2022_CommandConstants.md): OMAC PackML V2022 command constants
- [`LimitConstants`](./constants/LPMLV2022_LimitConstants.md): Array boundary constants
- [`LPMLV2022.Mode`](./constants/LPMLV2022_ModeConstants.md): OMAC PackML V2022 unit mode constants
- [`LPMLV2022.State`](./constants/LPMLV2022_StateConstants.md): OMAC PackML V2022 state constants
- [`PackTagsConstants`](./constants/LPMLV2022_PackTagsConstants.md): OMAC PackML V2022 PackTag constants
- [`LPMLV2022.Message`](./constants/LPMLV2022_MessageConstants.md): Message constants for the diagnostic buffer

## Migration from TIA Portal

This library has been migrated from TIA Portal to SIMATIC AX. The functionality remains the same, but the programming model has been adapted to SIMATIC AX. Key differences include:

- Namespace: The library now uses the `Simatic.Ax.LPMLV2022` namespace
- Data types: The data types have been adapted to SIMATIC AX conventions
- The type `DTL` is not a system type in SIMATIC AX and is provided as a user-defined type for compatibility
