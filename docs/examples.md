# Getting Started — Application Examples

This page demonstrates how to integrate the LPMLV2022 library into a SIMATIC AX Logic Control application using code examples.

## Prerequisites

Add the library to your `apax.yml`:

```yaml
dependencies:
  "@simatic-ax/lpmlv2022": ^3.0.0
```

If you want to use timer-based state transitions (as shown in the examples), also add:

```yaml
dependencies:
  "@ax/system-timer": ^10.3.25
```

If you want to rely on system functionality to detect the first call of a ProgramCycle task, also add:

```yaml
dependencies:
  "@ax/simatic-tasks": ^11.0.2
```

## Example - step 1: Wrapping the State Manager in a Function Block

A function block wraps `UnitModeStateManager` and implements configuration handling and state-complete logic.

### Declaration

```iecst
USING Simatic.Ax.LPMLV2022;
USING System.Timer;

FUNCTION_BLOCK CallUnitModeStateManager
    VAR_INPUT
        initialCall : BOOL;
        unitMode : Mode;
        unitModeChangeReq : BOOL;
        cntrlCmd : Command;
        cmdChangeRequest : BOOL;
    END_VAR

    VAR_OUTPUT
        stacklightStatus : DWORD;
    END_VAR

    VAR
        _stateManager : UnitModeStateManager;
        _stacklight : Stacklight;
        _delay : OnDelay;
    END_VAR
```

> **Note:** The `initialCall` input is used to run the one-time configuration in the very first cycle, then `RETURN` to avoid a runtime peak.

### One-Time Configuration (First Cycle)

Use the configuration helper functions to set up which modes are enabled and which states are active per mode. This runs once on `initialCall`:

```iecst
IF initialCall THEN
    // Enable the needed unit modes
    ConfigureEnabledModesCfg(ProductionMode := TRUE,
                            MaintenanceMode := TRUE,
                            UserMode01 := TRUE,
                            EnabledModesCfg => _stateManager.config.EnabledModesCfg);

    // Production: all states enabled
    ConfigureDisabledStatesCfg(Clearing := FALSE,
                               Starting := FALSE,
                               Suspended := FALSE,
                               Stopping := FALSE,
                               Aborting := FALSE,
                               Holding := FALSE,
                               Held := FALSE,
                               Unholding := FALSE,
                               Suspending := FALSE,
                               Unsuspending := FALSE,
                               Resetting := FALSE,
                               Completing := FALSE,
                               Completed := FALSE,
                               DisabledStatesCfg => _stateManager.config.DisabledStatesCfg[Mode#PRODUCTION]);

    // Maintenance: Suspend/Unsuspend disabled
    ConfigureDisabledStatesCfg(Clearing := FALSE,
                               Starting := FALSE,
                               Suspended := TRUE,
                               Stopping := FALSE,
                               Aborting := FALSE,
                               Holding := FALSE,
                               Held := FALSE,
                               Unholding := FALSE,
                               Suspending := TRUE,
                               Unsuspending := TRUE,
                               Resetting := FALSE,
                               Completing := FALSE,
                               Completed := FALSE,
                               DisabledStatesCfg => _stateManager.config.DisabledStatesCfg[Mode#MAINTENANCE]);

    // Manual: minimal state set (no Hold, Suspend, Complete)
    ConfigureDisabledStatesCfg(Clearing := FALSE,
                               Starting := FALSE,
                               Suspended := TRUE,
                               Stopping := FALSE,
                               Aborting := FALSE,
                               Holding := TRUE,
                               Held := TRUE,
                               Unholding := TRUE,
                               Suspending := TRUE,
                               Unsuspending := TRUE,
                               Resetting := FALSE,
                               Completing := TRUE,
                               Completed := TRUE,
                               DisabledStatesCfg => _stateManager.config.DisabledStatesCfg[Mode#MANUAL]);

    // UserMode01: user-defined state configuration
    ConfigureDisabledStatesCfg(Clearing := FALSE,
                               Starting := FALSE,
                               Suspended := TRUE,
                               Stopping := FALSE,
                               Aborting := FALSE,
                               Holding := FALSE,
                               Held := FALSE,
                               Unholding := FALSE,
                               Suspending := TRUE,
                               Unsuspending := TRUE,
                               Resetting := FALSE,
                               Completing := FALSE,
                               Completed := FALSE,
                               DisabledStatesCfg => _stateManager.config.DisabledStatesCfg[Mode#USER_01]);

    _delay.duration := LTIME#2s; // used for simulation of transitioning out of Acting states
    RETURN;
END_IF;
```

