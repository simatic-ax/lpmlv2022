NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        {S7.extern = ReadOnly}
        DTL : STRUCT
            YEAR : UINT := UINT#1970;
            MONTH : USINT := USINT#1;
            DAY : USINT := USINT#1;
            WEEKDAY : USINT := USINT#5;
            HOUR : USINT := USINT#0;
            MINUTE : USINT := USINT#0;
            SECOND: USINT := USINT#0;
            NANOSECOND : UDINT := UDINT#0; 
        END_STRUCT; 
    END_TYPE
END_NAMESPACE