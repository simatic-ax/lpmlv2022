USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestConfigureHoldCmdCfg

        {Test}
        METHOD PUBLIC TestOnlyStarting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := TRUE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);
            Assert.Equal(actual := result.%X4, expected := FALSE);
            Assert.Equal(actual := result.%X5, expected := FALSE);
            Assert.Equal(actual := result.%X6, expected := FALSE);
            // Verify expected DWORD value (bit 3 set = 2^3 = 8 = 16#08)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0008);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyIdle
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := TRUE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X3, expected := FALSE);
            Assert.Equal(actual := result.%X4, expected := TRUE);
            Assert.Equal(actual := result.%X5, expected := FALSE);
            // Verify expected DWORD value (bit 4 set = 2^4 = 16 = 16#10)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0010);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlySuspended
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := TRUE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);
            Assert.Equal(actual := result.%X6, expected := FALSE);
            // Verify expected DWORD value (bit 5 set = 2^5 = 32 = 16#20)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0020);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyExecute
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := TRUE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X6, expected := TRUE);
            Assert.Equal(actual := result.%X5, expected := FALSE);
            // Verify expected DWORD value (bit 6 set = 2^6 = 64 = 16#40)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0040);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyUnholding
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := TRUE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X12, expected := TRUE);
            Assert.Equal(actual := result.%X13, expected := FALSE);
            // Verify expected DWORD value (bit 12 set = 2^12 = 4096 = 16#1000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_1000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlySuspending
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := TRUE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X13, expected := TRUE);
            Assert.Equal(actual := result.%X12, expected := FALSE);
            Assert.Equal(actual := result.%X14, expected := FALSE);
            // Verify expected DWORD value (bit 13 set = 2^13 = 8192 = 16#2000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_2000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyUnsuspending
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := TRUE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X14, expected := TRUE);
            Assert.Equal(actual := result.%X13, expected := FALSE);
            // Verify expected DWORD value (bit 14 set = 2^14 = 16384 = 16#4000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_4000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyCompleting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := TRUE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X16, expected := TRUE);
            Assert.Equal(actual := result.%X17, expected := FALSE);
            // Verify expected DWORD value (bit 16 set = 2^16 = 65536 = 16#10000)
            Assert.Equal(actual := result, expected := DWORD#16#0001_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyCompleted
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := TRUE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X17, expected := TRUE);
            Assert.Equal(actual := result.%X16, expected := FALSE);
            // Verify expected DWORD value (bit 17 set = 2^17 = 131072 = 16#20000)
            Assert.Equal(actual := result, expected := DWORD#16#0002_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestANSICompliance_SuspendedAndExecute
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test the ANSI/ISA-TR88.00.02-2022 compliant configuration
            // Note: Only 'Suspended' and 'Execute' must be set for compliance
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := TRUE,
                Execute := TRUE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);   // Suspended
            Assert.Equal(actual := result.%X6, expected := TRUE);   // Execute
            Assert.Equal(actual := result.%X3, expected := FALSE);  // Starting
            Assert.Equal(actual := result.%X4, expected := FALSE);  // Idle
            
            // Verify expected DWORD value (bits 5+6 set = 32+64 = 96 = 16#60)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0060);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestCombinationStartingAndIdle
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := TRUE,
                Idle := TRUE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting
            Assert.Equal(actual := result.%X4, expected := TRUE);   // Idle
            Assert.Equal(actual := result.%X5, expected := FALSE);  // Suspended
            
            // Verify expected DWORD value (bits 3+4 set = 8+16 = 24 = 16#18)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0018);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestCombinationHoldingStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test combination of holding-related states
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X12, expected := TRUE);  // Unholding
            Assert.Equal(actual := result.%X13, expected := TRUE);  // Suspending
            Assert.Equal(actual := result.%X14, expected := TRUE);  // Unsuspending
            
            // Verify expected DWORD value (bits 12+13+14 set = 4096+8192+16384 = 28672 = 16#7000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_7000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestCombinationCompletingStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test combination of completing states
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := TRUE,
                Completed := TRUE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X16, expected := TRUE);  // Completing
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed
            
            // Verify expected DWORD value (bits 16+17 set = 65536+131072 = 196608 = 16#30000)
            Assert.Equal(actual := result, expected := DWORD#16#0003_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesEnabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := TRUE,
                Idle := TRUE,
                Suspended := TRUE,
                Execute := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                holdCmdCfg => result);

            // Verify all configured bits are set
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting
            Assert.Equal(actual := result.%X4, expected := TRUE);   // Idle
            Assert.Equal(actual := result.%X5, expected := TRUE);   // Suspended
            Assert.Equal(actual := result.%X6, expected := TRUE);   // Execute
            Assert.Equal(actual := result.%X12, expected := TRUE);  // Unholding
            Assert.Equal(actual := result.%X13, expected := TRUE);  // Suspending
            Assert.Equal(actual := result.%X14, expected := TRUE);  // Unsuspending
            Assert.Equal(actual := result.%X16, expected := TRUE);  // Completing
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed
            
            // Verify expected DWORD value (all configured bits set)
            // bits 3,4,5,6,12,13,14,16,17 = 8+16+32+64+4096+8192+16384+65536+131072 = 225400 = 16#37078
            Assert.Equal(actual := result, expected := DWORD#16#0003_7078);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesDisabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := FALSE,
                Suspended := FALSE,
                Execute := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            // Verify all configured bits are FALSE
            Assert.Equal(actual := result.%X3, expected := FALSE);
            Assert.Equal(actual := result.%X4, expected := FALSE);
            Assert.Equal(actual := result.%X5, expected := FALSE);
            Assert.Equal(actual := result.%X6, expected := FALSE);
            Assert.Equal(actual := result.%X12, expected := FALSE);
            Assert.Equal(actual := result.%X13, expected := FALSE);
            Assert.Equal(actual := result.%X14, expected := FALSE);
            Assert.Equal(actual := result.%X16, expected := FALSE);
            Assert.Equal(actual := result.%X17, expected := FALSE);
            
            // Verify expected DWORD value (no bits set = 0)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestUnusedBitsRemainZero
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test with all configurable states enabled
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := TRUE,
                Idle := TRUE,
                Suspended := TRUE,
                Execute := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                holdCmdCfg => result);

            // Test that unused bits remain 0
            Assert.Equal(actual := result.%X0, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X1, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X2, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X7, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X8, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X9, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X10, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X11, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X15, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X18, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X31, expected := FALSE);  // Unused (MSB)
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestBitMappingVerification
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test specific bit mappings one by one
            
            // Test Starting -> bit 3
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := TRUE,
                Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE,
                Completing := FALSE, Completed := FALSE,
                holdCmdCfg => result);
            Assert.Equal(actual := result.%X3, expected := TRUE);
            Assert.Equal(actual := result, expected := DWORD#16#0000_0008);

            // Test Idle -> bit 4
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE,
                Idle := TRUE, Suspended := FALSE, Execute := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE,
                Completing := FALSE, Completed := FALSE,
                holdCmdCfg => result);
            Assert.Equal(actual := result.%X4, expected := TRUE);
            Assert.Equal(actual := result, expected := DWORD#16#0000_0010);

            // Test Unholding -> bit 12
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Unholding := TRUE,
                Suspending := FALSE, Unsuspending := FALSE,
                Completing := FALSE, Completed := FALSE,
                holdCmdCfg => result);
            Assert.Equal(actual := result.%X12, expected := TRUE);
            Assert.Equal(actual := result, expected := DWORD#16#0000_1000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestHighOrderBitMapping
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test high-order bit mappings (Completing and Completed)
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE,
                Completing := TRUE,
                Completed := FALSE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X16, expected := TRUE);  // Completing -> bit 16
            Assert.Equal(actual := result.%X17, expected := FALSE); // Completed -> bit 17
            Assert.Equal(actual := result, expected := DWORD#16#0001_0000);

            // Test Completed -> bit 17
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE,
                Completing := FALSE,
                Completed := TRUE,
                holdCmdCfg => result);

            Assert.Equal(actual := result.%X16, expected := FALSE); // Completing -> bit 16
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed -> bit 17
            Assert.Equal(actual := result, expected := DWORD#16#0002_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestANSI_ExtendedCompliance
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test ANSI compliance with additional commonly used states
            LPMLV2022_ConfigureHoldCmdCfg(
                Starting := TRUE,
                Idle := TRUE,
                Suspended := TRUE,  // Required for ANSI compliance
                Execute := TRUE,    // Required for ANSI compliance
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                holdCmdCfg => result);

            // Verify ANSI required states
            Assert.Equal(actual := result.%X5, expected := TRUE);   // Suspended (ANSI required)
            Assert.Equal(actual := result.%X6, expected := TRUE);   // Execute (ANSI required)
            
            // Verify additional states
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting
            Assert.Equal(actual := result.%X4, expected := TRUE);   // Idle
            
            // Verify expected DWORD value (bits 3+4+5+6 set = 8+16+32+64 = 120 = 16#78)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0078);
        
        END_METHOD

    END_CLASS

END_NAMESPACE