**Key points:**

- The `ConfigureDisabledStatesCfg` parameter names indicate which states to **disable** — set to `TRUE` to remove a state from that mode
- Stopped, Idle, Execute, and Aborted are always present and cannot be disabled
- Manual mode is always enabled; you do not need to configure it in `ConfigureEnabledModesCfg`
- The array index for `DisabledStatesCfg` uses the `Mode` named value directly (e.g. `Mode#PRODUCTION`)

### Calling the State Manager

Pass the mode and command inputs through, then implement per-mode/per-state logic:

```iecst
// Call the state manager
_stateManager(UnitMode := unitMode,
              UnitModeChangeRequest := unitModeChangeReq,
              CntrlCmd := cntrlCmd,
              CmdChangeRequest := cmdChangeRequest);

// Reset SC — it is edge-triggered and must return to FALSE
_stateManager.SC := FALSE;
```

### Handling Acting States with Timer-Based Delays

Acting states (Resetting, Starting, Stopping, etc.) require a rising edge on the `SC` (State Complete) signal to advance to the next state.
In a real application, `SC` would be set when actual machine actions finish.
For demonstration purposes, an `OnDelay` timer simulates transition durations:

```iecst
CASE _stateManager.UnitModeCurrent OF
    Mode#PRODUCTION:
        CASE _stateManager.StateCurrent OF
            State#RESETTING:
            //-------------------------------------------
            // State Type: Acting
            // This state is the result of a Reset command from the Stopped or
            // Completed state. Faults and stop causes are reset. Resetting will
            // typically cause safety devices to be energized and place the machine in
            // the Idle state where it will wait for a Start command. No hazardous
            // motion should happen in this state.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#IDLE:
            //-------------------------------------------
            // State Type: Wait
            // This is the state that indicates that Resetting is complete.
            // The machine will maintain the conditions that were achieved
            // during the Resetting state, and perform operations required when the
            // machine is in Idle.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here

            State#STARTING:
            //-------------------------------------------
            // State Type: Acting
            // The machine completes the steps needed to start. This state is entered
            // as a result of a Start command (local or remote). When Starting completes,
            // the machine will transition to the Execute state.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#EXECUTE:
            //-------------------------------------------
            // State Type: Acting
            // Once the machine is processing materials it is in the Execute state
            // until a transition command is received. Different machine modes
            // will result in specific types of Execute activities.
            // For example, if the machine is in the "Production" mode, the Execute will
            // result in products being produced, while perhaps in a user-defined "Clean Out" mode
            // the Execute state would result in the action of cleaning the machine.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here

            State#STOPPING:
            //-------------------------------------------
            // State Type: Acting
            // This state is entered in response to a Stop command.
            // While in this state the machine executes the logic that brings it to a
            // controlled stop as reflected by the Stopped state. Normal Starting
            // of the machine cannot be initiated unless Resetting has taken place.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#STOPPED:
            //-------------------------------------------
            // State Type: Wait
            // The machine is powered and stationary after completing the Stopping state.
            // All communications with other systems are functioning (if applicable).
            // A Reset command will cause a transition from Stopped to the Resetting state.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here

            State#HOLDING:
            //-------------------------------------------
            // State Type: Acting
            // This state is used when internal (inside this unit/machine and
            // not from another machine on the production line) machine conditions do
            // not allow the machine to continue producing, that is, the machine leaves
            // the Execute or Suspended states due to internal conditions.
            // This is typically used for routine machine conditions that require minor
            // operator servicing to continue production. This state can be initiated
            // automatically or by an operator and can be easily recovered from.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#HELD:
            //-------------------------------------------
            // State Type: Wait
            // Refer to Holding for when this state is used. In this state the machine
            // does not produce product. It will either stop running or continue to dry
            // cycle. A transition to the Unholding state will occur when internal
            // machine conditions change or an Unhold command is initiated by an operator.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here

            State#UNHOLDING:
            //-------------------------------------------
            // State Type: Acting
            // Refer to Holding for when this state is used. A machine will typically
            // enter into Unholding automatically when internal conditions,
            // material levels, for example, return to an acceptable level. If an operator
            // is required to perform minor servicing to replenish materials or make
            // adjustments, then the Unhold command may be initiated by the operator.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#SUSPENDING:
            //-------------------------------------------
            // State Type: Acting
            // This state is used when external (outside this unit/machine but
            // usually on the same integrated production line) process conditions do not
            // allow the machine to continue producing, that is, the machine leaves
            // Execute due to upstream or downstream conditions on the line. This is
            // typically due to a Blocked or Starved event.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#SUSPENDED:
            //-------------------------------------------
            // State Type: Wait
            // Refer to Suspending for when this state is used. In this state the
            // machine does not produce product. It will either stop running or continue
            // to cycle without producing until external process conditions return to
            // normal, at which time, the Suspended state will transition to the
            // Unsuspending state, typically without any operator intervention.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here

            State#UNSUSPENDING:
            //-------------------------------------------
            // State Type: Acting
            // Refer to Suspending for when this state is used. This state is a result
            // of process conditions returning to normal. The Unsuspending state
            // initiates any required actions or sequences necessary to transition the
            // machine from Suspended back to Execute.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#COMPLETING:
            //-------------------------------------------
            // State Type: Acting
            // This state is the result of a Complete command from the Execute, Held
            // or Suspended states. The Complete command may be internally generated,
            // such as reaching the end of a predefined production count where normal
            // operation has run to completion, or externally generated, such as by a
            // supervisory system. The Completing state is often used to end a
            // production run and summarize production data.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#COMPLETED:
            //-------------------------------------------
            // State Type: Wait
            // The machine has finished the Completing state and is now waiting for
            // a Reset command before transitioning to the Resetting state.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here

            State#ABORTING:
            //-------------------------------------------
            // State type: Acting
            // The Aborting state can be entered at any time in response to the Abort command,
            // typically triggered by the occurrence of a machine event that warrants an aborting action.
            // The aborting logic will bring the machine to a rapid safe stop.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            State#ABORTED:
            //-------------------------------------------
            // State Type: Wait
            // The machine maintains status information relevant to the abort condition.
            // The machine can only exit the Aborted state after an explicit Clear command,
            // subsequent to manual intervention to correct and reset the
            // detected machine faults.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here

            State#CLEARING:
            //-------------------------------------------
            // State Type: Acting
            // Initiated by a Clear command to clear faults that may have occurred and
            // are present in the Aborted state before proceeding to a Stopped state.
            //-------------------------------------------
            ; // ToDo: add application-specific logic here
            _delay.signal := TRUE;
            IF _delay.output THEN
                _stateManager.SC := TRUE;
                _delay.signal := FALSE;
            END_IF;

            ELSE
            // Error reaction
            ; // ToDo: add error handling here
        END_CASE;

    // Mode#MAINTENANCE, Mode#MANUAL, Mode#USER_01:
    // Follow the same pattern with mode-specific state subsets
END_CASE;
_delay();
```

