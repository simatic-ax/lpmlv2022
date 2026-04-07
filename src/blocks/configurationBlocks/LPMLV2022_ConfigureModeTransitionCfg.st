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
FUNCTION ConfigureModeTransitionCfg
    VAR_INPUT
        /// TRUE: Allow a mode transition to/from state Clearing
        Clearing : BOOL;
        /// TRUE: Allow a mode transition to/from state Stopped
        Stopped : BOOL;
        /// TRUE: Allow a mode transition to/from state Starting
        Starting : BOOL;
        /// TRUE: Allow a mode transition to/from state Idle
        Idle : BOOL;
        /// TRUE: Allow a mode transition to/from state Suspended
        Suspended : BOOL;
        /// TRUE: Allow a mode transition to/from state Execute
        Execute : BOOL;
        /// TRUE: Allow a mode transition to/from state Stopping
        Stopping : BOOL;
        /// TRUE: Allow a mode transition to/from state Aborting
        Aborting : BOOL;
        /// TRUE: Allow a mode transition to/from state Aborted
        Aborted : BOOL;
        /// TRUE: Allow a mode transition to/from state Holding
        Holding : BOOL;
        /// TRUE: Allow a mode transition to/from state Held
        Held : BOOL;
        /// TRUE: Allow a mode transition to/from state Unholding
        Unholding : BOOL;
        /// TRUE: Allow a mode transition to/from state Suspending
        Suspending : BOOL;
        /// TRUE: Allow a mode transition to/from state Unsuspending
        Unsuspending : BOOL;
        /// TRUE: Allow a mode transition to/from state Resetting
        Resetting : BOOL;
        /// TRUE: Allow a mode transition to/from state Completing
        Completing : BOOL;
        /// TRUE: Allow a mode transition to/from state Completed
        Completed : BOOL;
    END_VAR

    VAR_OUTPUT
        /// Mode Transition Configuration for one unit mode for direct connection with the input
        /// config.ModeTransitionCfg[<unit mode>] of the desired UnitModeStateManager instance
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