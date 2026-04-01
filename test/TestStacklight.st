USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestStacklight
        VAR
            stacklight : Stacklight;
        END_VAR

        {Test}
        METHOD PUBLIC TestStateExecute_NormalOperation
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Execute state with normal operation (no material issues)
            stacklight.StateCurrent := State#EXECUTE;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify individual outputs
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.redFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.amberSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.amberFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.blueSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);      // Running - Green Solid
            Assert.Equal(actual := stacklight.greenFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := FALSE);

            // Verify DWORD output (bit 6 set = 2^6 = 64 = 16#40)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0040);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateExecute_WithMaterialLow
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Execute state with low material
            stacklight.StateCurrent := State#EXECUTE;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);      // Running
            Assert.Equal(actual := stacklight.blueFlashing, expected := TRUE);    // Low material
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := FALSE);

            // Verify DWORD output (bits 5+6 set = 32+64 = 96 = 16#60)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0060);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateIdle_ReadyToStart
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Idle state (ready to start)
            stacklight.StateCurrent := State#IDLE;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.greenFlashing, expected := TRUE);   // Ready to start
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := FALSE);

            // Verify DWORD output (bit 7 set = 2^7 = 128 = 16#80)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0080);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateStarting_WithHorn
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Starting state
            stacklight.StateCurrent := State#STARTING;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);      // Running
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);    // Starting/Restarting
            Assert.Equal(actual := stacklight.greenFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);

            // Verify DWORD output (bits 6+9 set = 64+512 = 576 = 16#240)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0240);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateAborting_AbnormalStop
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Aborting state (abnormal stop)
            stacklight.StateCurrent := State#ABORTING;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.redFlashing, expected := TRUE);     // Abnormal stop
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);

            // Verify DWORD output (bit 1 set = 2^1 = 2 = 16#02)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0002);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateStopped_ControlledStop
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Stopped state (controlled stop)
            stacklight.StateCurrent := State#STOPPED;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);        // Controlled stop
            Assert.Equal(actual := stacklight.redFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);

            // Verify DWORD output (bit 0 set = 2^0 = 1 = 16#01)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0001);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateSuspended_StarvedUpstream
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Suspended state with starved upstream
            stacklight.StateCurrent := State#SUSPENDED;
            stacklight.starvedUpstream := TRUE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.amberFlashing, expected := TRUE);   // Starved upstream
            Assert.Equal(actual := stacklight.amberSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);

            // Verify DWORD output (bit 3 set = 2^3 = 8 = 16#08)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0008);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateSuspended_BlockedDownstream
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Suspended state with blocked downstream
            stacklight.StateCurrent := State#SUSPENDED;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := TRUE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.amberSolid, expected := TRUE);      // Blocked downstream
            Assert.Equal(actual := stacklight.amberFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);

            // Verify DWORD output (bit 2 set = 2^2 = 4 = 16#04)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0004);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateHeld_MaterialExhausted
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Held state with material exhausted
            stacklight.StateCurrent := State#HELD;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := TRUE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.blueSolid, expected := TRUE);       // Material exhausted
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);

            // Verify DWORD output (bit 4 set = 2^4 = 16 = 16#10)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0010);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateUnholding_RestartingWithHorn
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Unholding state (restarting with horn)
            stacklight.StateCurrent := State#UNHOLDING;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);      // Running
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);    // Restarting
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);

            // Verify DWORD output (bits 6+9 set = 64+512 = 576 = 16#240)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0240);

        END_METHOD

        {Test}
        METHOD PUBLIC TestComplexScenario_SuspendedWithAllConditions
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test complex scenario: Suspended with all conditions active
            stacklight.StateCurrent := State#SUSPENDED;
            stacklight.starvedUpstream := TRUE;
            stacklight.blockedDownstream := TRUE;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.amberFlashing, expected := TRUE);   // Starved upstream
            Assert.Equal(actual := stacklight.amberSolid, expected := TRUE);      // Blocked downstream
            Assert.Equal(actual := stacklight.blueFlashing, expected := TRUE);    // Low material
            Assert.Equal(actual := stacklight.blueSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);

            // Verify DWORD output (bits 2+3+5 set = 4+8+32 = 44 = 16#2C)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_002C);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStateCompleting_RunningWithMaterial
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test Completing state
            stacklight.StateCurrent := State#COMPLETING;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            // Verify outputs
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);      // Running
            Assert.Equal(actual := stacklight.blueFlashing, expected := TRUE);    // Low material
            Assert.Equal(actual := stacklight.hornFlashing, expected := FALSE);

            // Verify DWORD output (bits 5+6 set = 32+64 = 96 = 16#60)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0060);

        END_METHOD

        {Test}
        METHOD PUBLIC TestAllAbnormalStates
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test all abnormal stop states (should show red flashing)

            // Test Aborting
            stacklight.StateCurrent := State#ABORTING;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.redFlashing, expected := TRUE);
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);

            // Test Aborted
            stacklight.StateCurrent := State#ABORTED;
            stacklight();
            Assert.Equal(actual := stacklight.redFlashing, expected := TRUE);
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);

            // Test Clearing
            stacklight.StateCurrent := State#CLEARING;
            stacklight();
            Assert.Equal(actual := stacklight.redFlashing, expected := TRUE);
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestAllControlledStopStates
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test all controlled stop states (should show red solid)

            // Test Completed
            stacklight.StateCurrent := State#COMPLETED;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.redFlashing, expected := FALSE);

            // Test Resetting
            stacklight.StateCurrent := State#RESETTING;
            stacklight();
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.redFlashing, expected := FALSE);

            // Test Stopping
            stacklight.StateCurrent := State#STOPPING;
            stacklight();
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.redFlashing, expected := FALSE);

            // Test Stopped
            stacklight.StateCurrent := State#STOPPED;
            stacklight();
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.redFlashing, expected := FALSE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestAllRunningStates
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test all running states (should show green solid)

            // Test Execute
            stacklight.StateCurrent := State#EXECUTE;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.greenFlashing, expected := FALSE);

            // Test Starting
            stacklight.StateCurrent := State#STARTING;
            stacklight();
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

            // Test Completing
            stacklight.StateCurrent := State#COMPLETING;
            stacklight();
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := FALSE);

            // Test Unholding
            stacklight.StateCurrent := State#UNHOLDING;
            stacklight();
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

            // Test Unsuspending
            stacklight.StateCurrent := State#UNSUSPENDING;
            stacklight();
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestHornFlashingStates
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test all states that should trigger horn flashing
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;

            // Starting
            stacklight.StateCurrent := State#STARTING;
            stacklight();
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

            // Unholding
            stacklight.StateCurrent := State#UNHOLDING;
            stacklight();
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

            // Unsuspending
            stacklight.StateCurrent := State#UNSUSPENDING;
            stacklight();
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

            // Other states should not have horn
            stacklight.StateCurrent := State#EXECUTE;
            stacklight();
            Assert.Equal(actual := stacklight.hornFlashing, expected := FALSE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestMaterialConditionsInVariousStates
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test material conditions in states where they should be active

            // Low material in Execute state
            stacklight.StateCurrent := State#EXECUTE;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.blueFlashing, expected := TRUE);
            Assert.Equal(actual := stacklight.blueSolid, expected := FALSE);

            // Material exhausted in Held state
            stacklight.StateCurrent := State#HELD;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := TRUE;
            stacklight();
            Assert.Equal(actual := stacklight.blueSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);

            // Low material should not affect Holding state blue solid logic
            stacklight.StateCurrent := State#HOLDING;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.blueSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestUndefinedState
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test undefined state (should reset all outputs)
            stacklight.StateCurrent := State#UNDEFINED;
            stacklight.starvedUpstream := TRUE;
            stacklight.blockedDownstream := TRUE;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := TRUE;
            stacklight();

            // All outputs should be FALSE for undefined state
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.redFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.amberSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.amberFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.blueSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.greenFlashing, expected := FALSE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := FALSE);

            // Verify DWORD output (no bits set = 0)
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_0000);

        END_METHOD

        {Test}
        METHOD PUBLIC TestStacklightBitMapping
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test that individual outputs correctly map to DWORD bits

            // Test red solid (bit 0)
            stacklight.StateCurrent := State#STOPPED;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.StacklightStatus.%X0, expected := TRUE);
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);

            // Test green flashing (bit 7)
            stacklight.StateCurrent := State#IDLE;
            stacklight();
            Assert.Equal(actual := stacklight.StacklightStatus.%X7, expected := TRUE);
            Assert.Equal(actual := stacklight.greenFlashing, expected := TRUE);

            // Test horn flashing (bit 9)
            stacklight.StateCurrent := State#STARTING;
            stacklight();
            Assert.Equal(actual := stacklight.StacklightStatus.%X9, expected := TRUE);
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestUnusedStacklightBits
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test that unused bits in the DWORD remain zero
            stacklight.StateCurrent := State#STARTING;
            stacklight.starvedUpstream := TRUE;
            stacklight.blockedDownstream := TRUE;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := TRUE;
            stacklight();

            // Verify that unused bits are FALSE
            Assert.Equal(actual := stacklight.StacklightStatus.%X8, expected := FALSE);   // Unused bit 8
            Assert.Equal(actual := stacklight.StacklightStatus.%X10, expected := FALSE);  // Unused bit 10
            Assert.Equal(actual := stacklight.StacklightStatus.%X15, expected := FALSE);  // Unused bit 15
            Assert.Equal(actual := stacklight.StacklightStatus.%X31, expected := FALSE);  // Unused bit 31 (MSB)

        END_METHOD

        {Test}
        METHOD PUBLIC TestANSICompliance_TableVerification
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Verify ANSI compliance based on the comment table in the source code

            // Abnormal Stop: Aborting, Clearing, Aborted -> Red Flashing
            stacklight.StateCurrent := State#ABORTING;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.redFlashing, expected := TRUE);

            // Controlled Stop: Completed, Stopped, Stopping, Resetting -> Red Solid
            stacklight.StateCurrent := State#COMPLETED;
            stacklight();
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);

            // Ready to Start: Idle -> Green Flashing
            stacklight.StateCurrent := State#IDLE;
            stacklight();
            Assert.Equal(actual := stacklight.greenFlashing, expected := TRUE);

            // Running: Starting, Execute, Completing, Unholding, Unsuspending -> Green Solid
            stacklight.StateCurrent := State#EXECUTE;
            stacklight();
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);

            // Starting/Restarting: Starting, Unholding, Unsuspending -> Horn
            stacklight.StateCurrent := State#STARTING;
            stacklight();
            Assert.Equal(actual := stacklight.hornFlashing, expected := TRUE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestSequentialStateCalls
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            // Test that multiple sequential calls work correctly (function block behavior)

            // First call - Execute state
            stacklight.StateCurrent := State#EXECUTE;
            stacklight.starvedUpstream := FALSE;
            stacklight.blockedDownstream := FALSE;
            stacklight.materialLow := FALSE;
            stacklight.materialExhausted := FALSE;
            stacklight();
            Assert.Equal(actual := stacklight.greenSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);

            // Second call - change to Stopped state
            stacklight.StateCurrent := State#STOPPED;
            stacklight();
            Assert.Equal(actual := stacklight.redSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);

            // Third call - change to Idle state
            stacklight.StateCurrent := State#IDLE;
            stacklight();
            Assert.Equal(actual := stacklight.greenFlashing, expected := TRUE);
            Assert.Equal(actual := stacklight.redSolid, expected := FALSE);
            Assert.Equal(actual := stacklight.greenSolid, expected := FALSE);

        END_METHOD

        {Test}
        METHOD PUBLIC TestSuspending
            VAR_TEMP
                expectedStacklight : DWORD;
            END_VAR

            stacklight.StateCurrent := State#SUSPENDING;
            stacklight.starvedUpstream := TRUE;
            stacklight.blockedDownstream := TRUE;
            stacklight.materialLow := TRUE;
            stacklight.materialExhausted := FALSE;
            stacklight();

            Assert.Equal(actual := stacklight.amberFlashing, expected := TRUE);
            Assert.Equal(actual := stacklight.amberSolid, expected := TRUE);
            Assert.Equal(actual := stacklight.blueFlashing, expected := TRUE);
            // Verify DWORD output (bits 2,3,5 set = 16#2C
            Assert.Equal(actual := stacklight.StacklightStatus, expected := DWORD#16#0000_002C);


        END_METHOD

    END_CLASS

END_NAMESPACE