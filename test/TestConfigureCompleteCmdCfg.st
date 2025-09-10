USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestConfigureCompleteCmdCfg

        {Test}
        METHOD PUBLIC TestOnlySuspended
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := TRUE,
                Execute := FALSE,
                Held := FALSE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);
            Assert.Equal(actual := result.%X6, expected := FALSE);
            Assert.Equal(actual := result.%X11, expected := FALSE);
            // Verify expected DWORD value (bit 5 set = 2^5 = 32 = 16#20)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0020);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyExecute
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := FALSE,
                Execute := TRUE,
                Held := FALSE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := FALSE);
            Assert.Equal(actual := result.%X6, expected := TRUE);
            Assert.Equal(actual := result.%X11, expected := FALSE);
            // Verify expected DWORD value (bit 6 set = 2^6 = 64 = 16#40)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0040);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestOnlyHeld
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := FALSE,
                Execute := FALSE,
                Held := TRUE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := FALSE);
            Assert.Equal(actual := result.%X6, expected := FALSE);
            Assert.Equal(actual := result.%X11, expected := TRUE);
            // Verify expected DWORD value (bit 11 set = 2^11 = 2048 = 16#800)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0800);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestSuspendedAndExecute
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := TRUE,
                Execute := TRUE,
                Held := FALSE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);
            Assert.Equal(actual := result.%X6, expected := TRUE);
            Assert.Equal(actual := result.%X11, expected := FALSE);
            // Verify expected DWORD value (bits 5+6 set = 32+64 = 96 = 16#60)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0060);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestSuspendedAndHeld
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := TRUE,
                Execute := FALSE,
                Held := TRUE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);
            Assert.Equal(actual := result.%X6, expected := FALSE);
            Assert.Equal(actual := result.%X11, expected := TRUE);
            // Verify expected DWORD value (bits 5+11 set = 32+2048 = 2080 = 16#820)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0820);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestExecuteAndHeld
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := FALSE,
                Execute := TRUE,
                Held := TRUE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := FALSE);
            Assert.Equal(actual := result.%X6, expected := TRUE);
            Assert.Equal(actual := result.%X11, expected := TRUE);
            // Verify expected DWORD value (bits 6+11 set = 64+2048 = 2112 = 16#840)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0840);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesEnabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := TRUE,
                Execute := TRUE,
                Held := TRUE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := TRUE);
            Assert.Equal(actual := result.%X6, expected := TRUE);
            Assert.Equal(actual := result.%X11, expected := TRUE);
            // Verify expected DWORD value (bits 5+6+11 set = 32+64+2048 = 2144 = 16#860)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0860);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestAllStatesDisabled
            VAR_TEMP
                result : DWORD;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := FALSE,
                Execute := FALSE,
                Held := FALSE,
                completeCmdCfg => result);

            Assert.Equal(actual := result.%X5, expected := FALSE);
            Assert.Equal(actual := result.%X6, expected := FALSE);
            Assert.Equal(actual := result.%X11, expected := FALSE);
            // Verify expected DWORD value (no bits set = 0)
            Assert.Equal(actual := result, expected := DWORD#16#0000_0000);
        
        END_METHOD

        {Test}
        METHOD PUBLIC TestUnusedBitsRemainZero
            VAR_TEMP
                result : DWORD;
                i : INT;
            END_VAR

            LPMLV2022_ConfigureCompleteCmdCfg(
                Suspended := TRUE,
                Execute := TRUE,
                Held := TRUE,
                completeCmdCfg => result);

            // Test that only the expected bits (5, 6, 11) are set
            // and all other bits remain 0
            FOR i := 0 TO 31 DO
                IF i = 5 OR i = 6 OR i = 11 THEN
                    // These bits should be TRUE
                    CONTINUE;
                ELSE
                    // All other bits should be FALSE
                    CASE i OF
                        0: Assert.Equal(actual := result.%X0, expected := FALSE);
                        1: Assert.Equal(actual := result.%X1, expected := FALSE);
                        2: Assert.Equal(actual := result.%X2, expected := FALSE);
                        3: Assert.Equal(actual := result.%X3, expected := FALSE);
                        4: Assert.Equal(actual := result.%X4, expected := FALSE);
                        7: Assert.Equal(actual := result.%X7, expected := FALSE);
                        8: Assert.Equal(actual := result.%X8, expected := FALSE);
                        9: Assert.Equal(actual := result.%X9, expected := FALSE);
                        10: Assert.Equal(actual := result.%X10, expected := FALSE);
                        12: Assert.Equal(actual := result.%X12, expected := FALSE);
                        13: Assert.Equal(actual := result.%X13, expected := FALSE);
                        14: Assert.Equal(actual := result.%X14, expected := FALSE);
                        15: Assert.Equal(actual := result.%X15, expected := FALSE);
                        // Testing a few more significant bits
                        16: Assert.Equal(actual := result.%X16, expected := FALSE);
                        20: Assert.Equal(actual := result.%X20, expected := FALSE);
                        31: Assert.Equal(actual := result.%X31, expected := FALSE);
                    END_CASE;
                END_IF;
            END_FOR;
        
        END_METHOD
    END_CLASS

END_NAMESPACE
