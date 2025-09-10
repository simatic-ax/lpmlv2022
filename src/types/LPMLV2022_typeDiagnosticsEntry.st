NAMESPACE Simatic.Ax.LPMLV2022
    TYPE 
        {S7.extern = ReadOnly}
        LPMLV2022_typeDiagnosticsEntry : STRUCT
            timestamp : DTL; // Timestamp for this entry
            UnitModeCurrent : SINT; // Current unit mode
            StateCurrent : SINT; // Current state
            UnitMode : SINT; // Requested unit mode
            CntrlCmd : SINT; // Request control command
            SC : BOOL; // State complete signal
            message : BYTE; // Message for this entry
        END_STRUCT;
    END_TYPE
END_NAMESPACE