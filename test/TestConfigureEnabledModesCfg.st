USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestConfigureEnabledModesCfg

        {Test}
        METHOD PUBLIC TestOnlyMandatoryManualMode
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            // Verify only Manual mode (bit 3) is set
            Assert.Equal(actual := result.%X1, expected := FALSE);  // ProductionMode
            Assert.Equal(actual := result.%X2, expected := FALSE);  // MaintenanceMode
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            Assert.Equal(actual := result.%X4, expected := FALSE);  // UserMode01
            
            // Verify expected DWORD value (only bit 3 set = 2^3 = 8 = 16#08)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0008);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyProductionMode
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := TRUE,
                MaintenanceMode := FALSE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X1, expected := TRUE);   // ProductionMode
            Assert.Equal(actual := result.%X2, expected := FALSE);  // MaintenanceMode
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            
            // Verify expected DWORD value (bits 1+3 set = 2+8 = 10 = 16#0A)
            Assert.Equal(actual := result, expected := DWORD#16#0000_000A);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyMaintenanceMode
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := TRUE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X1, expected := FALSE);  // ProductionMode
            Assert.Equal(actual := result.%X2, expected := TRUE);   // MaintenanceMode
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            
            // Verify expected DWORD value (bits 2+3 set = 4+8 = 12 = 16#0C)
            Assert.Equal(actual := result, expected := DWORD#16#0000_000C);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestProductionAndMaintenanceModes
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := TRUE,
                MaintenanceMode := TRUE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X1, expected := TRUE);   // ProductionMode
            Assert.Equal(actual := result.%X2, expected := TRUE);   // MaintenanceMode
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            
            // Verify expected DWORD value (bits 1+2+3 set = 2+4+8 = 14 = 16#0E)
            Assert.Equal(actual := result, expected := DWORD#16#0000_000E);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestFirstFewUserModes
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := TRUE, UserMode02 := TRUE, UserMode03 := TRUE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            Assert.Equal(actual := result.%X4, expected := TRUE);   // UserMode01
            Assert.Equal(actual := result.%X5, expected := TRUE);   // UserMode02
            Assert.Equal(actual := result.%X6, expected := TRUE);   // UserMode03
            Assert.Equal(actual := result.%X7, expected := FALSE);  // UserMode04
            
            // Verify expected DWORD value (bits 3+4+5+6 set = 8+16+32+64 = 120 = 16#78)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0078);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestLastFewUserModes
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := TRUE, UserMode27 := TRUE, UserMode28 := TRUE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            Assert.Equal(actual := result.%X29, expected := TRUE);  // UserMode26
            Assert.Equal(actual := result.%X30, expected := TRUE);  // UserMode27
            Assert.Equal(actual := result.%X31, expected := TRUE);  // UserMode28
            
            // Verify expected DWORD value (bits 3+29+30+31 set = 8+536870912+1073741824+2147483648 = 3757465592 = 16#E0000008)
            Assert.Equal(actual := result, expected := DWORD#16#E000_0008);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestMiddleUserModes
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := TRUE, UserMode14 := TRUE, UserMode15 := TRUE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            Assert.Equal(actual := result.%X16, expected := TRUE);  // UserMode13
            Assert.Equal(actual := result.%X17, expected := TRUE);  // UserMode14
            Assert.Equal(actual := result.%X18, expected := TRUE);  // UserMode15
            
            // Verify expected DWORD value (bits 3+16+17+18 set = 8+65536+131072+262144 = 458760 = 16#70008)
            Assert.Equal(actual := result, expected := DWORD#16#0007_0008);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestEveryOtherUserMode
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := TRUE, UserMode02 := FALSE, UserMode03 := TRUE, UserMode04 := FALSE, UserMode05 := TRUE,
                UserMode06 := FALSE, UserMode07 := TRUE, UserMode08 := FALSE, UserMode09 := TRUE, UserMode10 := FALSE,
                UserMode11 := TRUE, UserMode12 := FALSE, UserMode13 := TRUE, UserMode14 := FALSE, UserMode15 := TRUE,
                UserMode16 := FALSE, UserMode17 := TRUE, UserMode18 := FALSE, UserMode19 := TRUE, UserMode20 := FALSE,
                UserMode21 := TRUE, UserMode22 := FALSE, UserMode23 := TRUE, UserMode24 := FALSE, UserMode25 := TRUE,
                UserMode26 := FALSE, UserMode27 := TRUE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            Assert.Equal(actual := result.%X4, expected := TRUE);   // UserMode01
            Assert.Equal(actual := result.%X5, expected := FALSE);  // UserMode02
            Assert.Equal(actual := result.%X6, expected := TRUE);   // UserMode03
            Assert.Equal(actual := result.%X7, expected := FALSE);  // UserMode04
            Assert.Equal(actual := result.%X30, expected := TRUE);  // UserMode27
            Assert.Equal(actual := result.%X31, expected := FALSE); // UserMode28
            
            // Verify expected DWORD value (alternating pattern + mandatory bit 3)
            Assert.Equal(actual := result, expected := DWORD#16#5555_5558);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllModesEnabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := TRUE,
                MaintenanceMode := TRUE,
                UserMode01 := TRUE, UserMode02 := TRUE, UserMode03 := TRUE, UserMode04 := TRUE, UserMode05 := TRUE,
                UserMode06 := TRUE, UserMode07 := TRUE, UserMode08 := TRUE, UserMode09 := TRUE, UserMode10 := TRUE,
                UserMode11 := TRUE, UserMode12 := TRUE, UserMode13 := TRUE, UserMode14 := TRUE, UserMode15 := TRUE,
                UserMode16 := TRUE, UserMode17 := TRUE, UserMode18 := TRUE, UserMode19 := TRUE, UserMode20 := TRUE,
                UserMode21 := TRUE, UserMode22 := TRUE, UserMode23 := TRUE, UserMode24 := TRUE, UserMode25 := TRUE,
                UserMode26 := TRUE, UserMode27 := TRUE, UserMode28 := TRUE,
                EnabledModesCfg => result);

            // Verify all configurable bits are set
            Assert.Equal(actual := result.%X1, expected := TRUE);   // ProductionMode
            Assert.Equal(actual := result.%X2, expected := TRUE);   // MaintenanceMode
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode (mandatory)
            Assert.Equal(actual := result.%X4, expected := TRUE);   // UserMode01
            Assert.Equal(actual := result.%X31, expected := TRUE);  // UserMode28
            
            // Verify expected DWORD value (all bits 1-31 set except bit 0 = 0xFFFFFFFE)
            Assert.Equal(actual := result, expected := DWORD#16#FFFF_FFFE);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestMandatoryBitAlwaysSet
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test different combinations to ensure Manual mode (bit 3) is always set
            
            // Test 1: All modes disabled
            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode must be set
            
            // Test 2: Only Production enabled
            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := TRUE,
                MaintenanceMode := FALSE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);   // Manual mode must be set
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestUnusedBitZero
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test with all modes enabled to verify bit 0 remains unused
            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := TRUE,
                MaintenanceMode := TRUE,
                UserMode01 := TRUE, UserMode02 := TRUE, UserMode03 := TRUE, UserMode04 := TRUE, UserMode05 := TRUE,
                UserMode06 := TRUE, UserMode07 := TRUE, UserMode08 := TRUE, UserMode09 := TRUE, UserMode10 := TRUE,
                UserMode11 := TRUE, UserMode12 := TRUE, UserMode13 := TRUE, UserMode14 := TRUE, UserMode15 := TRUE,
                UserMode16 := TRUE, UserMode17 := TRUE, UserMode18 := TRUE, UserMode19 := TRUE, UserMode20 := TRUE,
                UserMode21 := TRUE, UserMode22 := TRUE, UserMode23 := TRUE, UserMode24 := TRUE, UserMode25 := TRUE,
                UserMode26 := TRUE, UserMode27 := TRUE, UserMode28 := TRUE,
                EnabledModesCfg => result);

            // Verify bit 0 is not used and remains FALSE
            Assert.Equal(actual := result.%X0, expected := FALSE);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestBitMappingVerification
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test specific bit mappings by enabling only one mode at a time
            
            // Test UserMode01 -> bit 4
            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := TRUE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X4, expected := TRUE);   // UserMode01 -> bit 4
            Assert.Equal(actual := result.%X5, expected := FALSE);  // UserMode02 -> bit 5 (should be false)
            
            // Verify expected DWORD value (bits 3+4 set = 8+16 = 24 = 16#18)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0018);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestHighOrderBitMapping
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test high-order bit mappings
            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := FALSE, UserMode02 := FALSE, UserMode03 := FALSE, UserMode04 := FALSE, UserMode05 := FALSE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := TRUE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X31, expected := TRUE);  // UserMode28 -> bit 31 (MSB)
            Assert.Equal(actual := result.%X30, expected := FALSE); // UserMode27 -> bit 30 (should be false)
            
            // Verify expected DWORD value (bits 3+31 set = 8+2147483648 = 2147483656 = 16#80000008)
            Assert.Equal(actual := result, expected := DWORD#16#8000_0008);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestSequentialUserModes
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test first 5 user modes to verify sequential bit mapping
            LPMLV2022_ConfigureEnabledModesCfg(
                ProductionMode := FALSE,
                MaintenanceMode := FALSE,
                UserMode01 := TRUE, UserMode02 := TRUE, UserMode03 := TRUE, UserMode04 := TRUE, UserMode05 := TRUE,
                UserMode06 := FALSE, UserMode07 := FALSE, UserMode08 := FALSE, UserMode09 := FALSE, UserMode10 := FALSE,
                UserMode11 := FALSE, UserMode12 := FALSE, UserMode13 := FALSE, UserMode14 := FALSE, UserMode15 := FALSE,
                UserMode16 := FALSE, UserMode17 := FALSE, UserMode18 := FALSE, UserMode19 := FALSE, UserMode20 := FALSE,
                UserMode21 := FALSE, UserMode22 := FALSE, UserMode23 := FALSE, UserMode24 := FALSE, UserMode25 := FALSE,
                UserMode26 := FALSE, UserMode27 := FALSE, UserMode28 := FALSE,
                EnabledModesCfg => result);

            Assert.Equal(actual := result.%X4, expected := TRUE);   // UserMode01 -> bit 4
            Assert.Equal(actual := result.%X5, expected := TRUE);   // UserMode02 -> bit 5
            Assert.Equal(actual := result.%X6, expected := TRUE);   // UserMode03 -> bit 6
            Assert.Equal(actual := result.%X7, expected := TRUE);   // UserMode04 -> bit 7
            Assert.Equal(actual := result.%X8, expected := TRUE);   // UserMode05 -> bit 8
            Assert.Equal(actual := result.%X9, expected := FALSE);  // UserMode06 -> bit 9 (should be false)
            
            // Verify expected DWORD value (bits 3+4+5+6+7+8 set = 8+16+32+64+128+256 = 504 = 16#1F8)
            Assert.Equal(actual := result, expected := DWORD#16#0000_01F8);
        
        END_METHOD

    END_CLASS

END_NAMESPACE