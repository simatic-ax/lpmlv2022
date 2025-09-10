NAMESPACE Simatic.Ax.LPMLV2022
///================================================================================
/// SIEMENS AG
/// (c)Copyright 2025 All Rights Reserved
///--------------------------------------------------------------------------------
/// Library: LPMLV2022
/// Engineering: SIMATIC AX
/// Restrictions: -
/// Requirements: S7-1500 FW 2.6
/// Functionality: The function generates a DWord value which represents
///                the state configuration for all unit modes.
///
///                Note: All inputs must be set to comply with ANSI/ISA-TR88.00.02-2022
///================================================================================
FUNCTION LPMLV2022_ConfigureCompleteCmdCfg
    VAR_INPUT
        Suspended : BOOL; // TRUE: The Complete control command is taken into account in state Suspended
        Execute : BOOL; // TRUE: The Complete control command is taken into account in state Execute
        Held : BOOL; // TRUE: The Complete control command is taken into account in state Held
    END_VAR

    VAR_OUTPUT
        completeCmdCfg : DWORD;
    END_VAR


    // Initialize states configuration
    completeCmdCfg := DWORD#16#0000_0000;

    // Set states configuration
    completeCmdCfg.%X5 := Suspended;
    completeCmdCfg.%X6 := Execute;
    completeCmdCfg.%X11 := Held;

END_FUNCTION

END_NAMESPACE