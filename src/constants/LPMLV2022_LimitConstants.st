NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        LimitConstants : INT (
            /// Diagnostics buffer array upper boundary (0-based)
            DIAG_BUFFER_UPPER_LIM := INT#7,
            /// (Number of unit modes - 1) -> Array[0..MODES_UPPER_LIM]
            MODES_UPPER_LIM := INT#8,
            /// (Number of states - 1) -> Array[0..STATES_UPPER_LIM]
            STATES_UPPER_LIM := INT#17,
            /// (Maximum number of unit modes - 1) -> Array[0..MAX_MODES_UPPER_LIM]
            MAX_MODES_UPPER_LIM := INT#31
            );
    END_TYPE
END_NAMESPACE
