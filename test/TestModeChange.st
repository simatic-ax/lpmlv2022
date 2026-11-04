USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    // Default configuration: a mode change is only allowed from Stopped, Idle and Aborted; modes 1..8 are enabled.
    {TestFixture}
    CLASS TestModeChangeDefaultConfig
        VAR
            driver : StateMachineDriver;
        END_VAR

        //------------------------------------------------------------------
        // Mode change to Production from every state
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Clearing_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#CLEARING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_ToProduction_Accepted
            driver.ExpectModeAccepted(startState := State#STOPPED, modeValue := Mode#PRODUCTION);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#STARTING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_ToProduction_Accepted
            driver.ExpectModeAccepted(startState := State#IDLE, modeValue := Mode#PRODUCTION);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#SUSPENDED, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#EXECUTE, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#STOPPING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#ABORTING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_ToProduction_Accepted
            driver.ExpectModeAccepted(startState := State#ABORTED, modeValue := Mode#PRODUCTION);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#HOLDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#HELD, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#UNHOLDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#SUSPENDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#UNSUSPENDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#RESETTING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#COMPLETING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_ToProduction_Rejected
            driver.ExpectModeRejected(startState := State#COMPLETED, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_ALLOWED);
        END_METHOD

        //------------------------------------------------------------------
        // Requested mode value, from Stopped
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Maintenance_Accepted
            driver.ExpectModeAccepted(startState := State#STOPPED, modeValue := Mode#MAINTENANCE);
        END_METHOD

        {Test}
        METHOD PUBLIC LastEnabledUserMode_Accepted
            driver.ExpectModeAccepted(startState := State#STOPPED, modeValue := Mode#USER_05);
        END_METHOD

        {Test}
        METHOD PUBLIC FirstDisabledUserMode_NotConfigured
            driver.ExpectModeRejected(startState := State#STOPPED, modeValue := Mode#USER_06, expectedMessage := Message#REQ_MODE_NOT_CONFIGURED);
        END_METHOD

        {Test}
        METHOD PUBLIC LastUserMode_NotConfigured
            driver.ExpectModeRejected(startState := State#STOPPED, modeValue := Mode#USER_28, expectedMessage := Message#REQ_MODE_NOT_CONFIGURED);
        END_METHOD

        {Test}
        METHOD PUBLIC CurrentMode_AlreadyActive
            driver.ExpectModeRejected(startState := State#STOPPED, modeValue := Mode#MANUAL, expectedMessage := Message#MODE_ALREADY_ACTIVE);
        END_METHOD

        {Test}
        METHOD PUBLIC ModeAboveRange_NotDefined
            driver.ExpectModeRejected(startState := State#STOPPED, modeValue := DINT#32, expectedMessage := Message#MODE_NOT_DEFINED);
        END_METHOD

        {Test}
        METHOD PUBLIC ModeBelowRange_NotDefined
            driver.ExpectModeRejected(startState := State#STOPPED, modeValue := DINT#-1, expectedMessage := Message#MODE_NOT_DEFINED);
        END_METHOD

        {Test}
        METHOD PUBLIC ModeFarOutOfRange_NotDefined
            driver.ExpectModeRejected(startState := State#STOPPED, modeValue := DINT#100, expectedMessage := Message#MODE_NOT_DEFINED);
        END_METHOD

        {Test}
        METHOD PUBLIC InvalidMode_Ignored
            driver.ExpectInvalidModeIgnored();
        END_METHOD
    END_CLASS

    // Production disables every optional state and mode changes are allowed from every state:
    // a change is refused wherever the current state does not exist in Production.
    {TestFixture}
    CLASS TestModeChangeTargetStatesDisabled
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            VAR_TEMP
                allStates : DWORD;
                disabled : DWORD;
            END_VAR

            ConfigureModeTransitionCfg(
                Clearing := TRUE,
                Stopped := TRUE,
                Starting := TRUE,
                Idle := TRUE,
                Suspended := TRUE,
                Execute := TRUE,
                Stopping := TRUE,
                Aborting := TRUE,
                Aborted := TRUE,
                Holding := TRUE,
                Held := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Resetting := TRUE,
                Completing := TRUE,
                Completed := TRUE,
                ModeTransitionCfg => allStates);
            driver.sut.config.ModeTransitionCfg[Mode#MANUAL] := allStates;
            driver.sut.config.ModeTransitionCfg[Mode#PRODUCTION] := allStates;

            ConfigureDisabledStatesCfg(
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
                DisabledStatesCfg => disabled);
            driver.sut.config.DisabledStatesCfg[Mode#PRODUCTION] := disabled;
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#CLEARING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_ToProduction_Accepted
            driver.ExpectModeAccepted(startState := State#STOPPED, modeValue := Mode#PRODUCTION);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#STARTING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_ToProduction_Accepted
            driver.ExpectModeAccepted(startState := State#IDLE, modeValue := Mode#PRODUCTION);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#SUSPENDED, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_ToProduction_Accepted
            driver.ExpectModeAccepted(startState := State#EXECUTE, modeValue := Mode#PRODUCTION);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#STOPPING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#ABORTING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_ToProduction_Accepted
            driver.ExpectModeAccepted(startState := State#ABORTED, modeValue := Mode#PRODUCTION);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#HOLDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#HELD, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#UNHOLDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#SUSPENDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#UNSUSPENDING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#RESETTING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#COMPLETING, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_ToProduction_NotPossible
            driver.ExpectModeRejected(startState := State#COMPLETED, modeValue := Mode#PRODUCTION, expectedMessage := Message#MODE_TRANSITION_NOT_POSSIBLE);
        END_METHOD

        {Test}
        METHOD PUBLIC Production_ReportsItsOwnStateConfiguration
            driver.ExpectModeAccepted(startState := State#STOPPED, modeValue := Mode#PRODUCTION);

            Assert.Equal(actual := driver.sut.CurDisabledStates, expected := DWORD#16#0003_FDAA);
            Assert.Equal(actual := driver.sut.curHoldCmdCfg, expected := DWORD#16#0000_0000);
            Assert.Equal(actual := driver.sut.curCompleteCmdCfg, expected := DWORD#16#0000_0000);
        END_METHOD
    END_CLASS

    // A mode whose state configuration breaks the standard is entered, but the configuration is corrected
    // and the correction is reported.
    {TestFixture}
    CLASS TestModeChangeForcedConfig
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            driver.sut.config.DisabledStatesCfg[Mode#PRODUCTION] := DWORD#16#0002_0A74; // Stopped, Idle, Suspended, Execute, Aborted, Held, Completed
            driver.sut.config.DisabledStatesCfg[Mode#MAINTENANCE] := DWORD#16#0000_0004; // Stopped
            driver.sut.config.DisabledStatesCfg[Mode#USER_01] := DWORD#16#0000_0800; // Held, but Holding/Unholding exist
            driver.sut.config.DisabledStatesCfg[Mode#USER_02] := DWORD#16#0000_0020; // Suspended, but Suspending/Unsuspending exist
            driver.sut.config.DisabledStatesCfg[Mode#USER_03] := DWORD#16#0002_0000; // Completed, but Completing exists
            driver.sut.config.DisabledStatesCfg[Mode#USER_04] := DWORD#16#0000_1C00; // Holding, Held and Unholding: consistent
        END_METHOD

        {Test}
        METHOD PUBLIC AllRuleViolations_CorrectedAtOnce
            driver.ExpectModeForced(modeValue := Mode#PRODUCTION, expectedDisabled := DWORD#16#0000_0000);
        END_METHOD

        {Test}
        METHOD PUBLIC StoppedDisabled_Corrected
            driver.ExpectModeForced(modeValue := Mode#MAINTENANCE, expectedDisabled := DWORD#16#0000_0000);
        END_METHOD

        {Test}
        METHOD PUBLIC HeldDisabledWithHolding_Corrected
            driver.ExpectModeForced(modeValue := Mode#USER_01, expectedDisabled := DWORD#16#0000_0000);
        END_METHOD

        {Test}
        METHOD PUBLIC SuspendedDisabledWithSuspending_Corrected
            driver.ExpectModeForced(modeValue := Mode#USER_02, expectedDisabled := DWORD#16#0000_0000);
        END_METHOD

        {Test}
        METHOD PUBLIC CompletedDisabledWithCompleting_Corrected
            driver.ExpectModeForced(modeValue := Mode#USER_03, expectedDisabled := DWORD#16#0000_0000);
        END_METHOD

        {Test}
        METHOD PUBLIC HeldDisabledTogetherWithItsActingStates_Untouched
            driver.ExpectModeAccepted(startState := State#STOPPED, modeValue := Mode#USER_04);

            Assert.Equal(actual := driver.sut.CurDisabledStates, expected := DWORD#16#0000_1C00);
        END_METHOD
    END_CLASS

    // The same correction applies to the mode that is active from the very first cycle.
    {TestFixture}
    CLASS TestFirstCycleForcedConfig
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            driver.sut.config.DisabledStatesCfg[Mode#MANUAL] := DWORD#16#0002_0A74;
        END_METHOD

        {Test}
        METHOD PUBLIC ManualMode_ConfigurationCorrected
            driver.ToStopped();

            Assert.Equal(actual := driver.sut.CurDisabledStates, expected := DWORD#16#0000_0000);
            Assert.Equal(actual := driver.sut.curHoldCmdCfg, expected := DWORD#16#0000_0060);
            Assert.Equal(actual := driver.sut.curCompleteCmdCfg, expected := DWORD#16#0000_0860);
        END_METHOD
    END_CLASS
END_NAMESPACE
