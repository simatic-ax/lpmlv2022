USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestConfigOutputsDefault
        VAR
            driver : StateMachineDriver;
        END_VAR

        {Test}
        METHOD PUBLIC DefaultConfig_AllStatesPresentAndStandardCommands
            driver.ToStopped();

            Assert.Equal(actual := driver.sut.CurDisabledStates, expected := DWORD#16#0000_0000);
            Assert.Equal(actual := driver.sut.curHoldCmdCfg, expected := DWORD#16#0000_0060);
            Assert.Equal(actual := driver.sut.curCompleteCmdCfg, expected := DWORD#16#0000_0860);
        END_METHOD
    END_CLASS

    // Outputs show what is effective in the active mode, not what was configured.
    {TestFixture}
    CLASS TestConfigOutputsCustom
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            VAR_TEMP
                disabled : DWORD;
                holdCfg : DWORD;
            END_VAR

            ConfigureDisabledStatesCfg(
                Clearing := TRUE,
                Starting := TRUE,
                Stopping := TRUE,
                Resetting := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                DisabledStatesCfg => disabled);
            driver.sut.config.DisabledStatesCfg[Mode#MANUAL] := disabled;

            ConfigureHoldCmdCfg(
                Starting := TRUE,
                Idle := TRUE,
                Suspended := TRUE,
                Execute := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                holdCmdCfg => holdCfg);
            driver.sut.config.holdCmdCfg := holdCfg;
        END_METHOD

        {Test}
        METHOD PUBLIC Manual_HoldOnlyWhereStateExists_CompleteOffWithoutCompleted
            driver.ToStopped();

            Assert.Equal(actual := driver.sut.CurDisabledStates, expected := DWORD#16#0003_808A);
            // Starting, Completing and Completed are disabled and therefore dropped from the Hold configuration
            Assert.Equal(actual := driver.sut.curHoldCmdCfg, expected := DWORD#16#0000_7070);
            Assert.Equal(actual := driver.sut.curCompleteCmdCfg, expected := DWORD#16#0000_0000);
        END_METHOD

        {Test}
        METHOD PUBLIC Production_OutputsFollowActiveMode
            driver.ExpectModeAccepted(startState := State#STOPPED, modeValue := Mode#PRODUCTION);

            Assert.Equal(actual := driver.sut.CurDisabledStates, expected := DWORD#16#0000_0000);
            Assert.Equal(actual := driver.sut.curHoldCmdCfg, expected := DWORD#16#0003_7078);
            Assert.Equal(actual := driver.sut.curCompleteCmdCfg, expected := DWORD#16#0000_0860);
        END_METHOD
    END_CLASS
END_NAMESPACE
