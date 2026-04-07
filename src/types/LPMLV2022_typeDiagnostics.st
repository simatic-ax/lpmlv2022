NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        {S7.extern = ReadOnly}
        typeDiagnostics : STRUCT
            /// Index of actual buffer entry
            bufferIndex : INT := -1;
            /// Diagnostics information buffer
            buffer : ARRAY[0..LimitConstants#DIAG_BUFFER_UPPER_LIM] OF typeDiagnosticsEntry;
        END_STRUCT;
    END_TYPE
END_NAMESPACE