> **Pattern:** Acting states activate the timer with `_delay.signal := TRUE`.
> When `_delay.output` becomes `TRUE` (after the configured duration), set `SC := TRUE` and reset the timer.
> Wait states need no SC logic — they wait for the next command.

### Stacklight Integration

Wire the stacklight to the **current state** to get OMAC-compliant indicator outputs:

```iecst
_stacklight(StateCurrent := _stateManager.StateCurrent,
            StacklightStatus => stacklightStatus);
```

## Example 2: Program and Configuration Setup

### Configuration (configuration.st)

Define the cyclic task and expose the function block instance and control variables as globals:

```iecst
USING Simatic.Ax.LPMLV2022;
USING Siemens.Simatic.Tasks;

CONFIGURATION MyConfiguration
    TASK Main : ProgramCycle;

    PROGRAM P1 WITH Main: MainProgram;

    VAR_GLOBAL
        InstPMLV2022 : Demo.CallUnitModeStateManager;
        unitMode : Mode;
        unitModeChangeReq : BOOL;
        cntrlCmd : Command;
        cmdChangeRequest : BOOL;
    END_VAR
END_CONFIGURATION
```

### Main Program (MainProgram.st)

The main program reads task information (to detect the first cycle via `Initial_Call`) and calls the wrapper function block:

