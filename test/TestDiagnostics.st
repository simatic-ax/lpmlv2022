USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    {TestFixture}
    CLASS TestDiagnostics
        VAR
            driver : StateMachineDriver;
        END_VAR

        {Test}
        METHOD PUBLIC CmdAboveRange_NotDefined
            driver.ExpectCmdNotDefined(startState := State#STOPPED, cmdValue := DINT#11);
        END_METHOD

        {Test}
        METHOD PUBLIC CmdBelowRange_NotDefined
            driver.ExpectCmdNotDefined(startState := State#EXECUTE, cmdValue := DINT#-1);
        END_METHOD

        {Test}
        METHOD PUBLIC CmdFarOutOfRange_NotDefinedInActingState
            driver.ExpectCmdNotDefined(startState := State#STARTING, cmdValue := DINT#100);
        END_METHOD

        {Test}
        METHOD PUBLIC BufferIndexWrapsAfterEightEntries
            driver.ExpectBufferWraps();
        END_METHOD
    END_CLASS
END_NAMESPACE
