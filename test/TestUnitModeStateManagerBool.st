USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestInitialState
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestInitState
            VAR_TEMP
                i : INT;
            END_VAR

            // Test initial state - should be INVALID mode and UNDEFINED state
            unitModeManager();

            // Verify initial outputs
            Assert.Equal(actual := unitModeManager.UnitModeCurrent, expected := LPMLV2022_ModeConstants#MODE_MANUAL);
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_STOPPED);

            // Verify all mode active flags are FALSE initially
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.ManualModeActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.UserMode01Active, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UserMode02Active, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UserMode03Active, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UserMode04Active, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UserMode05Active, expected := FALSE);

            // Verify all state active flags are FALSE initially
            Assert.Equal(actual := unitModeManager.ClearingStateActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.StoppedStateActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.StartingStateActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.IdleStateActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.ExecuteStateActive, expected := FALSE);

            // Verify error flags are FALSE initially
            Assert.Equal(actual := unitModeManager.unitModeChangeNotAllowed, expected := FALSE);
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestProductionModeRequest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestProductionModeRequest_RisingEdge
            VAR_TEMP
                i : UINT;
            END_VAR
            
            // Test rising edge detection for Production mode request
            unitModeManager.ProductionModeRequest := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR; // First cycle - initialize

            // No change yet
            Assert.Equal(actual := unitModeManager.UnitModeCurrent, expected := LPMLV2022_ModeConstants#MODE_MANUAL);
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);

            // Rising edge - should trigger mode change
            unitModeManager.ProductionModeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Should now be in Production mode
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.ManualModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.StoppedStateActive, expected := TRUE);

            // Keep input high - should not trigger again
            unitModeManager.ProductionModeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := TRUE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestManualModeRequest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        

        {Test}
        METHOD PUBLIC TestManualModeRequest_RisingEdge
            VAR_TEMP
                i : UINT;
            END_VAR
            // Test rising edge detection for Manual mode request
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  // First cycle
            END_FOR;
            
            // Rising edge for Manual mode
            unitModeManager.ManualModeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Should be in Manual mode
            Assert.Equal(actual := unitModeManager.ManualModeActive, expected := TRUE); // active after initalization
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.unitModeChangeNotAllowed, expected := TRUE);

            unitModeManager.ManualModeRequest := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.unitModeChangeNotAllowed, expected := FALSE);

            // Rising edge - should trigger mode change
            unitModeManager.ProductionModeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            // Should now be in Production mode
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.ManualModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.StoppedStateActive, expected := TRUE);

            unitModeManager.ProductionModeRequest := FALSE;
            unitModeManager.ManualModeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Should now be in Manual mode
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.ManualModeActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.StoppedStateActive, expected := TRUE);


        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestMaintenanceModeRequest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestMaintenanceModeRequest_RisingEdge
            VAR_TEMP
                i : UINT;
            END_VAR
            
            unitModeManager();  // First cycle

            // Rising edge for Maintenance mode
            unitModeManager.MaintenanceModeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Should be in Maintenance mode
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.ManualModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UnitModeCurrent, expected := LPMLV2022_ModeConstants#MODE_MAINTENANCE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestUserModeRequests
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestUserModeRequests_RisingEdge
            VAR_TEMP
                i : UINT;
            END_VAR
            
            unitModeManager();  // First cycle


            // Test UserMode01
            unitModeManager.UserMode01Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.UserMode01Active, expected := TRUE);
            Assert.Equal(actual := unitModeManager.UserMode02Active, expected := FALSE);

            // Reset
            unitModeManager.UserMode01Request := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Test UserMode02
            unitModeManager.UserMode02Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.UserMode02Active, expected := TRUE);
            Assert.Equal(actual := unitModeManager.UserMode01Active, expected := FALSE);

            // Reset and test UserMode03
            unitModeManager.UserMode02Request := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            unitModeManager.UserMode03Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.UserMode03Active, expected := TRUE);

            // Test UserMode04
            unitModeManager.UserMode03Request := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            unitModeManager.UserMode04Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.UserMode04Active, expected := TRUE);

            // Test UserMode05
            unitModeManager.UserMode04Request := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            unitModeManager.UserMode05Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.UserMode05Active, expected := TRUE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestModePriorityManualHighest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestModePriority_ManualHighest
            VAR_TEMP
                i : UINT;
            END_VAR
            
            unitModeManager();  // First cycle

            // Simultaneous requests - Manual should have highest priority
            unitModeManager.ProductionModeRequest := TRUE;
            unitModeManager.MaintenanceModeRequest := TRUE;
            unitModeManager.ManualModeRequest := TRUE;
            unitModeManager.UserMode01Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Manual should win due to highest priority
            Assert.Equal(actual := unitModeManager.ManualModeActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UserMode01Active, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestModePriorityMaintenanceSecond
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestModePriority_MaintenanceSecond
            VAR_TEMP
                i : UINT;
            END_VAR
            
            unitModeManager();  // First cycle


            // Simultaneous requests without Manual - Maintenance should have priority
            unitModeManager.ProductionModeRequest := TRUE;
            unitModeManager.MaintenanceModeRequest := TRUE;
            unitModeManager.UserMode01Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Maintenance should win
            Assert.Equal(actual := unitModeManager.MaintenanceModeActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UserMode01Active, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestModePriorityUserModeBeforeProduction
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestModePriority_UserModeBeforeProduction
            VAR_TEMP
                i : UINT;
            END_VAR
            
            unitModeManager();  // First cycle
            

            // UserMode vs Production - UserMode should have priority
            unitModeManager.ProductionModeRequest := TRUE;
            unitModeManager.UserMode01Request := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // UserMode01 should win over Production
            Assert.Equal(actual := unitModeManager.UserMode01Active, expected := TRUE);
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := FALSE);
        
        END_METHOD
    END_CLASS
(*
    {TestFixture}
    CLASS TestModePriorityUserModeOrder
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestModePriority_UserModeOrder
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Multiple UserModes - should follow order UserMode01, 02, 03, 04, 05
            unitModeManager.UserMode05Request := TRUE;
            unitModeManager.UserMode03Request := TRUE;
            unitModeManager.UserMode01Request := TRUE;
            unitModeManager();

            // UserMode01 should win (highest priority among user modes)
            Assert.Equal(actual := unitModeManager.UserMode01Active, expected := TRUE);
            Assert.Equal(actual := unitModeManager.UserMode03Active, expected := FALSE);
            Assert.Equal(actual := unitModeManager.UserMode05Active, expected := FALSE);
        
        END_METHOD
    END_CLASS
*)
    {TestFixture}
    CLASS TestResetCommandRequest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestResetCommandRequest_RisingEdge
            VAR_TEMP
                i : UINT;
            END_VAR
            
            unitModeManager();  // First cycle

            // Test rising edge detection for Reset command
            unitModeManager.ResetCmdRequest := FALSE;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.ResetCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Command should have been processed (verify through internal state manager)
            // Keep input high - should not trigger again
            unitModeManager.ResetCmdRequest := TRUE;
            unitModeManager();

            // Should not cause issues with repeated high input
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_RESETTING);
            Assert.Equal(actual := unitModeManager.ResettingStateActive, expected := TRUE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestStoppedToIdle
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestStopedToIdleSequence
            VAR_TEMP
                i : UINT;
            END_VAR
            
            unitModeManager();  // First cycle

            // Test rising edge detection for Reset command
            unitModeManager.ResetCmdRequest := FALSE;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.ResetCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            unitModeManager.ResetCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;

            // Should not cause issues with repeated high input
            Assert.Equal(actual := unitModeManager.IdleStateActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_IDLE);       
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestCompleteStateModel
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR
        
        {Test}
        METHOD PUBLIC TestStateModel
            VAR_TEMP
                i : UINT;
            END_VAR
            unitModeManager();  // First cycle

            // Test rising edge detection for Reset command
            unitModeManager.ResetCmdRequest := FALSE;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.ResetCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            unitModeManager.ResetCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            // IDLE
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.IdleStateActive, expected := TRUE);
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_IDLE);


            unitModeManager.SC := FALSE;
            unitModeManager.StartCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_STARTING);
            Assert.Equal(actual := unitModeManager.StartingStateActive, expected := TRUE);

            unitModeManager.StartCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_EXECUTE);
            Assert.Equal(actual := unitModeManager.ExecuteStateActive, expected := TRUE);

            unitModeManager.SC := FALSE;
            unitModeManager.SuspendCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_SUSPENDING);
            Assert.Equal(actual := unitModeManager.SuspendingStateActive, expected := TRUE);

            unitModeManager.SuspendCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_SUSPENDED);
            Assert.Equal(actual := unitModeManager.SuspendedStateActive, expected := TRUE);

            unitModeManager.SC := FALSE;
            unitModeManager.UnsuspendCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_UNSUSPENDING);
            Assert.Equal(actual := unitModeManager.UnsuspendingStateActive, expected := TRUE);

            unitModeManager.UnsuspendCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_EXECUTE);
            Assert.Equal(actual := unitModeManager.ExecuteStateActive, expected := TRUE);

            //
            unitModeManager.SC := FALSE;
            unitModeManager.HoldCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_HOLDING);
            Assert.Equal(actual := unitModeManager.HoldingStateActive, expected := TRUE);

            unitModeManager.HoldCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_HELD);
            Assert.Equal(actual := unitModeManager.HeldStateActive, expected := TRUE);

            unitModeManager.SC := FALSE;
            unitModeManager.UnholdCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_UNHOLDING);
            Assert.Equal(actual := unitModeManager.UnholdingStateActive, expected := TRUE);

            unitModeManager.UnholdCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_EXECUTE);
            Assert.Equal(actual := unitModeManager.ExecuteStateActive, expected := TRUE);

            unitModeManager.SC := FALSE;
            unitModeManager.CompleteCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_COMPLETING);
            Assert.Equal(actual := unitModeManager.CompletingStateActive, expected := TRUE);

            unitModeManager.CompleteCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_COMPLETED);
            Assert.Equal(actual := unitModeManager.CompletedStateActive, expected := TRUE);

            unitModeManager.SC := FALSE;
            unitModeManager.ResetCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_RESETTING);
            Assert.Equal(actual := unitModeManager.ResettingStateActive, expected := TRUE);

            unitModeManager.ResetCmdRequest := FALSE;
            unitModeManager.AbortCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_ABORTING);
            Assert.Equal(actual := unitModeManager.AbortingStateActive, expected := TRUE);

            unitModeManager.AbortCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_ABORTED);
            Assert.Equal(actual := unitModeManager.AbortedStateActive, expected := TRUE);

            unitModeManager.SC := FALSE;
            unitModeManager.ClearCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_CLEARING);
            Assert.Equal(actual := unitModeManager.ClearingStateActive, expected := TRUE);

            unitModeManager.ClearCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_STOPPED);
            Assert.Equal(actual := unitModeManager.StoppedStateActive, expected := TRUE);

            unitModeManager.SC := FALSE;
            unitModeManager.ResetCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_RESETTING);
            Assert.Equal(actual := unitModeManager.ResettingStateActive, expected := TRUE);

            unitModeManager.ResetCmdRequest := FALSE;
            unitModeManager.StopCmdRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_STOPPING);
            Assert.Equal(actual := unitModeManager.StoppingStateActive, expected := TRUE);

            unitModeManager.StopCmdRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();  
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := LPMLV2022_StateConstants#STATE_STOPPED);
            Assert.Equal(actual := unitModeManager.StoppedStateActive, expected := TRUE);

        END_METHOD
    END_CLASS

