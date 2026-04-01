USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestStopNotAllowedInStop
        VAR
            unitModeManager : UnitModeStateManager;
        END_VAR


        {Test}
        METHOD PUBLIC TestStopNotAllowedInStop_RisingEdge
            VAR_TEMP
                i : UINT;
            END_VAR

            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#START;
            unitModeManager.CmdChangeRequest := TRUE;

            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := TRUE);
            Assert.Equal(actual := unitModeManager.diagnostics.buffer[0].message, expected := BYTE#16#84); //  MSG_CMD_NOT_ALLOWED : Byte := BYTE#16#84;

        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestCmdNotAllowedInResetting
        VAR
            unitModeManager : UnitModeStateManager;
        END_VAR


        {Test}
        METHOD PUBLIC TestStopNotAllowedInStop_RisingEdge
            VAR_TEMP
                i : UINT;
            END_VAR

            unitModeManager();  // First cycle

            // Test rising edge detection for Reset command
            unitModeManager.CntrlCmd := Command#RESET;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.CmdChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#START;
            unitModeManager.CmdChangeRequest := TRUE;
            // CMD_STARET in RESETTING not allowed
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            Assert.Equal(actual := unitModeManager.cntrlCmdNotAllowed, expected := TRUE);
            Assert.Equal(actual := unitModeManager.diagnostics.buffer[1].message, expected := BYTE#16#84); //  MSG_CMD_NOT_ALLOWED : Byte := BYTE#16#84;

        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestExecuteCompleteTransition
        VAR
            unitModeManager : UnitModeStateManager;
        END_VAR


        {Test}
        METHOD PUBLIC TestExecuteCompletingTransition
            VAR_TEMP
                i : UINT;
                disabled : DWORD;
            END_VAR

            ConfigureDisabledStatesCfg(Completing := TRUE,  DisabledStatesCfg => disabled);
            unitModeManager.config.DisabledStatesCfg[1] := disabled;
            unitModeManager();  // First cycle

            unitModeManager.UnitMode := Mode#PRODUCTION;
            unitModeManager.UnitModeChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            unitModeManager.UnitModeChangeRequest := FALSE;
            Assert.Equal(actual := unitModeManager.UnitModeCurrent, expected := Mode#PRODUCTION);


            // Test rising edge detection for Reset command
            unitModeManager.CntrlCmd := Command#RESET;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.CmdChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#START;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#COMPLETE;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := State#COMPLETED);

        END_METHOD
    END_CLASS


    {TestFixture}
    CLASS TestExecuteHoldTransition
        VAR
            unitModeManager : UnitModeStateManager;
        END_VAR


        {Test}
        METHOD PUBLIC TestExecuteHoldingTransition
            VAR_TEMP
                i : UINT;
                disabled : DWORD;
            END_VAR

            ConfigureDisabledStatesCfg(Holding := TRUE,  DisabledStatesCfg => disabled);
            unitModeManager.config.DisabledStatesCfg[1] := disabled;
            unitModeManager();  // First cycle

            unitModeManager.UnitMode := Mode#PRODUCTION;
            unitModeManager.UnitModeChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            unitModeManager.UnitModeChangeRequest := FALSE;
            Assert.Equal(actual := unitModeManager.UnitModeCurrent, expected := Mode#PRODUCTION);


            // Test rising edge detection for Reset command
            unitModeManager.CntrlCmd := Command#RESET;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.CmdChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#START;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#HOLD;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := State#HELD);

        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestExecuteSuspendedTransition
        VAR
            unitModeManager : UnitModeStateManager;
        END_VAR


        {Test}
        METHOD PUBLIC TestExecuteSuspendedTransition_Test
            VAR_TEMP
                i : UINT;
                disabled : DWORD;
            END_VAR

            ConfigureDisabledStatesCfg(Suspending := TRUE,  DisabledStatesCfg => disabled);
            unitModeManager.config.DisabledStatesCfg[1] := disabled;
            unitModeManager();  // First cycle

            unitModeManager.UnitMode := Mode#PRODUCTION;
            unitModeManager.UnitModeChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            unitModeManager.UnitModeChangeRequest := FALSE;
            Assert.Equal(actual := unitModeManager.UnitModeCurrent, expected := Mode#PRODUCTION);


            // Test rising edge detection for Reset command
            unitModeManager.CntrlCmd := Command#RESET;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.CmdChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#START;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#SUSPEND;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := State#SUSPENDED);

        END_METHOD
    END_CLASS

    {TestFixture}
    CLASS TestHoldAfterCompleted
        VAR
            unitModeManager : UnitModeStateManager;
        END_VAR


        {Test}
        METHOD PUBLIC TestHoldAfterCompleted_Test
            VAR_TEMP
                i : UINT;
                holdCfg : DWORD;
            END_VAR

            ConfigureHoldCmdCfg(Completed := TRUE,  holdCmdCfg => holdCfg);
            unitModeManager.config.holdCmdCfg := holdCfg;
            unitModeManager();  // First cycle

            unitModeManager.UnitMode := Mode#PRODUCTION;
            unitModeManager.UnitModeChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            unitModeManager.UnitModeChangeRequest := FALSE;
            Assert.Equal(actual := unitModeManager.UnitModeCurrent, expected := Mode#PRODUCTION);


            // Test rising edge detection for Reset command
            unitModeManager.CntrlCmd := Command#RESET;
            unitModeManager();

            // Rising edge - should trigger command
            unitModeManager.CmdChangeRequest := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#START;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#COMPLETE;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CmdChangeRequest := FALSE;
            unitModeManager.SC := TRUE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;

            unitModeManager.CntrlCmd := Command#HOLD;
            unitModeManager.CmdChangeRequest := TRUE;
            unitModeManager.SC := FALSE;
            FOR i := 0 TO UINT#10 DO
                unitModeManager();
            END_FOR;
            Assert.Equal(actual := unitModeManager.StateCurrent, expected := State#HOLDING);

        END_METHOD
    END_CLASS
END_NAMESPACE