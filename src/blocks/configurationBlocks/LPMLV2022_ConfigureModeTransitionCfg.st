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
FUNCTION LPMLV2022_ConfigureModeTransitionCfg
    VAR_INPUT
        Clearing : BOOL; // TRUE: Allow a mode transition to/from state Clearing
        Stopped : BOOL; // TRUE: Allow a mode transition to/from state Stopped
        Starting : BOOL; // TRUE: Allow a mode transition to/from state Starting
        Idle : BOOL; // TRUE: Allow a mode transition to/from state Idle
        Suspended : BOOL; // TRUE: Allow a mode transition to/from state Suspended
        Execute : BOOL; // TRUE: Allow a mode transition to/from state Execute
        Stopping : BOOL; // TRUE: Allow a mode transition to/from state Stopping
        Aborting : BOOL; // TRUE: Allow a mode transition to/from state Aborting
        Aborted : BOOL; // TRUE: Allow a mode transition to/from state Aborted
        Holding : BOOL; // TRUE: Allow a mode transition to/from state Holding
        Held : BOOL; // TRUE: Allow a mode transition to/from state Held
        Unholding : BOOL; // TRUE: Allow a mode transition to/from state Unholding
        Suspending : BOOL; // TRUE: Allow a mode transition to/from state Suspending
        Unsuspending : BOOL; // TRUE: Allow a mode transition to/from state Unsuspending
        Resetting : BOOL; // TRUE: Allow a mode transition to/from state Resetting
        Completing : BOOL; // TRUE: Allow a mode transition to/from state Completing
        Completed : BOOL; // TRUE: Allow a mode transition to/from state Completed
    END_VAR

    VAR_OUTPUT
        ModeTransitionCfg : DWORD;
    END_VAR


    // Initialize states configuration
    ModeTransitionCfg := DWORD#16#0000_0000;

    // Set states configuration
    ModeTransitionCfg.%X1 := Clearing;
    ModeTransitionCfg.%X2 := Stopped;
    ModeTransitionCfg.%X3 := Starting;
    ModeTransitionCfg.%X4 := Idle;
    ModeTransitionCfg.%X5 := Suspended;
    ModeTransitionCfg.%X6 := Execute;
    ModeTransitionCfg.%X7 := Stopping;
    ModeTransitionCfg.%X8 := Aborting;
    ModeTransitionCfg.%X9 := Aborted;
    ModeTransitionCfg.%X10 := Holding;
    ModeTransitionCfg.%X11 := Held;
    ModeTransitionCfg.%X12 := Unholding;
    ModeTransitionCfg.%X13 := Suspending;
    ModeTransitionCfg.%X14 := Unsuspending;
    ModeTransitionCfg.%X15 := Resetting;
    ModeTransitionCfg.%X16 := Completing;
    ModeTransitionCfg.%X17 := Completed;

END_FUNCTION

END_NAMESPACE