(*
    {TestFixture}
    CLASS TestStopCommandRequest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestStopCommandRequest_RisingEdge
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Test Stop command
            unitModeManager.StopCmdRequest := TRUE;
            unitModeManager();

            // Command should have been processed
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestHoldUnholdCommandRequests
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestHoldUnholdCommandRequests
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Test Hold command
            unitModeManager.HoldCmdRequest := TRUE;
            unitModeManager();
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);

            // Reset and test Unhold command
            unitModeManager.HoldCmdRequest := FALSE;
            unitModeManager();
            unitModeManager.UnholdCmdRequest := TRUE;
            unitModeManager();
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestSuspendUnsuspendCommandRequests
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestSuspendUnsuspendCommandRequests
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Test Suspend command
            unitModeManager.SuspendCmdRequest := TRUE;
            unitModeManager();
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);

            // Reset and test Unsuspend command
            unitModeManager.SuspendCmdRequest := FALSE;
            unitModeManager();
            unitModeManager.UnsuspendCmdRequest := TRUE;
            unitModeManager();
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestAbortClearCommandRequests
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestAbortClearCommandRequests
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Test Abort command
            unitModeManager.AbortCmdRequest := TRUE;
            unitModeManager();
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);

            // Reset and test Clear command
            unitModeManager.AbortCmdRequest := FALSE;
            unitModeManager();
            unitModeManager.ClearCmdRequest := TRUE;
            unitModeManager();
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestCompleteCommandRequest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestCompleteCommandRequest
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Test Complete command
            unitModeManager.CompleteCmdRequest := TRUE;
            unitModeManager();
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestCommandPriorityAbortHighest
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestCommandPriority_AbortHighest
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Multiple commands - Abort should have highest priority
            unitModeManager.StartCmdRequest := TRUE;
            unitModeManager.StopCmdRequest := TRUE;
            unitModeManager.AbortCmdRequest := TRUE;
            unitModeManager.ResetCmdRequest := TRUE;
            unitModeManager();

            // Abort should be processed (highest priority)
            // Note: We can't directly verify which command was processed,
            // but we can verify no error occurred
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestCommandPriorityStopSecond
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestCommandPriority_StopSecond
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Multiple commands without Abort - Stop should have priority
            unitModeManager.StartCmdRequest := TRUE;
            unitModeManager.StopCmdRequest := TRUE;
            unitModeManager.ResetCmdRequest := TRUE;
            unitModeManager.HoldCmdRequest := TRUE;
            unitModeManager();

            // Stop should be processed (second highest priority)
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestCommandPriorityCompleteThird
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestCommandPriority_CompleteThird
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Commands without Abort/Stop - Complete should have priority
            unitModeManager.StartCmdRequest := TRUE;
            unitModeManager.CompleteCmdRequest := TRUE;
            unitModeManager.ResetCmdRequest := TRUE;
            unitModeManager();

            // Complete should be processed (third highest priority)
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestStateCompleteSignal
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestStateCompleteSignal
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Test SC (State Complete) signal
            unitModeManager.SC := TRUE;
            unitModeManager();

            // Should process without error
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);

            // Test SC signal edge
            unitModeManager.SC := FALSE;
            unitModeManager();
            unitModeManager.SC := TRUE;
            unitModeManager();

            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestEdgeDetectionConsistency
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestEdgeDetectionConsistency
            
            unitModeManager();  // First cycle
            unitModeManager();  // Second cycle

            // Test that edge detection works consistently
            // Set input high
            unitModeManager.ProductionModeRequest := TRUE;
            unitModeManager();
            
            // Keep high - should not trigger again
            unitModeManager.ProductionModeRequest := TRUE;
            unitModeManager();
            
            // Set low
            unitModeManager.ProductionModeRequest := FALSE;
            unitModeManager();
            
            // Set high again - should trigger
            unitModeManager.ProductionModeRequest := TRUE;
            unitModeManager();
            
            // Should be in Production mode
            Assert.Equal(actual := unitModeManager.ProductionModeActive, expected := TRUE);
        
        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestConfigurationHandling
        VAR
            unitModeManager : LPMLV2022_UnitModeStateManagerBool;
        END_VAR

        {Test}
        METHOD PUBLIC TestConfigurationHandling
            
            // Test that configuration is properly handled
            // Set custom configuration
            unitModeManager.config.EnabledModesCfg := DWORD#16#0000_000E; // Enable only Manual, Maintenance, Production
            unitModeManager.config.holdCmdCfg := DWORD#16#0000_0020; // Custom hold command config
            unitModeManager.config.completeCmdCfg := DWORD#16#0000_0040; // Custom complete command config
            
            unitModeManager();  // First cycle - should copy config
            unitModeManager();  // Second cycle

            // Configuration should have been transferred to internal state manager
            // (We can't directly verify this, but ensure no errors occur)
            Assert.Equal(actual := unitModeManager.unitModeChangeNotAllowed, expected := FALSE);
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := FALSE);
        
        END_METHOD
    END_CLASS
*)
END_NAMESPACE