NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        {S7.extern = ReadOnly}
        typeDiagnosticsEntry : STRUCT
            /// Timestamp for this entry
            timestamp : DTL;
            /// Current unit mode
            UnitModeCurrent : SINT;
            /// Current state
            StateCurrent : SINT;
            /// Requested unit mode
            UnitMode : SINT;
            /// Request control command
            CntrlCmd : SINT;
            /// State complete signal
            SC : BOOL;
            /// Message for this entry
            message : Message;
        END_STRUCT;
    END_TYPE
END_NAMESPACE