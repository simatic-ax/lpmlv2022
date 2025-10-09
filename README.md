# @simatic-ax/lpmlv2022

## Description

The LPMLV2022 library provides a user-friendly basis for the implementation of an OMAC PackML compliant mode and state manager including _PackTags_ for the machine data interface for SIMATIC controllers.

The library is a direct conversion of the functionally identical library [LPMLV2022](https://support.industry.siemens.com/cs/ww/en/view/109821198) for use inside the TIA Portal.

### Key Features

- **OMAC PackML V2022 Compliance**: Full implementation of ANSI/ISA-TR88.00.02-2022 standard for machine and unit state management
- **Multi-Mode Operation**: Support for Production, Maintenance, Manual, and up to 28 user-defined modes
- **Complete State Machine**: 17 standardized states including Execute, Stopped, Starting, Holding, Suspending, and more
- **PackTags Interface**: Standardized variable structures for machine data exchange with HMI, MES, and Enterprise systems
- **Flexible Configuration**: Configurable enabled modes, disabled states, mode transitions, and command handling
- **Boolean Wrapper Support**: Simplified boolean interface for unit state manager integration
- **Stacklight Integration**: Built-in stacklight status management according to PackML standards
- **Time Tracking**: Unit mode and state execution time monitoring capabilities
- **Comprehensive Diagnostics**: Built-in diagnostics and status reporting functionality

### Requirements

- SIMATIC AX
- S7-1500T CPU with firmware version 2.9 or higher

## Getting started

Install with Apax:

> If not yet done login to the GitHub registry first.
> More information you'll find [here](https://github.com/simatic-ax/.github/blob/main/docs/personalaccesstoken.md)

```cli
apax add @simatic-ax/lpmlv2022
```

Add the namespace in your ST code:

```iec-st
USING Simatic.Ax.LPMLV2022;
```

## Library functionality

Comprehensive documentation is available in the [docs](./docs) directory:

## Folder structure

```bash
lpmlv2022
    |
    +- .github
    |   +- workflows
    |       | # GitHub workflows for maintaining the library
    |       |- package-development-workflow.yml
    |       |- package-release-workflow.yml
    |
    +- docs
    |   | # comprehensive documentation for the library
    |   |- index.md
    |   |- libraryOverview.md
    |   +- assets
    |   |   +- images
    |   |       |- function_characteristics.png
    |   |       |- maintenance.png
    |   |       |- production.png
    |   |       |- user_scenario.png
    |   +- constants
    |   |   |- LPMLV2022_CommandConstants.md
    |   |   |- LPMLV2022_LimitConstants.md
    |   |   |- LPMLV2022_ModeConstants.md
    |   |   |- LPMLV2022_StateConstants.md
    |   |   |- LPMVL2022_PackTagsConstants.md
    |   +- function-blocks
    |   |   |- LPMLV2022_Stacklight.md
    |   |   |- LPMLV2022_UnitModeStateManager.md
    |   |   |- LPMLV2022_UnitModeStateManagerBool.md
    |   +- functions
    |   |   |- LPMLV2022_ConfigureCompleteCmdCfg.md
    |   |   |- LPMLV2022_ConfigureDisabledStatesCfg.md
    |   |   |- LPMLV2022_ConfigureEnabledModesCfg.md
    |   |   |- LPMLV2022_ConfigureHoldCmdCfg.md
    |   |   |- LPMLV2022_ConfigureModeTransitionCfg.md
    |   +- types
    |       |- LPMLV2022_typeCommand.md
    |       |- LPMLV2022_typeConfiguration.md
    |       |- LPMLV2022_typeDiagnostics.md
    |       |- LPMLV2022_typeDiagnosticsEntry.md
    |       |- LPMLV2022_typePackTags.md
    |       |- LPMLV2022_typeStatus.md
    |
    |
    +- src
    |   | # library source files
    |   +- blocks
    |   |   |- LPMLV2022_UnitModeStateManager.st
    |   |   +- booleanWrapper
    |   |   |   |- LPMLV2022_UnitModeStateManagerBool.st
    |   |   +- configurationBlocks
    |   |   |   |- LPMLV2022_ConfigureCompleteCmdCfg.st
    |   |   |   |- LPMLV2022_ConfigureDisabledStatesCfg.st
    |   |   |   |- LPMLV2022_ConfigureEnabledModesCfg.st
    |   |   |   |- LPMLV2022_ConfigureHoldCmdCfg.st
    |   |   |   |- LPMLV2022_ConfigureModeTransitionCfg.st
    |   |   +- furtherBlocks
    |   |       |- LPMLV2022_Stacklight.st
    |   +- constants
    |   |   |- LPMLV2022_Constants.st
    |   |   |- LPMLV2022_PackTag_Constants.st
    |   +- types
    |       |- DTL.st
    |       |- LPMLV2022_typeConfiguration.st
    |       |- LPMLV2022_typeConsiderCompleteCmdIn.st
    |       |- LPMLV2022_typeConsiderHoldCmdIn.st
    |       |- LPMLV2022_typeDiagnostics.st
    |       |- LPMLV2022_typeDiagnosticsEntry.st
    |       |- LPMLV2022_typeStatesInCurrentMode.st
    |
    +- test
    |   | # test programs for the library
    |   |- TestConfigureCompleteCmdCfg.st
    |   |- TestConfigureDisabledStatesCfg.st
    |   |- TestConfigureEnabledModesCfg.st
    |   |- TestConfigureHoldCmdCfg.st
    |   |- TestConfigureModeTransitionCfg.st
    |   |- TestStacklight.st
    |   |- TestUnitModeStateManager.st
    |   |- TestUnitModeStateManagerBool.st
    |
    | # additional meta-information for GitHub/-workflows
    |- .gitattributes
    |- .gitignore
    |- .markdownlint.yml
    |
    | # package management files
    |- apax.yml
    |
    | # settings file for activating the renovate-bot
    |- renovate.json
    |
    | # essential git project files
    |- CODEOWNERS
    |- README.md
    |- LICENSE.md #do not change!
```

## Contribution

Thanks for your interest in contributing. Anybody is free to report bugs, unclear documentation, and other problems regarding this repository in the Issues section.

## License and Legal information

Please read the [Legal information](LICENSE.md)
