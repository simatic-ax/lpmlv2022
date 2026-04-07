NAMESPACE Simatic.Ax.LPMLV2022
///================================================================================
/// SIEMENS AG
/// (c)Copyright 2025 All Rights Reserved
///--------------------------------------------------------------------------------
/// Library: LPMLV2022
/// Engineering: SIMATIC AX
/// Restrictions: -
/// Requirements: S7-1500 FW 2.6
/// Functionality: Stacklight status according to ANSI/ISA-TR88.00.02-2022
///================================================================================
FUNCTION_BLOCK Stacklight
    {S7.extern = ReadWrite}
    VAR_INPUT
        /// Current state
        StateCurrent : State := State#UNDEFINED;
        /// TRUE: upstream system is not able to supply products
        starvedUpstream : BOOL;
        /// TRUE: downstream system is not able to accept products
        blockedDownstream : BOOL;
        /// TRUE: low material
        materialLow : BOOL;
        /// TRUE: material exhausted
        materialExhausted : BOOL;
    END_VAR

    {S7.extern = ReadOnly}
    VAR_OUTPUT
        /// Indicator for the current stacklight status -> PackTags
        StacklightStatus : DWORD;
        /// Status of stacklight bit 0
        redSolid : BOOL;
        /// Status of stacklight bit 1
        redFlashing : BOOL;
        /// Status of stacklight bit 2
        amberSolid : BOOL;
        /// Status of stacklight bit 3
        amberFlashing : BOOL;
        /// Status of stacklight bit 4
        blueSolid : BOOL;
        /// Status of stacklight bit 5
        blueFlashing : BOOL;
        /// Status of stacklight bit 6
        greenSolid : BOOL;
        /// Status of stacklight bit 7
        greenFlashing : BOOL;
        /// Status of stacklight bit 9
        hornFlashing : BOOL;
    END_VAR

    VAR_TEMP
        tempRedSolid : BOOL; // Status of stacklight bit 0
        tempRedFlashing : BOOL; // Status of stacklight bit 1
        tempAmberSolid : BOOL; // Status of stacklight bit 2
        tempAmberFlashing : BOOL; // Status of stacklight bit 3
        tempBlueSolid : BOOL; // Status of stacklight bit 4
        tempBlueFlashing : BOOL; // Status of stacklight bit 5
        tempGreenSolid : BOOL; // Status of stacklight bit 6
        tempGreenFlashing : BOOL; // Status of stacklight bit 7
        tempHornFlashing : BOOL; // Status of stacklight bit 9
    END_VAR


    // Example of how the stacklight can be made to correspond to certain machine conditions and PackML States

    //                    |Aborting |Clearing | Aborted |Completed| Stopped |Stopping |Resetting|  Idle   |Starting |Execute  | Comple- | Holding |Held (No |Unholding| Suspen- |Suspended|Unsuspen-|
    //                    |         |         |         |         |         |         |         |         |         |         |  ting   |         |Product.)|         |  ding   |         |  ding   |
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Abnormal Stop      |    F    |    F    |    F    |         |         |         |         |         |         |         |         |         |         |         |         |         |         | Red Lamp Flashing
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Controlled Stop    |         |         |         |    S    |    S    |    S    |    S    |         |         |         |         |         |         |         |         |         |         | Red Lamp Solid
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Starved Upstream   |         |         |         |         |         |         |         |         |         |         |         |         |         |         |    F    |    F    |         | Amber Lamp Flashing
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Blocked Downstream |         |         |         |         |         |         |         |         |         |         |         |         |         |         |    S    |    S    |         | Amber Lamp Solid
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Low Material       |    F    |    F    |    F    |    F    |    F    |    F    |    F    |    F    |    F    |    F    |    F    |         |         |    F    |    F    |    F    |    F    | Blue Lamp Flashing
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Material Exhausted |         |         |         |         |         |         |         |         |         |         |         |    S    |    S    |         |         |         |         | Blue Lamp Solid
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Ready to Start     |         |         |         |         |         |         |         |    F    |         |         |         |         |         |         |         |         |         | Green Lamp Flashing
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Running            |         |         |         |         |         |         |         |         |    S    |    S    |    S    |         |         |    S    |         |         |    S    | Green Lamp Solid
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------
    // Starting/Restarting|         |         |         |         |         |         |         |         |    F    |         |         |         |         |    F    |         |         |    F    | Horn
    //--------------------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+--------------------

    // The temporary variables are automatically set to FALSE, because the "Optimized block access" attribute is set

    CASE StateCurrent OF
        State#EXECUTE:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;

        State#COMPLETING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;

        State#COMPLETED:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        State#RESETTING:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        State#IDLE:
            tempBlueFlashing := materialLow;
            tempGreenFlashing := TRUE;

        State#STARTING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;
            tempHornFlashing := TRUE;

        State#UNHOLDING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;
            tempHornFlashing := TRUE;

        State#UNSUSPENDING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;
            tempHornFlashing := TRUE;

        State#HOLDING:
            tempBlueSolid := materialExhausted;

        State#HELD:
            tempBlueSolid := materialExhausted;

        State#SUSPENDING:
            tempAmberFlashing := starvedUpstream;
            tempAmberSolid := blockedDownstream;
            tempBlueFlashing := materialLow;

        State#SUSPENDED:
            tempAmberFlashing := starvedUpstream;
            tempAmberSolid := blockedDownstream;
            tempBlueFlashing := materialLow;

        State#ABORTING:
            tempRedFlashing := TRUE;
            tempBlueFlashing := materialLow;

        State#ABORTED:
            tempRedFlashing := TRUE;
            tempBlueFlashing := materialLow;

        State#CLEARING:
            tempRedFlashing := TRUE;
            tempBlueFlashing := materialLow;

        State#STOPPING:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        State#STOPPED:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        // ELSE
        //   ; // Reset all outputs
    END_CASE;

    // Write outputs
    StacklightStatus := DWORD#16#0000_0000;

    StacklightStatus.%X0 := tempRedSolid;
	redSolid := tempRedSolid;
    StacklightStatus.%X1 := tempRedFlashing;
	redFlashing := tempRedFlashing;
    StacklightStatus.%X2 := tempAmberSolid;
	amberSolid := tempAmberSolid;
    StacklightStatus.%X3 := tempAmberFlashing;
	amberFlashing := tempAmberFlashing;
    StacklightStatus.%X4 := tempBlueSolid;
	blueSolid := tempBlueSolid;
    StacklightStatus.%X5 := tempBlueFlashing;
	blueFlashing := tempBlueFlashing;
    StacklightStatus.%X6 := tempGreenSolid;
	greenSolid := tempGreenSolid;
    StacklightStatus.%X7 := tempGreenFlashing;
	greenFlashing := tempGreenFlashing;
    StacklightStatus.%X9 := tempHornFlashing;
	hornFlashing := tempHornFlashing;

END_FUNCTION_BLOCK

END_NAMESPACE