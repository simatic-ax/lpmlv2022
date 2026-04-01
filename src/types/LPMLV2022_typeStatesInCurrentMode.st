NAMESPACE Simatic.Ax.LPMLV2022

    TYPE
        typeStatesInCurrentMode  : STRUCT   // Copied from configuration
            clearing  : BOOL;
            stopped  : BOOL;
            starting  : BOOL;
            idle  : BOOL;
            suspended  : BOOL;
            execute  : BOOL;
            stopping  : BOOL;
            aborting  : BOOL;
            aborted  : BOOL;
            holding  : BOOL;
            held  : BOOL;
            unholding  : BOOL;
            suspending  : BOOL;
            unsuspending  : BOOL;
            resetting  : BOOL;
            completing  : BOOL;
            completed  : BOOL;
        END_STRUCT;
    END_TYPE
END_NAMESPACE