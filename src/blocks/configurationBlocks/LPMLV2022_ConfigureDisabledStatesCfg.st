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
///                the state configuration for one unit mode.
///================================================================================
FUNCTION LPMLV2022_ConfigureDisabledStatesCfg
    VAR_INPUT
        Clearing : BOOL; // TRUE: Disable state Clearing
        Starting : BOOL; // TRUE: Disable state Starting
        Suspended : BOOL; // TRUE: Disable state Suspended
        Stopping : BOOL; // TRUE: Disable state Stopping
        Aborting : BOOL; // TRUE: Disable state Aborting
        Holding : BOOL; // TRUE: Disable state Holding
        Held : BOOL; // TRUE: Disable state Held
        Unholding : BOOL; // TRUE: Disable state Unholding
        Suspending : BOOL; // TRUE: Disable state Suspending
        Unsuspending : BOOL; // TRUE: Disable state Unsuspending
        Resetting : BOOL; // TRUE: Disable state Resetting
        Completing : BOOL; // TRUE: Disable state Completing
        Completed : BOOL; // TRUE: Disable state Completed
    END_VAR

    VAR_OUTPUT
        DisabledStatesCfg : DWORD;
    END_VAR


    // Initialize states configuration
    DisabledStatesCfg := DWORD#16#0000_0000;

    // Note: Stopped (.%X2), Idle (.%X4), Execute (.%X6) and Aborted (.%X9) are always present. They cannot be disabled

    // Set states configuration
    DisabledStatesCfg.%X1 := Clearing;
    DisabledStatesCfg.%X3 := Starting;
    DisabledStatesCfg.%X5 := Suspended;
    DisabledStatesCfg.%X7 := Stopping;
    DisabledStatesCfg.%X8 := Aborting;
    DisabledStatesCfg.%X10 := Holding;
    DisabledStatesCfg.%X11 := Held;
    DisabledStatesCfg.%X12 := Unholding;
    DisabledStatesCfg.%X13 := Suspending;
    DisabledStatesCfg.%X14 := Unsuspending;
    DisabledStatesCfg.%X15 := Resetting;
    DisabledStatesCfg.%X16 := Completing;
    DisabledStatesCfg.%X17 := Completed;

END_FUNCTION

END_NAMESPACE