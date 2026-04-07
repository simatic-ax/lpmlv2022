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
FUNCTION ConfigureDisabledStatesCfg
    VAR_INPUT
        /// TRUE: Disable state Clearing
        Clearing : BOOL;
        /// TRUE: Disable state Starting
        Starting : BOOL;
        /// TRUE: Disable state Suspended
        Suspended : BOOL;
        /// TRUE: Disable state Stopping
        Stopping : BOOL;
        /// TRUE: Disable state Aborting
        Aborting : BOOL;
        /// TRUE: Disable state Holding
        Holding : BOOL;
        /// TRUE: Disable state Held
        Held : BOOL;
        /// TRUE: Disable state Unholding
        Unholding : BOOL;
        /// TRUE: Disable state Suspending
        Suspending : BOOL;
        /// TRUE: Disable state Unsuspending
        Unsuspending : BOOL;
        /// TRUE: Disable state Resetting
        Resetting : BOOL;
        /// TRUE: Disable state Completing
        Completing : BOOL;
        /// TRUE: Disable state Completed
        Completed : BOOL;
    END_VAR

    VAR_OUTPUT
        /// Disabled states configuration for one unit mode for direct connection with the input
        /// config.DisabledStatesCfg[<unit mode>] of the desired UnitModeStateManager instance.
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