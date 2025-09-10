NAMESPACE Simatic.Ax.LPMLV2022
  TYPE
    LPMLV2022_PackTag_Constants : UINT(
      COMMAND_PARAMETER_BOOL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with BOOL data type
      COMMAND_PARAMETER_DINT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with DINT data type
      COMMAND_PARAMETER_REAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with REAL data type
      COMMAND_PARAMETER_LREAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with LREAL data type
      COMMAND_PARAMETER_STRING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with STRING data type
      COMMAND_RECIPE_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Information
      COMMAND_PROCESS_VARIABLES_PARAMETER_BOOL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with BOOL data type
      COMMAND_PROCESS_VARIABLES_PARAMETER_DINT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable Information for values with DINT data type
      COMMAND_PROCESS_VARIABLES_PARAMETER_REAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with REAL data type
      COMMAND_PROCESS_VARIABLES_PARAMETER_LREAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with LREAL data type
      COMMAND_PROCESS_VARIABLES_PARAMETER_STRING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with STRING data type
      COMMAND_INGREDIENTS_PARAMETER_BOOL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with BOOL data type
      COMMAND_INGREDIENTS_PARAMETER_DINT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient Information for values with DINT data type
      COMMAND_INGREDIENTS_PARAMETER_REAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with REAL data type
      COMMAND_INGREDIENTS_PARAMETER_LREAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with LREAL data type
      COMMAND_INGREDIENTS_PARAMETER_STRING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with STRING data type
      STATUS_PARAMETER_BOOL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with BOOL data type
      STATUS_PARAMETER_DINT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with DINT data type
      STATUS_PARAMETER_REAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with REAL data type
      STATUS_PARAMETER_LREAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with LREAL data type
      STATUS_PARAMETER_STRING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with STRING data type
      STATUS_RECIPE_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Information
      STATUS_PROCESS_VARIABLES_PARAMETER_BOOL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with BOOL data type
      STATUS_PROCESS_VARIABLES_PARAMETER_DINT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable Information for values with DINT data type
      STATUS_PROCESS_VARIABLES_PARAMETER_REAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with REAL data type
      STATUS_PROCESS_VARIABLES_PARAMETER_LREAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with LREAL data type
      STATUS_PROCESS_VARIABLES_PARAMETER_STRING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Recipe Process Variable information for values with STRING data type
      STATUS_INGREDIENTS_PARAMETER_BOOL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with BOOL data type
      STATUS_INGREDIENTS_PARAMETER_DINT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient Information for values with DINT data type
      STATUS_INGREDIENTS_PARAMETER_REAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with REAL data type
      STATUS_INGREDIENTS_PARAMETER_LREAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with LREAL data type
      STATUS_INGREDIENTS_PARAMETER_STRING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Ingredient information for values with STRING data type
      STATUS_STACK_LIGHT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of Indicator for the current stacklight status
      ADMIN_PARAMETER_BOOL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with BOOL data type
      ADMIN_PARAMETER_DINT_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with DINT data type
      ADMIN_PARAMETER_REAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with REAL data type
      ADMIN_PARAMETER_LREAL_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with LREAL data type
      ADMIN_PARAMETER_STRING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Unit/Machine Parameter information for values with STRING data type
      ADMIN_ALARM_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of Array for Machine Alarms
      ADMIN_ALARM_HISTORY_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of Array for Machine Fault Number and Messaging History
      ADMIN_WARNING_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of Machine warnings for general events that do not cause the machine to stop
      ADMIN_CUMULATIVE_TIMES_UPPER_LIM := UINT#0, //Size [0..UPPER_LIM] of structured Array of Timer Values
      ADMIN_NUMBER_OF_MODES_UPPER_LIM := UINT#8, //Size [0..UPPER_LIM] of structured Array of Mode and State Time Values for each Cumulative Time Tracker
      ADMIN_NUMBER_OF_STATES_UPPER_LIM := UINT#17, //Size [0..UPPER_LIM] of state Time Values for each State in each Mode
      ADMIN_PRODUCT_DATA_UPPER_LIM := UINT#0 //Size [0..UPPER_LIM] of structured array of Product Stream Data
    );
  END_TYPE
END_NAMESPACE