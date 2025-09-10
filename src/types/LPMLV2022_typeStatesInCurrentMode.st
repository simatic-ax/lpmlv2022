NAMESPACE Simatic.Ax.LPMLV2022

TYPE
LPMLV2022_typeStatesInCurrentMode  : Struct   // Copied from configuration
         clearing  : Bool;
         stopped  : Bool;
         starting  : Bool;
         idle  : Bool;
         suspended  : Bool;
         execute  : Bool;
         stopping  : Bool;
         aborting  : Bool;
         aborted  : Bool;
         holding  : Bool;
         held  : Bool;
         unholding  : Bool;
         suspending  : Bool;
         unsuspending  : Bool;
         resetting  : Bool;
         completing  : Bool;
         completed  : Bool;
      END_STRUCT;
    END_TYPE
END_NAMESPACE