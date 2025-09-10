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
///                Note: Only the inputs 'Suspended' and 'Execute' must be set
///                      to comply with ANSI/ISA-TR88.00.02-2022
///================================================================================
FUNCTION LPMLV2022_ConfigureHoldCmdCfg
    VAR_INPUT
        Starting : BOOL; // TRUE: The Hold control command is taken into account in state Starting
        Idle : BOOL; // TRUE: The Hold control command is taken into account in state Idle
        Suspended : BOOL; // TRUE: The Hold control command is taken into account in state Suspended
        Execute : BOOL; // TRUE: The Hold control command is taken into account in state Execute
        Unholding : BOOL; // TRUE: The Hold control command is taken into account in state Unholding
        Suspending : BOOL; // TRUE: The Hold control command is taken into account in state Suspending
        Unsuspending : BOOL; // TRUE: The Hold control command is taken into account in state Unsuspending
        Completing : BOOL; // TRUE: The Hold control command is taken into account in state Completing
        Completed : BOOL; // TRUE: The Hold control command is taken into account in state Completed
    END_VAR

    VAR_OUTPUT
        holdCmdCfg : DWORD;
    END_VAR


    // Initialize states configuration
    holdCmdCfg := DWORD#16#0000_0000;

    // Set states configuration
    holdCmdCfg.%X3 := Starting;
    holdCmdCfg.%X4 := Idle;
    holdCmdCfg.%X5 := Suspended;
    holdCmdCfg.%X6 := Execute;
    holdCmdCfg.%X12 := Unholding;
    holdCmdCfg.%X13 := Suspending;
    holdCmdCfg.%X14 := Unsuspending;
    holdCmdCfg.%X16 := Completing;
    holdCmdCfg.%X17 := Completed;

END_FUNCTION

END_NAMESPACE