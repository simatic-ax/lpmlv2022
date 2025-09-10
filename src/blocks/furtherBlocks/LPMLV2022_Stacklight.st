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
FUNCTION_BLOCK LPMLV2022_Stacklight
    {S7.extern = ReadWrite}
    VAR_INPUT
        StateCurrent : DINT := LPMLV2022_StateConstants#STATE_UNDEFINED; // Current state
        starvedUpstream : BOOL; // TRUE: upstream system is not able to supply products
        blockedDownstream : BOOL; // TRUE: downstream system is not able to accept products
        materialLow : BOOL; // TRUE: low material
        materialExhausted : BOOL; // TRUE: material exhausted
    END_VAR
    
    {S7.extern = ReadOnly}
    VAR_OUTPUT
        Stacklight : DWORD; // Indicator for the current stacklight status -> PackTags
        redSolid : BOOL; // Status of stacklight bit 0
        redFlashing : BOOL; // Status of stacklight bit 1
        amberSolid : BOOL; // Status of stacklight bit 2
        amberFlashing : BOOL; // Status of stacklight bit 3
        blueSolid : BOOL; // Status of stacklight bit 4
        blueFlashing : BOOL; // Status of stacklight bit 5
        greenSolid : BOOL; // Status of stacklight bit 6
        greenFlashing : BOOL; // Status of stacklight bit 7
        hornFlashing : BOOL; // Status of stacklight bit 9
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
        LPMLV2022_StateConstants#STATE_EXECUTE:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;

        LPMLV2022_StateConstants#STATE_COMPLETING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;

        LPMLV2022_StateConstants#STATE_COMPLETED:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_RESETTING:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_IDLE:
            tempBlueFlashing := materialLow;
            tempGreenFlashing := TRUE;

        LPMLV2022_StateConstants#STATE_STARTING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;
            tempHornFlashing := TRUE;

        LPMLV2022_StateConstants#STATE_UNHOLDING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;
            tempHornFlashing := TRUE;

        LPMLV2022_StateConstants#STATE_UNSUSPENDING:
            tempBlueFlashing := materialLow;
            tempGreenSolid := TRUE;
            tempHornFlashing := TRUE;

        LPMLV2022_StateConstants#STATE_HOLDING:
            tempBlueSolid := materialExhausted;

        LPMLV2022_StateConstants#STATE_HELD:
            tempBlueSolid := materialExhausted;

        LPMLV2022_StateConstants#STATE_SUSPENDING:
            tempAmberFlashing := starvedUpstream;
            tempAmberSolid := blockedDownstream;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_SUSPENDED:
            tempAmberFlashing := starvedUpstream;
            tempAmberSolid := blockedDownstream;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_ABORTING:
            tempRedFlashing := TRUE;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_ABORTED:
            tempRedFlashing := TRUE;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_CLEARING:
            tempRedFlashing := TRUE;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_STOPPING:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        LPMLV2022_StateConstants#STATE_STOPPED:
            tempRedSolid := TRUE;
            tempBlueFlashing := materialLow;

        // ELSE 
        //   ; // Reset all outputs
    END_CASE;

    // Write outputs
    Stacklight := DWORD#16#0000_0000;

    Stacklight.%X0 := tempRedSolid;
	redSolid := tempRedSolid;
    Stacklight.%X1 := tempRedFlashing;
	redFlashing := tempRedFlashing;
    Stacklight.%X2 := tempAmberSolid;
	amberSolid := tempAmberSolid;
    Stacklight.%X3 := tempAmberFlashing;
	amberFlashing := tempAmberFlashing;
    Stacklight.%X4 := tempBlueSolid;
	blueSolid := tempBlueSolid;
    Stacklight.%X5 := tempBlueFlashing;
	blueFlashing := tempBlueFlashing;
    Stacklight.%X6 := tempGreenSolid;
	greenSolid := tempGreenSolid;
    Stacklight.%X7 := tempGreenFlashing;
	greenFlashing := tempGreenFlashing;
    Stacklight.%X9 := tempHornFlashing;
	hornFlashing := tempHornFlashing;

END_FUNCTION_BLOCK

END_NAMESPACE