USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestConfigureModeTransitionCfg

        {Test}
        METHOD PUBLIC TestOnlyClearing
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := TRUE,
                Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X1, expected := TRUE);
            Assert.Equal(actual := result.%X2, expected := FALSE);
            // Verify expected DWORD value (bit 1 set = 2^1 = 2 = 16#02)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0002);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyStopped
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE,
                Stopped := TRUE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X2, expected := TRUE);
            Assert.Equal(actual := result.%X1, expected := FALSE);
            // Verify expected DWORD value (bit 2 set = 2^2 = 4 = 16#04)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0004);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyStarting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE,
                Starting := TRUE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X3, expected := TRUE);
            // Verify expected DWORD value (bit 3 set = 2^3 = 8 = 16#08)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0008);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyIdle
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE,
                Idle := TRUE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X4, expected := TRUE);
            // Verify expected DWORD value (bit 4 set = 2^4 = 16 = 16#10)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0010);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlySuspended
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE,
                Suspended := TRUE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);
            // Verify expected DWORD value (bit 5 set = 2^5 = 32 = 16#20)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0020);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyExecute
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE,
                Execute := TRUE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X6, expected := TRUE);
            // Verify expected DWORD value (bit 6 set = 2^6 = 64 = 16#40)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0040);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyStopping
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := TRUE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X7, expected := TRUE);
            // Verify expected DWORD value (bit 7 set = 2^7 = 128 = 16#80)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0080);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyAborting
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := TRUE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X8, expected := TRUE);
            // Verify expected DWORD value (bit 8 set = 2^8 = 256 = 16#100)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0100);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyAborted
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := TRUE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X9, expected := TRUE);
            // Verify expected DWORD value (bit 9 set = 2^9 = 512 = 16#200)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0200);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyHolding
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := TRUE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X10, expected := TRUE);
            // Verify expected DWORD value (bit 10 set = 2^10 = 1024 = 16#400)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0400);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyHeld
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := TRUE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X11, expected := TRUE);
            // Verify expected DWORD value (bit 11 set = 2^11 = 2048 = 16#800)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0800);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestHighOrderStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test Completing and Completed states (bits 16 and 17)
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := TRUE, Completed := TRUE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X16, expected := TRUE);  // Completing
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed
            // Verify expected DWORD value (bits 16+17 set = 65536+131072 = 196608 = 16#30000)
            Assert.Equal(actual := result, expected := DWORD#16#0003_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestBasicStateTransitions
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test basic state transitions: Stopped, Starting, Idle, Execute
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE,
                Stopped := TRUE, Starting := TRUE, Idle := TRUE, Suspended := FALSE, Execute := TRUE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X2, expected := TRUE);   // Stopped
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting
            Assert.Equal(actual := result.%X4, expected := TRUE);   // Idle
            Assert.Equal(actual := result.%X6, expected := TRUE);   // Execute
            
            // Verify expected DWORD value (bits 2+3+4+6 set = 4+8+16+64 = 92 = 16#5C)
            Assert.Equal(actual := result, expected := DWORD#16#0000_005C);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestSuspendingStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test suspending-related states
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE,
                Suspended := TRUE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := TRUE, Unsuspending := TRUE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);   // Suspended
            Assert.Equal(actual := result.%X13, expected := TRUE);  // Suspending
            Assert.Equal(actual := result.%X14, expected := TRUE);  // Unsuspending
            
            // Verify expected DWORD value (bits 5+13+14 set = 32+8192+16384 = 24608 = 16#6020)
            Assert.Equal(actual := result, expected := DWORD#16#0000_6020);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestHoldingStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test holding-related states
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE,
                Holding := TRUE, Held := TRUE, Unholding := TRUE,
                Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X10, expected := TRUE);  // Holding
            Assert.Equal(actual := result.%X11, expected := TRUE);  // Held
            Assert.Equal(actual := result.%X12, expected := TRUE);  // Unholding
            
            // Verify expected DWORD value (bits 10+11+12 set = 1024+2048+4096 = 7168 = 16#1C00)
            Assert.Equal(actual := result, expected := DWORD#16#0000_1C00);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAbortingStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test aborting-related states
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := TRUE, Aborted := TRUE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := TRUE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X8, expected := TRUE);   // Aborting
            Assert.Equal(actual := result.%X9, expected := TRUE);   // Aborted
            Assert.Equal(actual := result.%X15, expected := TRUE);  // Resetting
            
            // Verify expected DWORD value (bits 8+9+15 set = 256+512+32768 = 33536 = 16#8300)
            Assert.Equal(actual := result, expected := DWORD#16#0000_8300);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestCompletingStates
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test completing-related states
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE,
                Execute := TRUE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := TRUE, Completed := TRUE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X6, expected := TRUE);   // Execute
            Assert.Equal(actual := result.%X16, expected := TRUE);  // Completing
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed
            
            // Verify expected DWORD value (bits 6+16+17 set = 64+65536+131072 = 196672 = 16#30040)
            Assert.Equal(actual := result, expected := DWORD#16#0003_0040);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesEnabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := TRUE, Stopped := TRUE, Starting := TRUE, Idle := TRUE, Suspended := TRUE, Execute := TRUE,
                Stopping := TRUE, Aborting := TRUE, Aborted := TRUE, Holding := TRUE, Held := TRUE,
                Unholding := TRUE, Suspending := TRUE, Unsuspending := TRUE, Resetting := TRUE,
                Completing := TRUE, Completed := TRUE,
                ModeTransitionCfg => result);

            // Verify all configured bits are set
            Assert.Equal(actual := result.%X1, expected := TRUE);   // Clearing
            Assert.Equal(actual := result.%X2, expected := TRUE);   // Stopped
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting
            Assert.Equal(actual := result.%X4, expected := TRUE);   // Idle
            Assert.Equal(actual := result.%X5, expected := TRUE);   // Suspended
            Assert.Equal(actual := result.%X6, expected := TRUE);   // Execute
            Assert.Equal(actual := result.%X7, expected := TRUE);   // Stopping
            Assert.Equal(actual := result.%X8, expected := TRUE);   // Aborting
            Assert.Equal(actual := result.%X9, expected := TRUE);   // Aborted
            Assert.Equal(actual := result.%X10, expected := TRUE);  // Holding
            Assert.Equal(actual := result.%X11, expected := TRUE);  // Held
            Assert.Equal(actual := result.%X12, expected := TRUE);  // Unholding
            Assert.Equal(actual := result.%X13, expected := TRUE);  // Suspending
            Assert.Equal(actual := result.%X14, expected := TRUE);  // Unsuspending
            Assert.Equal(actual := result.%X15, expected := TRUE);  // Resetting
            Assert.Equal(actual := result.%X16, expected := TRUE);  // Completing
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed
            
            // Verify expected DWORD value (all configured bits 1-17 set)
            // bits 1-17 = 2+4+8+16+32+64+128+256+512+1024+2048+4096+8192+16384+32768+65536+131072 = 262142 = 16#3FFFE
            Assert.Equal(actual := result, expected := DWORD#16#0003_FFFE);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesDisabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            // Verify all configured bits are FALSE
            Assert.Equal(actual := result.%X1, expected := FALSE);
            Assert.Equal(actual := result.%X2, expected := FALSE);
            Assert.Equal(actual := result.%X3, expected := FALSE);
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
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := TRUE, Stopped := TRUE, Starting := TRUE, Idle := TRUE, Suspended := TRUE, Execute := TRUE,
                Stopping := TRUE, Aborting := TRUE, Aborted := TRUE, Holding := TRUE, Held := TRUE,
                Unholding := TRUE, Suspending := TRUE, Unsuspending := TRUE, Resetting := TRUE,
                Completing := TRUE, Completed := TRUE,
                ModeTransitionCfg => result);

            // Test that unused bits remain 0
            Assert.Equal(actual := result.%X0, expected := FALSE);   // Unused
            Assert.Equal(actual := result.%X18, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X19, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X20, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X25, expected := FALSE);  // Unused
            Assert.Equal(actual := result.%X31, expected := FALSE);  // Unused (MSB)
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestBitMappingVerification
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test specific bit mappings for key states
            
            // Test Clearing -> bit 1
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := TRUE,
                Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);
            Assert.Equal(actual := result.%X1, expected := TRUE);
            Assert.Equal(actual := result, expected := DWORD#16#0000_0002);

            // Test Resetting -> bit 15
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := FALSE, Stopped := FALSE, Starting := FALSE, Idle := FALSE, Suspended := FALSE, Execute := FALSE,
                Stopping := FALSE, Aborting := FALSE, Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE,
                Resetting := TRUE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);
            Assert.Equal(actual := result.%X15, expected := TRUE);
            Assert.Equal(actual := result, expected := DWORD#16#0000_8000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestSequentialLowOrderBits
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test first 8 states to verify sequential bit mapping
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := TRUE, Stopped := TRUE, Starting := TRUE, Idle := TRUE,
                Suspended := TRUE, Execute := TRUE, Stopping := TRUE, Aborting := TRUE,
                Aborted := FALSE, Holding := FALSE, Held := FALSE,
                Unholding := FALSE, Suspending := FALSE, Unsuspending := FALSE, Resetting := FALSE,
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X1, expected := TRUE);   // Clearing -> bit 1
            Assert.Equal(actual := result.%X2, expected := TRUE);   // Stopped -> bit 2
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting -> bit 3
            Assert.Equal(actual := result.%X4, expected := TRUE);   // Idle -> bit 4
            Assert.Equal(actual := result.%X5, expected := TRUE);   // Suspended -> bit 5
            Assert.Equal(actual := result.%X6, expected := TRUE);   // Execute -> bit 6
            Assert.Equal(actual := result.%X7, expected := TRUE);   // Stopping -> bit 7
            Assert.Equal(actual := result.%X8, expected := TRUE);   // Aborting -> bit 8
            Assert.Equal(actual := result.%X9, expected := FALSE);  // Aborted -> bit 9 (should be false)
            
            // Verify expected DWORD value (bits 1-8 set = 2+4+8+16+32+64+128+256 = 510 = 16#1FE)
            Assert.Equal(actual := result, expected := DWORD#16#0000_01FE);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAlternatingPattern
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test alternating pattern of states
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := TRUE, Stopped := FALSE, Starting := TRUE, Idle := FALSE,
                Suspended := TRUE, Execute := FALSE, Stopping := TRUE, Aborting := FALSE,
                Aborted := TRUE, Holding := FALSE, Held := TRUE, Unholding := FALSE,
                Suspending := TRUE, Unsuspending := FALSE, Resetting := TRUE,
                Completing := FALSE, Completed := TRUE,
                ModeTransitionCfg => result);

            // Verify alternating pattern
            Assert.Equal(actual := result.%X1, expected := TRUE);   // Clearing
            Assert.Equal(actual := result.%X2, expected := FALSE);  // Stopped
            Assert.Equal(actual := result.%X3, expected := TRUE);   // Starting
            Assert.Equal(actual := result.%X4, expected := FALSE);  // Idle
            Assert.Equal(actual := result.%X17, expected := TRUE);  // Completed
            Assert.Equal(actual := result.%X16, expected := FALSE); // Completing
            
            // Verify alternating DWORD pattern for bits 1-17
            // Pattern: 10101010101010101 (binary) = 0x2AAAA in hex
            Assert.Equal(actual := result, expected := DWORD#16#0002_AAAA);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestCriticalStateTransitions
            VAR_TEMP
                result : DWORD;
            END_VAR

            // Test critical states that typically need mode transitions
            LPMLV2022_ConfigureModeTransitionCfg(
                Clearing := TRUE,   // After abort/error
                Stopped := TRUE,    // Initial state
                Starting := FALSE, Idle := TRUE,     // Normal operation
                Suspended := FALSE, Execute := FALSE,
                Stopping := TRUE,   // Controlled shutdown
                Aborting := TRUE, Aborted := TRUE,   // Emergency states
                Holding := FALSE, Held := FALSE, Unholding := FALSE,
                Suspending := FALSE, Unsuspending := FALSE,
                Resetting := TRUE,  // Recovery
                Completing := FALSE, Completed := FALSE,
                ModeTransitionCfg => result);

            Assert.Equal(actual := result.%X1, expected := TRUE);   // Clearing
            Assert.Equal(actual := result.%X2, expected := TRUE);   // Stopped
            Assert.Equal(actual := result.%X4, expected := TRUE);   // Idle
            Assert.Equal(actual := result.%X7, expected := TRUE);   // Stopping
            Assert.Equal(actual := result.%X8, expected := TRUE);   // Aborting
            Assert.Equal(actual := result.%X9, expected := TRUE);   // Aborted
            Assert.Equal(actual := result.%X15, expected := TRUE);  // Resetting
            
            // Verify expected DWORD value (bits 1+2+4+7+8+9+15 set)
            // = 2+4+16+128+256+512+32768 = 33686 = 16#8396
            Assert.Equal(actual := result, expected := DWORD#16#0000_8396);
        
        END_METHOD

    END_CLASS

END_NAMESPACE