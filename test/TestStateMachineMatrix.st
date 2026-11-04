USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    // Default configuration: every state enabled, Hold considered in Suspended/Execute, Complete in Suspended/Execute/Held.
    // One test per state and control command, plus one per state for the state complete signal (SC).
    {TestFixture}
    CLASS TestStateMachineMatrix
        VAR
            driver : StateMachineDriver;
        END_VAR

        //------------------------------------------------------------------
        // CLEARING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Clearing_Reset_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Start_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Stop_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#STOP);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Hold_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Unhold_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Suspend_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Abort_Accepted
            driver.ExpectAccepted(startState := State#CLEARING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Clear_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_Complete_Rejected
            driver.ExpectRejected(startState := State#CLEARING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Clearing_SC_Completes
            driver.ExpectScCompletes(startState := State#CLEARING, endState := State#STOPPED);
        END_METHOD

        //------------------------------------------------------------------
        // STOPPED
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Stopped_Reset_Accepted
            driver.ExpectAccepted(startState := State#STOPPED, cmd := Command#RESET, endState := State#RESETTING, requested := State#IDLE, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Start_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Stop_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#STOP);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Hold_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Unhold_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Suspend_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Abort_Accepted
            driver.ExpectAccepted(startState := State#STOPPED, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Clear_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_Complete_Rejected
            driver.ExpectRejected(startState := State#STOPPED, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopped_SC_Rejected
            driver.ExpectScRejected(startState := State#STOPPED);
        END_METHOD

        //------------------------------------------------------------------
        // STARTING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Starting_Reset_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Start_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Stop_Accepted
            driver.ExpectAccepted(startState := State#STARTING, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Hold_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Unhold_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Suspend_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Abort_Accepted
            driver.ExpectAccepted(startState := State#STARTING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Clear_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_Complete_Rejected
            driver.ExpectRejected(startState := State#STARTING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Starting_SC_Completes
            driver.ExpectScCompletes(startState := State#STARTING, endState := State#EXECUTE);
        END_METHOD

        //------------------------------------------------------------------
        // IDLE
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Idle_Reset_Rejected
            driver.ExpectRejected(startState := State#IDLE, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Start_Accepted
            driver.ExpectAccepted(startState := State#IDLE, cmd := Command#START, endState := State#STARTING, requested := State#EXECUTE, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Stop_Accepted
            driver.ExpectAccepted(startState := State#IDLE, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Hold_Rejected
            driver.ExpectRejected(startState := State#IDLE, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Unhold_Rejected
            driver.ExpectRejected(startState := State#IDLE, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Suspend_Rejected
            driver.ExpectRejected(startState := State#IDLE, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#IDLE, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Abort_Accepted
            driver.ExpectAccepted(startState := State#IDLE, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Clear_Rejected
            driver.ExpectRejected(startState := State#IDLE, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_Complete_Rejected
            driver.ExpectRejected(startState := State#IDLE, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Idle_SC_Rejected
            driver.ExpectScRejected(startState := State#IDLE);
        END_METHOD

        //------------------------------------------------------------------
        // SUSPENDED
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Suspended_Reset_Rejected
            driver.ExpectRejected(startState := State#SUSPENDED, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Start_Rejected
            driver.ExpectRejected(startState := State#SUSPENDED, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Stop_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Hold_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Unhold_Rejected
            driver.ExpectRejected(startState := State#SUSPENDED, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Suspend_Rejected
            driver.ExpectRejected(startState := State#SUSPENDED, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Unsuspend_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#UNSUSPEND, endState := State#UNSUSPENDING, requested := State#EXECUTE, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Abort_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Clear_Rejected
            driver.ExpectRejected(startState := State#SUSPENDED, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_Complete_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDED, cmd := Command#COMPLETE, endState := State#COMPLETING, requested := State#COMPLETED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspended_SC_Rejected
            driver.ExpectScRejected(startState := State#SUSPENDED);
        END_METHOD

        //------------------------------------------------------------------
        // EXECUTE
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Execute_Reset_Rejected
            driver.ExpectRejected(startState := State#EXECUTE, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Start_Rejected
            driver.ExpectRejected(startState := State#EXECUTE, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Stop_Accepted
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Hold_Accepted
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#HOLD, endState := State#HOLDING, requested := State#HELD, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Unhold_Rejected
            driver.ExpectRejected(startState := State#EXECUTE, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Suspend_Accepted
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#SUSPEND, endState := State#SUSPENDING, requested := State#SUSPENDED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#EXECUTE, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Abort_Accepted
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Clear_Rejected
            driver.ExpectRejected(startState := State#EXECUTE, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_Complete_Accepted
            driver.ExpectAccepted(startState := State#EXECUTE, cmd := Command#COMPLETE, endState := State#COMPLETING, requested := State#COMPLETED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Execute_SC_Rejected
            driver.ExpectScRejected(startState := State#EXECUTE);
        END_METHOD

        //------------------------------------------------------------------
        // STOPPING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Stopping_Reset_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Start_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Stop_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#STOP);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Hold_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Unhold_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Suspend_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Abort_Accepted
            driver.ExpectAccepted(startState := State#STOPPING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Clear_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_Complete_Rejected
            driver.ExpectRejected(startState := State#STOPPING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Stopping_SC_Completes
            driver.ExpectScCompletes(startState := State#STOPPING, endState := State#STOPPED);
        END_METHOD

        //------------------------------------------------------------------
        // ABORTING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Aborting_Reset_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Start_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Stop_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#STOP);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Hold_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Unhold_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Suspend_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Abort_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#ABORT);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Clear_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_Complete_Rejected
            driver.ExpectRejected(startState := State#ABORTING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborting_SC_Completes
            driver.ExpectScCompletes(startState := State#ABORTING, endState := State#ABORTED);
        END_METHOD

        //------------------------------------------------------------------
        // ABORTED
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Aborted_Reset_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Start_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Stop_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#STOP);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Hold_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Unhold_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Suspend_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Abort_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#ABORT);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Clear_Accepted
            driver.ExpectAccepted(startState := State#ABORTED, cmd := Command#CLEAR, endState := State#CLEARING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_Complete_Rejected
            driver.ExpectRejected(startState := State#ABORTED, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Aborted_SC_Rejected
            driver.ExpectScRejected(startState := State#ABORTED);
        END_METHOD

        //------------------------------------------------------------------
        // HOLDING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Holding_Reset_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Start_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Stop_Accepted
            driver.ExpectAccepted(startState := State#HOLDING, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Hold_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Unhold_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Suspend_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Abort_Accepted
            driver.ExpectAccepted(startState := State#HOLDING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Clear_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_Complete_Rejected
            driver.ExpectRejected(startState := State#HOLDING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Holding_SC_Completes
            driver.ExpectScCompletes(startState := State#HOLDING, endState := State#HELD);
        END_METHOD

        //------------------------------------------------------------------
        // HELD
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Held_Reset_Rejected
            driver.ExpectRejected(startState := State#HELD, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Start_Rejected
            driver.ExpectRejected(startState := State#HELD, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Stop_Accepted
            driver.ExpectAccepted(startState := State#HELD, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Hold_Rejected
            driver.ExpectRejected(startState := State#HELD, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Unhold_Accepted
            driver.ExpectAccepted(startState := State#HELD, cmd := Command#UNHOLD, endState := State#UNHOLDING, requested := State#EXECUTE, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Suspend_Rejected
            driver.ExpectRejected(startState := State#HELD, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#HELD, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Abort_Accepted
            driver.ExpectAccepted(startState := State#HELD, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Clear_Rejected
            driver.ExpectRejected(startState := State#HELD, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_Complete_Accepted
            driver.ExpectAccepted(startState := State#HELD, cmd := Command#COMPLETE, endState := State#COMPLETING, requested := State#COMPLETED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Held_SC_Rejected
            driver.ExpectScRejected(startState := State#HELD);
        END_METHOD

        //------------------------------------------------------------------
        // UNHOLDING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Unholding_Reset_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Start_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Stop_Accepted
            driver.ExpectAccepted(startState := State#UNHOLDING, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Hold_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Unhold_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Suspend_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Abort_Accepted
            driver.ExpectAccepted(startState := State#UNHOLDING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Clear_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_Complete_Rejected
            driver.ExpectRejected(startState := State#UNHOLDING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unholding_SC_Completes
            driver.ExpectScCompletes(startState := State#UNHOLDING, endState := State#EXECUTE);
        END_METHOD

        //------------------------------------------------------------------
        // SUSPENDING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Suspending_Reset_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Start_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Stop_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDING, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Hold_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Unhold_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Suspend_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Abort_Accepted
            driver.ExpectAccepted(startState := State#SUSPENDING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Clear_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_Complete_Rejected
            driver.ExpectRejected(startState := State#SUSPENDING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Suspending_SC_Completes
            driver.ExpectScCompletes(startState := State#SUSPENDING, endState := State#SUSPENDED);
        END_METHOD

        //------------------------------------------------------------------
        // UNSUSPENDING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Unsuspending_Reset_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Start_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Stop_Accepted
            driver.ExpectAccepted(startState := State#UNSUSPENDING, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Hold_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Unhold_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Suspend_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Abort_Accepted
            driver.ExpectAccepted(startState := State#UNSUSPENDING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Clear_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_Complete_Rejected
            driver.ExpectRejected(startState := State#UNSUSPENDING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Unsuspending_SC_Completes
            driver.ExpectScCompletes(startState := State#UNSUSPENDING, endState := State#EXECUTE);
        END_METHOD

        //------------------------------------------------------------------
        // RESETTING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Resetting_Reset_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Start_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Stop_Accepted
            driver.ExpectAccepted(startState := State#RESETTING, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Hold_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Unhold_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Suspend_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Abort_Accepted
            driver.ExpectAccepted(startState := State#RESETTING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Clear_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_Complete_Rejected
            driver.ExpectRejected(startState := State#RESETTING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Resetting_SC_Completes
            driver.ExpectScCompletes(startState := State#RESETTING, endState := State#IDLE);
        END_METHOD

        //------------------------------------------------------------------
        // COMPLETING
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Completing_Reset_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#RESET);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Start_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Stop_Accepted
            driver.ExpectAccepted(startState := State#COMPLETING, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Hold_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Unhold_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Suspend_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Abort_Accepted
            driver.ExpectAccepted(startState := State#COMPLETING, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Clear_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_Complete_Rejected
            driver.ExpectRejected(startState := State#COMPLETING, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completing_SC_Completes
            driver.ExpectScCompletes(startState := State#COMPLETING, endState := State#COMPLETED);
        END_METHOD

        //------------------------------------------------------------------
        // COMPLETED
        //------------------------------------------------------------------
        {Test}
        METHOD PUBLIC Completed_Reset_Accepted
            driver.ExpectAccepted(startState := State#COMPLETED, cmd := Command#RESET, endState := State#RESETTING, requested := State#IDLE, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Start_Rejected
            driver.ExpectRejected(startState := State#COMPLETED, cmd := Command#START);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Stop_Accepted
            driver.ExpectAccepted(startState := State#COMPLETED, cmd := Command#STOP, endState := State#STOPPING, requested := State#STOPPED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Hold_Rejected
            driver.ExpectRejected(startState := State#COMPLETED, cmd := Command#HOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Unhold_Rejected
            driver.ExpectRejected(startState := State#COMPLETED, cmd := Command#UNHOLD);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Suspend_Rejected
            driver.ExpectRejected(startState := State#COMPLETED, cmd := Command#SUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Unsuspend_Rejected
            driver.ExpectRejected(startState := State#COMPLETED, cmd := Command#UNSUSPEND);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Abort_Accepted
            driver.ExpectAccepted(startState := State#COMPLETED, cmd := Command#ABORT, endState := State#ABORTING, requested := State#ABORTED, inProcess := TRUE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Clear_Rejected
            driver.ExpectRejected(startState := State#COMPLETED, cmd := Command#CLEAR);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_Complete_Rejected
            driver.ExpectRejected(startState := State#COMPLETED, cmd := Command#COMPLETE);
        END_METHOD

        {Test}
        METHOD PUBLIC Completed_SC_Rejected
            driver.ExpectScRejected(startState := State#COMPLETED);
        END_METHOD
    END_CLASS
END_NAMESPACE
