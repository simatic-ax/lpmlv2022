NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        LPMLV2022_typeConsiderHoldCmdIn  : Struct   // Copied from configuration
         starting  : Bool;
         idle  : Bool;
         suspended  : Bool;
         execute  : Bool;
         unholding  : Bool;
         suspending  : Bool;
         unsuspending  : Bool;
         completing  : Bool;
         completed  : Bool;
      END_STRUCT;
    END_TYPE
END_NAMESPACE