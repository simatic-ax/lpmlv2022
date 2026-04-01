NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        typeConsiderHoldCmdIn  : STRUCT   // Copied from configuration
            starting  : BOOL;
            idle  : BOOL;
            suspended  : BOOL;
            execute  : BOOL;
            unholding  : BOOL;
            suspending  : BOOL;
            unsuspending  : BOOL;
            completing  : BOOL;
            completed  : BOOL;
      END_STRUCT;
    END_TYPE
END_NAMESPACE