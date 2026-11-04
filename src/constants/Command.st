NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        /// Control commands according to ANSI/ISA-TR88.00.02-2022 (PackML).
        Command : DINT (
            /// OMAC PackMLV2022 control command Undefined
            UNDEFINED := DINT#0,
            /// OMAC PackMLV2022 control command Reset
            RESET := DINT#1,
            /// OMAC PackMLV2022 control command Start
            START := DINT#2,
            /// OMAC PackMLV2022 control command Stop
            STOP := DINT#3,
            /// OMAC PackMLV2022 control command Hold
            HOLD := DINT#4,
            /// OMAC PackMLV2022 control command Unhold
            UNHOLD := DINT#5,
            /// OMAC PackMLV2022 control command Suspend
            SUSPEND := DINT#6,
            /// OMAC PackMLV2022 control command Unsuspend
            UNSUSPEND := DINT#7,
            /// OMAC PackMLV2022 control command Abort
            ABORT := DINT#8,
            /// OMAC PackMLV2022 control command Clear
            CLEAR := DINT#9,
            /// OMAC PackMLV2022 control command Complete
            COMPLETE := DINT#10
            );
    END_TYPE
END_NAMESPACE
