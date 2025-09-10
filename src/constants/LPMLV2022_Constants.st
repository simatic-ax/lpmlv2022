NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        LPMLV2022_ModeConstants : DINT (
            MODE_INVALID := DINT#0, // OMAC PackMLV2022 unit mode Invalid
            MODE_PRODUCTION := DINT#1, // OMAC PackMLV2022 unit mode Production
            MODE_MAINTENANCE := DINT#2, // OMAC PackMLV2022 unit mode Maintenance
            MODE_MANUAL := DINT#3, // OMAC PackMLV2022 unit mode Manual
            MODE_USER_01 := DINT#4, // OMAC PackMLV2022 user-defined unit mode 01
            MODE_USER_02 := DINT#5, // OMAC PackMLV2022 user-defined unit mode 02
            MODE_USER_03 := DINT#6, // OMAC PackMLV2022 user-defined unit mode 03
            MODE_USER_04 := DINT#7, // OMAC PackMLV2022 user-defined unit mode 04
            MODE_USER_05 := DINT#8, // OMAC PackMLV2022 user-defined unit mode 05
            MODE_USER_06 := DINT#9, // OMAC PackMLV2022 user-defined unit mode 06
            MODE_USER_07 := DINT#10, // OMAC PackMLV2022 user-defined unit mode 07
            MODE_USER_08 := DINT#11, // OMAC PackMLV2022 user-defined unit mode 08
            MODE_USER_09 := DINT#12, // OMAC PackMLV2022 user-defined unit mode 09
            MODE_USER_10 := DINT#13, // OMAC PackMLV2022 user-defined unit mode 10
            MODE_USER_11 := DINT#14, // OMAC PackMLV2022 user-defined unit mode 11
            MODE_USER_12 := DINT#15, // OMAC PackMLV2022 user-defined unit mode 12
            MODE_USER_13 := DINT#16, // OMAC PackMLV2022 user-defined unit mode 13
            MODE_USER_14 := DINT#17, // OMAC PackMLV2022 user-defined unit mode 14
            MODE_USER_15 := DINT#18, // OMAC PackMLV2022 user-defined unit mode 15
            MODE_USER_16 := DINT#19, // OMAC PackMLV2022 user-defined unit mode 16
            MODE_USER_17 := DINT#20, // OMAC PackMLV2022 user-defined unit mode 17
            MODE_USER_18 := DINT#21, // OMAC PackMLV2022 user-defined unit mode 18
            MODE_USER_19 := DINT#22, // OMAC PackMLV2022 user-defined unit mode 19
            MODE_USER_20 := DINT#23, // OMAC PackMLV2022 user-defined unit mode 20
            MODE_USER_21 := DINT#24, // OMAC PackMLV2022 user-defined unit mode 21
            MODE_USER_22 := DINT#25, // OMAC PackMLV2022 user-defined unit mode 22
            MODE_USER_23 := DINT#26, // OMAC PackMLV2022 user-defined unit mode 23
            MODE_USER_24 := DINT#27, // OMAC PackMLV2022 user-defined unit mode 24
            MODE_USER_25 := DINT#28, // OMAC PackMLV2022 user-defined unit mode 25
            MODE_USER_26 := DINT#29, // OMAC PackMLV2022 user-defined unit mode 26
            MODE_USER_27 := DINT#30, // OMAC PackMLV2022 user-defined unit mode 27
            MODE_USER_28 := DINT#31 // OMAC PackMLV2022 user-defined unit mode 28
            );
    END_TYPE

    TYPE
        LPMLV2022_StateConstants : DINT (
            STATE_UNDEFINED := DINT#0, // OMAC PackMLV2022 state Undefined
            STATE_CLEARING := DINT#1, // OMAC PackMLV2022 state Clearing
            STATE_STOPPED := DINT#2, // OMAC PackMLV2022 state Stopped
            STATE_STARTING := DINT#3, // OMAC PackMLV2022 state Starting
            STATE_IDLE := DINT#4, // OMAC PackMLV2022 state Idle
            STATE_SUSPENDED := DINT#5, // OMAC PackMLV2022 state Suspended
            STATE_EXECUTE := DINT#6, // OMAC PackMLV2022 state Execute
            STATE_STOPPING := DINT#7, // OMAC PackMLV2022 state Stopping
            STATE_ABORTING := DINT#8, // OMAC PackMLV2022 state Aborting
            STATE_ABORTED := DINT#9, // OMAC PackMLV2022 state Aborted
            STATE_HOLDING := DINT#10, // OMAC PackMLV2022 state Holding
            STATE_HELD := DINT#11, // OMAC PackMLV2022 state Held
            STATE_UNHOLDING := DINT#12, // OMAC PackMLV2022 state Unholding
            STATE_SUSPENDING := DINT#13, // OMAC PackMLV2022 state Suspending
            STATE_UNSUSPENDING := DINT#14, // OMAC PackMLV2022 state Unsuspending
            STATE_RESETTING := DINT#15, // OMAC PackMLV2022 state Resetting
            STATE_COMPLETING := DINT#16, // OMAC PackMLV2022 state Completing
            STATE_COMPLETED := DINT#17 // OMAC PackMLV2022 state Completed
            );
    END_TYPE

    TYPE
        LPMLV2022_CommandConstants : DINT (
            CMD_UNDEFINED := DINT#0, // OMAC PackMLV2022 control command Undefined
            CMD_RESET := DINT#1, // OMAC PackMLV2022 control command Reset
            CMD_START := DINT#2, // OMAC PackMLV2022 control command Start
            CMD_STOP := DINT#3, // OMAC PackMLV2022 control command Stop
            CMD_HOLD := DINT#4, // OMAC PackMLV2022 control command Hold
            CMD_UNHOLD := DINT#5, // OMAC PackMLV2022 control command Unhold
            CMD_SUSPEND := DINT#6, // OMAC PackMLV2022 control command Suspend
            CMD_UNSUSPEND := DINT#7, // OMAC PackMLV2022 control command Unsuspend
            CMD_ABORT := DINT#8, // OMAC PackMLV2022 control command Abort
            CMD_CLEAR := DINT#9, // OMAC PackMLV2022 control command Clear
            CMD_COMPLETE := DINT#10 // OMAC PackMLV2022 control command Complete
            );
    END_TYPE

    TYPE
        LPMLV2022_LimitConstants : INT (
            DIAG_BUFFER_UPPER_LIM := INT#7, // Diagnostics buffer array upper boundary (0-based)
            MODES_UPPER_LIM := INT#8, // (Number of unit modes - 1) -> Array[0..MODES_UPPER_LIM]
            STATES_UPPER_LIM := INT#17, // (Number of states - 1) -> Array[0..STATES_UPPER_LIM]
            MAX_MODES_UPPER_LIM := INT#31 // (Maximum number of unit modes - 1) -> Array[0..MAX_MODES_UPPER_LIM]
            );
    END_TYPE
END_NAMESPACE