NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        {S7.extern = ReadOnly}
        LPMLV2022_typeDiagnostics : STRUCT
            bufferIndex : INT := -1; // Index of actual buffer entry
            buffer : ARRAY[0..LPMLV2022_LimitConstants#DIAG_BUFFER_UPPER_LIM] OF LPMLV2022_typeDiagnosticsEntry; // Diagnostics information buffer
        END_STRUCT;
    END_TYPE
END_NAMESPACE