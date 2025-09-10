NAMESPACE Simatic.Ax.LPMLV2022
///================================================================================
/// SIEMENS AG
/// (c)Copyright 2025 All Rights Reserved
///--------------------------------------------------------------------------------
/// Library: LPMLV2022
/// Engineering: SIMATIC AX
/// Restrictions: -
/// Requirements: S7-1500 FW 2.6
/// Functionality: The function generates the unit mode configuration as DWord.
///================================================================================
FUNCTION LPMLV2022_ConfigureEnabledModesCfg
    VAR_INPUT
        ProductionMode : BOOL; // TRUE: Enable unit mode Production
        MaintenanceMode : BOOL; // TRUE: Enable unit mode Maintenance
        UserMode01 : BOOL; // TRUE: Enable user-defined unit mode 01
        UserMode02 : BOOL; // TRUE: Enable user-defined unit mode 02
        UserMode03 : BOOL; // TRUE: Enable user-defined unit mode 03
        UserMode04 : BOOL; // TRUE: Enable user-defined unit mode 04
        UserMode05 : BOOL; // TRUE: Enable user-defined unit mode 05
        UserMode06 : BOOL; // TRUE: Enable user-defined unit mode 06
        UserMode07 : BOOL; // TRUE: Enable user-defined unit mode 07
        UserMode08 : BOOL; // TRUE: Enable user-defined unit mode 08
        UserMode09 : BOOL; // TRUE: Enable user-defined unit mode 09
        UserMode10 : BOOL; // TRUE: Enable user-defined unit mode 10
        UserMode11 : BOOL; // TRUE: Enable user-defined unit mode 11
        UserMode12 : BOOL; // TRUE: Enable user-defined unit mode 12
        UserMode13 : BOOL; // TRUE: Enable user-defined unit mode 13
        UserMode14 : BOOL; // TRUE: Enable user-defined unit mode 14
        UserMode15 : BOOL; // TRUE: Enable user-defined unit mode 15
        UserMode16 : BOOL; // TRUE: Enable user-defined unit mode 16
        UserMode17 : BOOL; // TRUE: Enable user-defined unit mode 17
        UserMode18 : BOOL; // TRUE: Enable user-defined unit mode 18
        UserMode19 : BOOL; // TRUE: Enable user-defined unit mode 19
        UserMode20 : BOOL; // TRUE: Enable user-defined unit mode 20
        UserMode21 : BOOL; // TRUE: Enable user-defined unit mode 21
        UserMode22 : BOOL; // TRUE: Enable user-defined unit mode 22
        UserMode23 : BOOL; // TRUE: Enable user-defined unit mode 23
        UserMode24 : BOOL; // TRUE: Enable user-defined unit mode 24
        UserMode25 : BOOL; // TRUE: Enable user-defined unit mode 25
        UserMode26 : BOOL; // TRUE: Enable user-defined unit mode 26
        UserMode27 : BOOL; // TRUE: Enable user-defined unit mode 27
        UserMode28 : BOOL; // TRUE: Enable user-defined unit mode 28
    END_VAR

    VAR_OUTPUT
        EnabledModesCfg : DWORD;
    END_VAR


    // Initialize unitMode configuration
    EnabledModesCfg := DWORD#16#0000_0008; // Note: mode Manual (EnabledModesCfg.%X3) is mandatory

    // Set unitMode configuration
    EnabledModesCfg.%X1 := ProductionMode;
    EnabledModesCfg.%X2 := MaintenanceMode;
    EnabledModesCfg.%X4 := UserMode01;
    EnabledModesCfg.%X5 := UserMode02;
    EnabledModesCfg.%X6 := UserMode03;
    EnabledModesCfg.%X7 := UserMode04;
    EnabledModesCfg.%X8 := UserMode05;
    EnabledModesCfg.%X9 := UserMode06;
    EnabledModesCfg.%X10 := UserMode07;
    EnabledModesCfg.%X11 := UserMode08;
    EnabledModesCfg.%X12 := UserMode09;
    EnabledModesCfg.%X13 := UserMode10;
    EnabledModesCfg.%X14 := UserMode11;
    EnabledModesCfg.%X15 := UserMode12;
    EnabledModesCfg.%X16 := UserMode13;
    EnabledModesCfg.%X17 := UserMode14;
    EnabledModesCfg.%X18 := UserMode15;
    EnabledModesCfg.%X19 := UserMode16;
    EnabledModesCfg.%X20 := UserMode17;
    EnabledModesCfg.%X21 := UserMode18;
    EnabledModesCfg.%X22 := UserMode19;
    EnabledModesCfg.%X23 := UserMode20;
    EnabledModesCfg.%X24 := UserMode21;
    EnabledModesCfg.%X25 := UserMode22;
    EnabledModesCfg.%X26 := UserMode23;
    EnabledModesCfg.%X27 := UserMode24;
    EnabledModesCfg.%X28 := UserMode25;
    EnabledModesCfg.%X29 := UserMode26;
    EnabledModesCfg.%X30 := UserMode27;
    EnabledModesCfg.%X31 := UserMode28;

END_FUNCTION

END_NAMESPACE