USING AxUnit;
USING Simatic.Ax.LPMLV2022;

NAMESPACE Simatic.Ax.LPMLV2022.Tests

    /// Test helper: AxUnit keeps one instance per fixture, so every check first drives the block back to a known state.
    CLASS StateMachineDriver
        VAR PUBLIC
            sut : UnitModeStateManager;
        END_VAR

        METHOD PRIVATE Release
            VAR_TEMP
                i : INT;
            END_VAR

            sut.CmdChangeRequest := FALSE;
            sut.CntrlCmd := Command#UNDEFINED;
            sut.SC := FALSE;
            sut.UnitModeChangeRequest := FALSE;
            sut.UnitMode := Mode#INVALID;
            // The block re-arms command and mode edge detection two cycles after the request drops
            FOR i := 1 TO 3 DO
                sut();
            END_FOR;
        END_METHOD

        METHOD PRIVATE Issue
            VAR_INPUT
                cmd : Command;
            END_VAR

            THIS.Release();
            sut.CntrlCmd := cmd;
            sut.CmdChangeRequest := TRUE;
            sut();
        END_METHOD

        METHOD PRIVATE IssueSC
            THIS.Release();
            sut.SC := TRUE;
            sut();
        END_METHOD

        METHOD PRIVATE PulseSC
            THIS.IssueSC();
            sut.SC := FALSE;
            sut();
        END_METHOD

        METHOD PRIVATE IsActing : BOOL
            VAR_INPUT
                s : State;
            END_VAR

            IsActing := s = State#CLEARING OR
                s = State#STARTING OR
                s = State#STOPPING OR
                s = State#ABORTING OR
                s = State#HOLDING OR
                s = State#UNHOLDING OR
                s = State#SUSPENDING OR
                s = State#UNSUSPENDING OR
                s = State#RESETTING OR
                s = State#COMPLETING;
        END_METHOD

        METHOD PRIVATE Finish
            IF THIS.IsActing(s := sut.StateCurrent) THEN
                THIS.PulseSC();
            END_IF;
        END_METHOD

        METHOD PUBLIC RequestMode
            VAR_INPUT
                modeValue : DINT;
            END_VAR

            THIS.Release();
            sut.UnitMode := modeValue;
            sut.UnitModeChangeRequest := TRUE;
            sut();
        END_METHOD

        /// Returns to STOPPED in unit mode Manual, the baseline every check starts from.
        METHOD PUBLIC ToStopped
            THIS.Release();
            THIS.Finish();
            IF sut.StateCurrent <> State#STOPPED THEN
                IF sut.StateCurrent <> State#ABORTED THEN
                    THIS.Issue(cmd := Command#ABORT);
                    THIS.Finish();
                END_IF;
                THIS.Issue(cmd := Command#CLEAR);
                THIS.Finish();
            END_IF;
            IF sut.UnitModeCurrent <> Mode#MANUAL THEN
                THIS.RequestMode(modeValue := Mode#MANUAL);
            END_IF;
            Assert.Equal(actual := sut.UnitModeCurrent, expected := Mode#MANUAL);
        END_METHOD

        METHOD PRIVATE ToIdle
            THIS.Issue(cmd := Command#RESET);
            THIS.Finish();
        END_METHOD

        METHOD PRIVATE ToExecute
            THIS.ToIdle();
            THIS.Issue(cmd := Command#START);
            THIS.Finish();
        END_METHOD

        /// Leaves the command that entered an acting state asserted, so the state has not been completed yet.
        METHOD PRIVATE DriveTo
            VAR_INPUT
                target : State;
            END_VAR

            THIS.ToStopped();

            CASE target OF
                State#STOPPED:
                    ;
                State#RESETTING:
                    THIS.Issue(cmd := Command#RESET);
                State#IDLE:
                    THIS.ToIdle();
                State#STARTING:
                    THIS.ToIdle();
                    THIS.Issue(cmd := Command#START);
                State#EXECUTE:
                    THIS.ToExecute();
                State#STOPPING:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#STOP);
                State#SUSPENDING:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#SUSPEND);
                State#SUSPENDED:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#SUSPEND);
                    THIS.Finish();
                State#UNSUSPENDING:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#SUSPEND);
                    THIS.Finish();
                    THIS.Issue(cmd := Command#UNSUSPEND);
                State#HOLDING:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#HOLD);
                State#HELD:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#HOLD);
                    THIS.Finish();
                State#UNHOLDING:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#HOLD);
                    THIS.Finish();
                    THIS.Issue(cmd := Command#UNHOLD);
                State#COMPLETING:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#COMPLETE);
                State#COMPLETED:
                    THIS.ToExecute();
                    THIS.Issue(cmd := Command#COMPLETE);
                    THIS.Finish();
                State#ABORTING:
                    THIS.Issue(cmd := Command#ABORT);
                State#ABORTED:
                    THIS.Issue(cmd := Command#ABORT);
                    THIS.Finish();
                State#CLEARING:
                    THIS.Issue(cmd := Command#ABORT);
                    THIS.Finish();
                    THIS.Issue(cmd := Command#CLEAR);
            END_CASE;

            Assert.Equal(actual := sut.StateCurrent, expected := target);
        END_METHOD

        METHOD PRIVATE NextIndex : INT
            VAR_INPUT
                index : INT;
            END_VAR
            VAR_TEMP
                result : INT;
            END_VAR

            result := index + 1;
            IF result > LimitConstants#DIAG_BUFFER_UPPER_LIM THEN
                result := 0;
            END_IF;
            NextIndex := result;
        END_METHOD

        /// The command is accepted: the state changes and a single diagnostics entry reports success.
        METHOD PUBLIC ExpectAccepted
            VAR_INPUT
                startState : State;
                cmd : Command;
                endState : State;
                requested : State;
                inProcess : BOOL;
            END_VAR
            VAR_TEMP
                entry : INT;
            END_VAR

            THIS.DriveTo(target := startState);
            entry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            THIS.Issue(cmd := cmd);

            Assert.Equal(actual := sut.StateCurrent, expected := endState);
            Assert.Equal(actual := sut.StateRequested, expected := requested);
            Assert.Equal(actual := sut.StateChangeInProcess, expected := inProcess);
            Assert.Equal(actual := sut.cntrlCmdNotAllowed, expected := FALSE);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := entry);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].message, expected := Message#STATE_CHANGED_SUCCESSFULLY);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].StateCurrent, expected := TO_SINT(startState));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].CntrlCmd, expected := TO_SINT(cmd));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].UnitModeCurrent, expected := TO_SINT(Mode#MANUAL));
        END_METHOD

        /// The command is rejected: state, requested state and in-process flag stay untouched.
        METHOD PUBLIC ExpectRejected
            VAR_INPUT
                startState : State;
                cmd : Command;
            END_VAR

            THIS.ExpectRefused(startState := startState, cmd := cmd, expectedMessage := Message#CMD_NOT_ALLOWED);
        END_METHOD

        /// A command value outside the Command enumeration is refused and reported as not defined.
        METHOD PUBLIC ExpectCmdNotDefined
            VAR_INPUT
                startState : State;
                cmdValue : DINT;
            END_VAR
            VAR_TEMP
                undefinedCmd : Command;
            END_VAR

            undefinedCmd := cmdValue;
            THIS.ExpectRefused(startState := startState, cmd := undefinedCmd, expectedMessage := Message#CMD_NOT_DEFINED);
        END_METHOD

        METHOD PRIVATE ExpectRefused
            VAR_INPUT
                startState : State;
                cmd : Command;
                expectedMessage : Message;
            END_VAR
            VAR_TEMP
                requestedBefore : State;
                inProcessBefore : BOOL;
                entry : INT;
            END_VAR

            THIS.DriveTo(target := startState);
            requestedBefore := sut.StateRequested;
            inProcessBefore := sut.StateChangeInProcess;
            entry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            THIS.Issue(cmd := cmd);

            Assert.Equal(actual := sut.StateCurrent, expected := startState);
            Assert.Equal(actual := sut.StateRequested, expected := requestedBefore);
            Assert.Equal(actual := sut.StateChangeInProcess, expected := inProcessBefore);
            Assert.Equal(actual := sut.cntrlCmdNotAllowed, expected := TRUE);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := entry);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].message, expected := expectedMessage);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].StateCurrent, expected := TO_SINT(startState));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].CntrlCmd, expected := TO_SINT(cmd));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].UnitModeCurrent, expected := TO_SINT(Mode#MANUAL));
        END_METHOD

        /// The state complete signal finishes an acting state.
        METHOD PUBLIC ExpectScCompletes
            VAR_INPUT
                startState : State;
                endState : State;
            END_VAR
            VAR_TEMP
                requestedBefore : State;
                entry : INT;
            END_VAR

            THIS.DriveTo(target := startState);
            requestedBefore := sut.StateRequested;
            entry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            THIS.IssueSC();

            Assert.Equal(actual := sut.StateCurrent, expected := endState);
            Assert.Equal(actual := sut.StateRequested, expected := requestedBefore);
            Assert.Equal(actual := sut.StateChangeInProcess, expected := FALSE);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := entry);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].message, expected := Message#STATE_CHANGED_SUCCESSFULLY);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].StateCurrent, expected := TO_SINT(startState));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].SC, expected := TRUE);
        END_METHOD

        /// The state complete signal is ignored in a state that is not acting.
        METHOD PUBLIC ExpectScRejected
            VAR_INPUT
                startState : State;
            END_VAR
            VAR_TEMP
                requestedBefore : State;
                inProcessBefore : BOOL;
                entry : INT;
            END_VAR

            THIS.DriveTo(target := startState);
            requestedBefore := sut.StateRequested;
            inProcessBefore := sut.StateChangeInProcess;
            entry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            THIS.IssueSC();

            Assert.Equal(actual := sut.StateCurrent, expected := startState);
            Assert.Equal(actual := sut.StateRequested, expected := requestedBefore);
            Assert.Equal(actual := sut.StateChangeInProcess, expected := inProcessBefore);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := entry);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].message, expected := Message#SC_NOT_ALLOWED);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].StateCurrent, expected := TO_SINT(startState));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].SC, expected := TRUE);
        END_METHOD

        /// Hold and state complete in the same cycle: Hold wins and the SC entry reports the override.
        METHOD PUBLIC ExpectHoldOverridesSc
            VAR_INPUT
                startState : State;
            END_VAR
            VAR_TEMP
                scEntry : INT;
                cmdEntry : INT;
            END_VAR

            THIS.DriveTo(target := startState);
            scEntry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            cmdEntry := THIS.NextIndex(index := scEntry);

            THIS.Release();
            sut.CntrlCmd := Command#HOLD;
            sut.CmdChangeRequest := TRUE;
            sut.SC := TRUE;
            sut();

            Assert.Equal(actual := sut.StateCurrent, expected := State#HOLDING);
            Assert.Equal(actual := sut.StateRequested, expected := State#HELD);
            Assert.Equal(actual := sut.StateChangeInProcess, expected := TRUE);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := cmdEntry);
            Assert.Equal(actual := sut.diagnostics.buffer[scEntry].message, expected := Message#SC_OVERRIDDEN_BY_CMD_HOLD);
            Assert.Equal(actual := sut.diagnostics.buffer[cmdEntry].message, expected := Message#STATE_CHANGED_SUCCESSFULLY);
        END_METHOD

        /// The requested unit mode becomes active and a single diagnostics entry reports success.
        METHOD PUBLIC ExpectModeAccepted
            VAR_INPUT
                startState : State;
                modeValue : DINT;
            END_VAR
            VAR_TEMP
                entry : INT;
            END_VAR

            THIS.DriveTo(target := startState);
            entry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            THIS.RequestMode(modeValue := modeValue);

            Assert.Equal(actual := TO_DINT(sut.UnitModeCurrent), expected := modeValue);
            Assert.Equal(actual := sut.StateCurrent, expected := startState);
            Assert.Equal(actual := sut.unitModeChangeNotAllowed, expected := FALSE);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := entry);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].message, expected := Message#MODE_CHANGED_SUCCESSFULLY);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].UnitModeCurrent, expected := TO_SINT(Mode#MANUAL));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].StateCurrent, expected := TO_SINT(startState));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].UnitMode, expected := TO_SINT(modeValue));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].CntrlCmd, expected := TO_SINT(Command#UNDEFINED));
        END_METHOD

        /// The unit mode stays Manual, the not-allowed flag is raised until the request drops.
        METHOD PUBLIC ExpectModeRejected
            VAR_INPUT
                startState : State;
                modeValue : DINT;
                expectedMessage : Message;
            END_VAR
            VAR_TEMP
                entry : INT;
            END_VAR

            THIS.DriveTo(target := startState);
            entry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            THIS.RequestMode(modeValue := modeValue);

            Assert.Equal(actual := sut.UnitModeCurrent, expected := Mode#MANUAL);
            Assert.Equal(actual := sut.StateCurrent, expected := startState);
            Assert.Equal(actual := sut.unitModeChangeNotAllowed, expected := TRUE);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := entry);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].message, expected := expectedMessage);
            Assert.Equal(actual := sut.diagnostics.buffer[entry].UnitModeCurrent, expected := TO_SINT(Mode#MANUAL));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].StateCurrent, expected := TO_SINT(startState));
            Assert.Equal(actual := sut.diagnostics.buffer[entry].UnitMode, expected := TO_SINT(modeValue));

            THIS.Release();
            Assert.Equal(actual := sut.unitModeChangeNotAllowed, expected := FALSE);
        END_METHOD

        /// Requesting the invalid mode 0 is a no-op: no entry, no flag.
        METHOD PUBLIC ExpectInvalidModeIgnored
            VAR_TEMP
                indexBefore : INT;
            END_VAR

            THIS.ToStopped();
            indexBefore := sut.diagnostics.bufferIndex;
            THIS.RequestMode(modeValue := Mode#INVALID);

            Assert.Equal(actual := sut.UnitModeCurrent, expected := Mode#MANUAL);
            Assert.Equal(actual := sut.unitModeChangeNotAllowed, expected := FALSE);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := indexBefore);
        END_METHOD

        /// The mode is entered, but its state configuration is corrected and reported with a second entry.
        METHOD PUBLIC ExpectModeForced
            VAR_INPUT
                modeValue : DINT;
                expectedDisabled : DWORD;
            END_VAR
            VAR_TEMP
                changeEntry : INT;
                forcedEntry : INT;
            END_VAR

            THIS.ToStopped();
            changeEntry := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
            forcedEntry := THIS.NextIndex(index := changeEntry);
            THIS.RequestMode(modeValue := modeValue);

            Assert.Equal(actual := TO_DINT(sut.UnitModeCurrent), expected := modeValue);
            Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := forcedEntry);
            Assert.Equal(actual := sut.diagnostics.buffer[changeEntry].message, expected := Message#MODE_CHANGED_SUCCESSFULLY);
            Assert.Equal(actual := sut.diagnostics.buffer[forcedEntry].message, expected := Message#STATE_CONFIG_FORCED);
            Assert.Equal(actual := sut.CurDisabledStates, expected := expectedDisabled);
            Assert.Equal(actual := sut.unitModeChangeNotAllowed, expected := FALSE);
        END_METHOD

        /// Alternating mode changes fill the 8-entry diagnostics ring and wrap around.
        METHOD PUBLIC ExpectBufferWraps
            VAR_TEMP
                i : INT;
                expected : INT;
                wrapped : BOOL;
            END_VAR

            THIS.ToStopped();
            FOR i := 1 TO 9 DO
                expected := THIS.NextIndex(index := sut.diagnostics.bufferIndex);
                IF (i MOD 2) = 1 THEN
                    THIS.RequestMode(modeValue := Mode#PRODUCTION);
                ELSE
                    THIS.RequestMode(modeValue := Mode#MANUAL);
                END_IF;
                Assert.Equal(actual := sut.diagnostics.bufferIndex, expected := expected);
                Assert.Equal(actual := sut.diagnostics.buffer[expected].message, expected := Message#MODE_CHANGED_SUCCESSFULLY);
                IF expected = 0 THEN
                    wrapped := TRUE;
                END_IF;
            END_FOR;
            Assert.Equal(actual := wrapped, expected := TRUE);
        END_METHOD
    END_CLASS
END_NAMESPACE
