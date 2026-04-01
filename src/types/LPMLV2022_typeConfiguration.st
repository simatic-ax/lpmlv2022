NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        {S7.extern = ReadWrite}
        typeConfiguration : STRUCT
            /// Bit locations within the DWORD represent Mode numbers. A value of 1 in a bit location [0-31] indicates that the corresponding Mode number is enabled. Mode 0 is an Invalid Mode, therefore bit 0 is unused
            EnabledModesCfg : DWORD := DWORD#16#0000_01FE;
            /// The array index represents the Mode number. Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that the corresponding state number is disabled. State 0 is an Undefined State, therefore bit 0 is unused
            DisabledStatesCfg : ARRAY[0..LimitConstants#MAX_MODES_UPPER_LIM] OF DWORD;
            /// The array index represents the Mode number. Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that a mode transition from the corresponding state number is allowed
            ModeTransitionCfg : ARRAY[0..LimitConstants#MAX_MODES_UPPER_LIM] OF DWORD;
            /// Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that the Hold control command is taken into account in the corresponding state. Note: a state change is only performed if the Holding/Held states are not disabled. The 'holdCmdCfg' can only be activated for the following states: Idle, Starting, Execute, Completing, Completed, Suspending, Suspended, Unsuspending, Unholding
            holdCmdCfg : DWORD := DWORD#16#0000_0060;
            /// Bit locations within the DWORD value represent State numbers. A value of 1 in a bit location indicates that the Complete control command is taken into account in the corresponding state. Note: a state change is only performed if the Completing/Completed states are not disabled. The 'completeCmdCfg' can only be activated for the following states: Execute, Suspended, Held
            completeCmdCfg : DWORD := DWORD#16#0000_0860;
        END_STRUCT;
    END_TYPE
END_NAMESPACE