USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestConfigureDisabledStatesCfg

        {Test}
        METHOD PUBLIC TestOnlyClearing
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := TRUE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X1, expected := TRUE);
            Assert.Equal(actual := result.%X3, expected := FALSE);
            Assert.Equal(actual := result.%X5, expected := FALSE);
            // Verify expected DWORD value (bit 1 set = 2^1 = 2 = 16#02)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0002);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyStarting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := TRUE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X1, expected := FALSE);
            Assert.Equal(actual := result.%X3, expected := TRUE);
            Assert.Equal(actual := result.%X5, expected := FALSE);
            // Verify expected DWORD value (bit 3 set = 2^3 = 8 = 16#08)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0008);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlySuspended
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := TRUE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);
            // Verify expected DWORD value (bit 5 set = 2^5 = 32 = 16#20)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0020);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyStopping
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := TRUE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X7, expected := TRUE);
            // Verify expected DWORD value (bit 7 set = 2^7 = 128 = 16#80)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0080);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyAborting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := TRUE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X8, expected := TRUE);
            // Verify expected DWORD value (bit 8 set = 2^8 = 256 = 16#100)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0100);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyHolding
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := TRUE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X10, expected := TRUE);
            // Verify expected DWORD value (bit 10 set = 2^10 = 1024 = 16#400)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0400);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyHeld
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := TRUE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X11, expected := TRUE);
            // Verify expected DWORD value (bit 11 set = 2^11 = 2048 = 16#800)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0800);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyUnholding
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := TRUE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X12, expected := TRUE);
            // Verify expected DWORD value (bit 12 set = 2^12 = 4096 = 16#1000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_1000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlySuspending
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := TRUE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X13, expected := TRUE);
            // Verify expected DWORD value (bit 13 set = 2^13 = 8192 = 16#2000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_2000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyUnsuspending
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := TRUE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X14, expected := TRUE);
            // Verify expected DWORD value (bit 14 set = 2^14 = 16384 = 16#4000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_4000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyResetting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := TRUE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X15, expected := TRUE);
            // Verify expected DWORD value (bit 15 set = 2^15 = 32768 = 16#8000)
            Assert.Equal(actual := result, expected := DWORD#16#0000_8000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyCompleting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := TRUE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X16, expected := TRUE);
            // Verify expected DWORD value (bit 16 set = 2^16 = 65536 = 16#10000)
            Assert.Equal(actual := result, expected := DWORD#16#0001_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyCompleted
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := TRUE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X17, expected := TRUE);
            // Verify expected DWORD value (bit 17 set = 2^17 = 131072 = 16#20000)
            Assert.Equal(actual := result, expected := DWORD#16#0002_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestCombinationClearingAndStarting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := TRUE,
                Starting := TRUE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X1, expected := TRUE);
            Assert.Equal(actual := result.%X3, expected := TRUE);
            // Verify expected DWORD value (bits 1+3 set = 2+8 = 10 = 16#0A)
            Assert.Equal(actual := result, expected := DWORD#16#0000_000A);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestCombinationHoldingStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := TRUE,
                Held := TRUE,
                Unholding := TRUE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            Assert.Equal(actual := result.%X10, expected := TRUE);
            Assert.Equal(actual := result.%X11, expected := TRUE);
            Assert.Equal(actual := result.%X12, expected := TRUE);
            // Verify expected DWORD value (bits 10+11+12 set = 1024+2048+4096 = 7168 = 16#1C00)
            Assert.Equal(actual := result, expected := DWORD#16#0000_1C00);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesDisabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := TRUE,
                Starting := TRUE,
                Suspended := TRUE,
                Stopping := TRUE,
                Aborting := TRUE,
                Holding := TRUE,
                Held := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Resetting := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                DisabledStatesCfg => result);

            // Verify all configured bits are set
            Assert.Equal(actual := result.%X1, expected := TRUE);   // Clearing
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting
            Assert.Equal(actual := result.%X5, expected := TRUE);   // Suspended
            Assert.Equal(actual := result.%X7, expected := TRUE);   // Stopping
            Assert.Equal(actual := result.%X8, expected := TRUE);   // Aborting
            Assert.Equal(actual := result.%X10, expected := TRUE);  // Holding
            Assert.Equal(actual := result.%X11, expected := TRUE);  // Held
            Assert.Equal(actual := result.%X12, expected := TRUE);  // Unholding
            Assert.Equal(actual := result.%X13, expected := TRUE);  // Suspending
            Assert.Equal(actual := result.%X14, expected := TRUE);  // Unsuspending
            Assert.Equal(actual := result.%X15, expected := TRUE);  // Resetting
            Assert.Equal(actual := result.%X16, expected := TRUE);  // Completing
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed
            
            // Verify expected DWORD value (all configured bits set)
            // bits 1,3,5,7,8,10,11,12,13,14,15,16,17 = 2+8+32+128+256+1024+2048+4096+8192+16384+32768+65536+131072 = 261546 = 16#3FDAA
            Assert.Equal(actual := result, expected := DWORD#16#0003_FDAA);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesEnabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := FALSE,
                Starting := FALSE,
                Suspended := FALSE,
                Stopping := FALSE,
                Aborting := FALSE,
                Holding := FALSE,
                Held := FALSE,
                Unholding := FALSE,
                Suspending := FALSE,
                Unsuspending := FALSE,
                Resetting := FALSE,
                Completing := FALSE,
                Completed := FALSE,
                DisabledStatesCfg => result);

            // Verify all configured bits are FALSE (states enabled)
            Assert.Equal(actual := result.%X1, expected := FALSE);
            Assert.Equal(actual := result.%X3, expected := FALSE);
            Assert.Equal(actual := result.%X5, expected := FALSE);
            Assert.Equal(actual := result.%X7, expected := FALSE);
            Assert.Equal(actual := result.%X8, expected := FALSE);
            Assert.Equal(actual := result.%X10, expected := FALSE);
            Assert.Equal(actual := result.%X11, expected := FALSE);
            Assert.Equal(actual := result.%X12, expected := FALSE);
            Assert.Equal(actual := result.%X13, expected := FALSE);
            Assert.Equal(actual := result.%X14, expected := FALSE);
            Assert.Equal(actual := result.%X15, expected := FALSE);
            Assert.Equal(actual := result.%X16, expected := FALSE);
            Assert.Equal(actual := result.%X17, expected := FALSE);
            
            // Verify expected DWORD value (no bits set = 0)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAlwaysPresentBitsRemainUnaffected
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test with all states disabled to verify that always-present bits (2,4,6,9) remain 0
            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := TRUE,
                Starting := TRUE,
                Suspended := TRUE,
                Stopping := TRUE,
                Aborting := TRUE,
                Holding := TRUE,
                Held := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Resetting := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                DisabledStatesCfg => result);

            // Verify that the always-present states (Stopped, Idle, Execute, Aborted) 
            // remain FALSE as they cannot be disabled according to the comment
            Assert.Equal(actual := result.%X2, expected := FALSE);  // Stopped - always present
            Assert.Equal(actual := result.%X4, expected := FALSE);  // Idle - always present  
            Assert.Equal(actual := result.%X6, expected := FALSE);  // Execute - always present
            Assert.Equal(actual := result.%X9, expected := FALSE);  // Aborted - always present
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestUnusedBitsRemainZero
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test with all configurable states disabled
            LPMLV2022_ConfigureDisabledStatesCfg(
                Clearing := TRUE,
                Starting := TRUE,
                Suspended := TRUE,
                Stopping := TRUE,
                Aborting := TRUE,
                Holding := TRUE,
                Held := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Resetting := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                DisabledStatesCfg => result);

            // Test that unused bits remain 0
            Assert.Equal(actual := result.%X0, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X18, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X19, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X20, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X25, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X31, expected := FALSE);  // Unused (MSB)
        
        END_METHOD

    END_CLASS

END_NAMESPACE