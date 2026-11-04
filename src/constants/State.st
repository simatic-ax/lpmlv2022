NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        /// Machine states according to ANSI/ISA-TR88.00.02-2022 (PackML).
        State : DINT (
            /// OMAC PackMLV2022 state Undefined
            UNDEFINED := DINT#0,
            /// OMAC PackMLV2022 state Clearing
            CLEARING := DINT#1,
            /// OMAC PackMLV2022 state Stopped
            STOPPED := DINT#2,
            /// OMAC PackMLV2022 state Starting
            STARTING := DINT#3,
            /// OMAC PackMLV2022 state Idle
            IDLE := DINT#4,
            /// OMAC PackMLV2022 state Suspended
            SUSPENDED := DINT#5,
            /// OMAC PackMLV2022 state Execute
            EXECUTE := DINT#6,
            /// OMAC PackMLV2022 state Stopping
            STOPPING := DINT#7,
            /// OMAC PackMLV2022 state Aborting
            ABORTING := DINT#8,
            /// OMAC PackMLV2022 state Aborted
            ABORTED := DINT#9,
            /// OMAC PackMLV2022 state Holding
            HOLDING := DINT#10,
            /// OMAC PackMLV2022 state Held
            HELD := DINT#11,
            /// OMAC PackMLV2022 state Unholding
            UNHOLDING := DINT#12,
            /// OMAC PackMLV2022 state Suspending
            SUSPENDING := DINT#13,
            /// OMAC PackMLV2022 state Unsuspending
            UNSUSPENDING := DINT#14,
            /// OMAC PackMLV2022 state Resetting
            RESETTING := DINT#15,
            /// OMAC PackMLV2022 state Completing
            COMPLETING := DINT#16,
            /// OMAC PackMLV2022 state Completed
            COMPLETED := DINT#17
            );
    END_TYPE
END_NAMESPACE
