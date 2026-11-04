# @simatic-ax/lpmlv2022

## Description

The LPMLV2022 library provides a user-friendly basis for the implementation of an OMAC PackML compliant mode and state manager for SIMATIC controllers.

The library is a direct conversion of the functionally identical library [LPMLV2022](https://support.industry.siemens.com/cs/ww/en/view/109821198) for use inside the TIA Portal

### Key Features

- **OMAC PackML V2022 Compliance**: Full implementation of ANSI/ISA-TR88.00.02-2022 standard for machine and unit state management
- **Multi-Mode Operation**: Support for Production, Maintenance, Manual, and up to 28 user-defined modes
- **Complete State Machine**: 17 standardized states including Execute, Stopped, Starting, Holding, Suspending, and more
- **Flexible Configuration**: Configurable enabled modes, disabled states, mode transitions, and command handling
- **Boolean Wrapper Example**: Documented source code example of a boolean interface for the unit state manager
- **Stacklight Integration**: Built-in stacklight status management according to PackML standards
- **Comprehensive Diagnostics**: Built-in diagnostics and status reporting functionality

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

More details on how to use the library can be found on the dedicated [Getting Started](./docs/examples.md) page.

### Notes

- The package is delivered compiled. The diagnostics buffer depth is fixed at 8 entries.
- A boolean interface is not part of the package; see the [Boolean wrapper example](./docs/exampleBooleanWrapper.md).
- The full source code is available in this GitHub repository if the state machine behavior needs to be modified.

## Library functionality

Comprehensive documentation is available in the [docs](./docs) directory:

## Contribution

Thanks for your interest in contributing. Anybody is free to report bugs, unclear documentation, and other problems regarding this repository in the Issues section.

## License and Legal information

Please read the [Legal information](LICENSE.md)
