USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    // Acting states disabled: every command jumps straight to the stable target state.
    {TestFixture}
    CLASS TestStateMachineActingStatesDisabled
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            VAR_TEMP
                disabled : DWORD;
            END_VAR

            ConfigureDisabledStatesCfg(
                Clearing := TRUE,
                Starting := TRUE,
                Stopping := TRUE,
                Aborting := TRUE,
                Holding := TRUE,
                Unholding := TRUE,
                Suspending := TRUE,
                Unsuspending := TRUE,
                Resetting := TRUE,
                Completing := TRUE,
                DisabledStatesCfg => disabled);
            driver.sut.config.DisabledStatesCfg[Mode#MANUAL] := disabled;
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Reset_GoesToIdle
            driver.ExpectAccepted(startState := State#STOPPED, cmd := Command#RESET, endState := State#IDLE, requested := State#IDLE, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Abort_GoesToAborted
            driver.ExpectAccepted(startState := State#STOPPED, cmd := Command#ABORT, endState := State#ABORTED, requested := State#ABORTED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Start_GoesToExecute
            driver.ExpectAccepted(startState := State#IDLE, cmd := Command#START, endState := State#EXECUTE, requested := State#EXECUTE, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Stop_GoesToStopped
            driver.ExpectAccepted(startState := State#IDLE, cmd := Command#STOP, endState := State#STOPPED, requested := State#STOPPED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Abort_GoesToAborted
            driver.ExpectAccepted(startState := State#IDLE, cmd := Command#ABORT, endState := State#ABORTED, requested := State#ABORTED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Hold_GoesToHeld
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#HOLD, endState := State#HELD, requested := State#HELD, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Suspend_GoesToSuspended
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#SUSPEND, endState := State#SUSPENDED, requested := State#SUSPENDED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Complete_GoesToCompleted
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#COMPLETE, endState := State#COMPLETED, requested := State#COMPLETED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Stop_GoesToStopped
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#STOP, endState := State#STOPPED, requested := State#STOPPED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Abort_GoesToAborted
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#ABORT, endState := State#ABORTED, requested := State#ABORTED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Unsuspend_GoesToExecute
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#UNSUSPEND, endState := State#EXECUTE, requested := State#EXECUTE, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Hold_GoesToHeld
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#HOLD, endState := State#HELD, requested := State#HELD, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Complete_GoesToCompleted
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#COMPLETE, endState := State#COMPLETED, requested := State#COMPLETED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Unhold_GoesToExecute
            driver.ExpectAccepted(startState := State#HELD, cmd := Command#UNHOLD, endState := State#EXECUTE, requested := State#EXECUTE, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Complete_GoesToCompleted
            driver.ExpectAccepted(startState := State#HELD, cmd := Command#COMPLETE, endState := State#COMPLETED, requested := State#COMPLETED, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Reset_GoesToIdle
            driver.ExpectAccepted(startState := State#COMPLETED, cmd := Command#RESET, endState := State#IDLE, requested := State#IDLE, inProcess := FALSE);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Clear_GoesToStopped
            driver.ExpectAccepted(startState := State#ABORTED, cmd := Command#CLEAR, endState := State#STOPPED, requested := State#STOPPED, inProcess := FALSE);
        END_METHOD
    END_CLASS

    // Hold configured for every state the standard allows: Hold starts Holding from each of them.
    {TestFixture}
    CLASS TestStateMachineHoldEverywhere
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            VAR_TEMP
                holdCfg : DWORD;
            END_VAR

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
        METHOD PUBLIC Starting_Hold_Accepted
            driver.ExpectAccepted(startState := State#STARTING, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Hold_Accepted
            driver.ExpectAccepted(startState := State#IDLE, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Hold_Accepted
            driver.ExpectAccepted(startState := State#UNHOLDING, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Hold_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDING, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Hold_Accepted
            driver.ExpectAccepted(startState := State#UNSUSPENDING, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Hold_Accepted
            driver.ExpectAccepted(startState := State#COMPLETING, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Hold_Accepted
            driver.ExpectAccepted(startState := State#COMPLETED, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_HoldWithSC_HoldWins
            driver.ExpectHoldOverridesSc(startState := State#STARTING);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_HoldWithSC_HoldWins
            driver.ExpectHoldOverridesSc(startState := State#UNHOLDING);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_HoldWithSC_HoldWins
            driver.ExpectHoldOverridesSc(startState := State#SUSPENDING);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_HoldWithSC_HoldWins
            driver.ExpectHoldOverridesSc(startState := State#UNSUSPENDING);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_HoldWithSC_HoldWins
            driver.ExpectHoldOverridesSc(startState := State#COMPLETING);
        END_METHOD
    END_CLASS

    // Hold configured for no state: Hold is rejected even where the default allows it.
    {TestFixture}
    CLASS TestStateMachineHoldNowhere
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            driver.sut.config.holdCmdCfg := DWORD#16#0000_0000;
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Hold_Rejected
            driver.ExpectRejected(startState := State#EXECUTE, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Hold_Rejected
            driver.ExpectRejected(startState := State#SUSPENDED, cmd := Command#HOLD);
        END_METHOD
    END_CLASS

    // Complete configured for no state: Complete is rejected even where the default allows it.
    {TestFixture}
    CLASS TestStateMachineCompleteNowhere
        VAR
            driver : StateMachineDriver;
        END_VAR

        {TestSetup}
        METHOD PUBLIC Setup
            driver.sut.config.completeCmdCfg := DWORD#16#0000_0000;
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Complete_Rejected
            driver.ExpectRejected(startState := State#EXECUTE, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Complete_Rejected
            driver.ExpectRejected(startState := State#SUSPENDED, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Complete_Rejected
            driver.ExpectRejected(startState := State#HELD, cmd := Command#COMPLETE);
        END_METHOD
    END_CLASS
END_NAMESPACE