```iecst
USING Siemens.Simatic.Tasks;
USING Simatic.Ax.LPMLV2022;

PROGRAM MainProgram
    VAR_EXTERNAL
        InstPMLV2022 : Simatic.Ax.LPMLV2022.Demo.CallUnitModeStateManager;
        unitMode : Mode;
        unitModeChangeReq : BOOL;
        cntrlCmd : Command;
        cmdChangeRequest : BOOL;
    END_VAR

    VAR
        taskInfo : SI_ProgramCycle;
        retVal : WORD;
    END_VAR

    retVal := GetTaskInfo(taskInfo);
    InstPMLV2022(initialCall := taskInfo.Initial_Call,
                 unitMode := unitMode,
                 unitModeChangeReq := unitModeChangeReq,
                 cntrlCmd := cntrlCmd,
                 cmdChangeRequest := cmdChangeRequest);
END_PROGRAM
```

**Key points:**

- `taskInfo.Initial_Call` is `TRUE` only on the first scan after STOP→RUN, ensuring the configuration runs exactly once
- Global variables can be monitored and forced directly from the SIMATIC AX debugger/monitoring table.

## Example 3: Operating the State Machine

Once downloaded, control the machine by writing to the global variables. Here is a typical sequence:

| Step | Set Global Variable | Expected Transition |
| ---- | ---- | ---- |
| 1 | *(power on)* | Mode = `Mode#MANUAL`, State = `State#STOPPED` |
| 2 | `unitMode := Mode#PRODUCTION`<br>`unitModeChangeReq := TRUE` | Mode changes to Production, stays in Stopped |
| 3 | `unitModeChangeReq := FALSE` | — |
| 4 | `cntrlCmd := Command#RESET`<br>`cmdChangeRequest := TRUE` | State → Resetting → *(timer)* → Idle |
| 5 | `cmdChangeRequest := FALSE` | — |
| 6 | `cntrlCmd := Command#START`<br>`cmdChangeRequest := TRUE` | State → Starting → *(timer)* → Execute |
| 7 | `cntrlCmd := Command#HOLD`<br>`cmdChangeRequest := TRUE` | State → Holding → *(timer)* → Held |
| 8 | `cntrlCmd := Command#UNHOLD`<br>`cmdChangeRequest := TRUE` | State → Unholding → *(timer)* → Execute |
| 9 | `cntrlCmd := Command#STOP`<br>`cmdChangeRequest := TRUE` | State → Stopping → *(timer)* → Stopped |
| 10 | `cntrlCmd := Command#ABORT`<br>`cmdChangeRequest := TRUE` | State → Aborting → *(timer)* → Aborted |
| 11 | `cntrlCmd := Command#CLEAR`<br>`cmdChangeRequest := TRUE` | State → Clearing → *(timer)* → Stopped |

### Understanding `CmdChangeRequest` and `UnitModeChangeRequest`

These inputs are **enable signals**, not edge triggers. The actual change detection works on the **value** of `CntrlCmd` / `UnitMode`:

- While `CmdChangeRequest` remains `TRUE`, changing `CntrlCmd` to a different value will immediately trigger the new command — no need to cycle `CmdChangeRequest` through `FALSE` first
- Cycling `CmdChangeRequest` to `FALSE` and back to `TRUE` resets the internal change detection, allowing the **same** command to be re-issued
- The same behavior applies to `UnitModeChangeRequest` and `UnitMode`

In practice, the simplest approach is to set the desired command and enable signal together, then reset the enable signal after the state transition has been processed.
