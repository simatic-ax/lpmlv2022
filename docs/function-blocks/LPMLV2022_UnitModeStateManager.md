# LPMLV2022_UnitModeStateManager

## Principle of operation

The function block `LPMLV2022_UnitModeStateManager` is the main part of the block library LPMLV2022 and manages the transitions between the unit modes and states according to the OMAC PackML standard.

> NOTE
>
> If a boolean interface is preferred, then the block `LPMLV2022_UnitModeStateManagerBool` should be used instead of this block.
>

## Function characteristics

![FunctionCharacteristics](/lib/docs/assets/images/function_characteristics.png)

1. If `CmdChangeRequest` is not set, every `CntrlCmd` is ignored.
2. If `CmdChangeRequest` is set to TRUE and a valid `CntrlCmd` (in this case
Reset) is set, the `StateChangeInProcess` bit is set and the StateRequested (in
this case Idle) value is set (only wait states possible). A valid `CntrlCmd` is
always necessary if the current state is a wait state.
If the current state is an acting state (here Resetting), a rising edge at input `SC`
is necessary to leave the state.
If `CmdChangeRequest` is FALSE, the `CntrlCmd` (here Start) has already been
set in the acting state (here Resetting) and the wait state (Idle) is reached
through a rising edge at the input `SC`, the next acting state will not be reached
automatically. For the change in the next wait state (here Execute) is a rising
edge at `CmdChangeRequest` needed.
3. The `StateChangeInProcess` bit remains set until StateCurrent gets the same
value as StateRequested. The StateRequested changes from Execute to
Stopped, because in Starting state a valid Stop command was set.
4. The `SC` input is not level sensitive. If the `SC` input is already set when reaching
the acting state, the Unit Mode and State Manager stays in the acting state as
long as a rising edge at `SC` input is detected.
5. The `SC` command is not related to the `CmdChangeRequest` input. Even if
`CmdChangeRequest` is FALSE, a state change can happen from acting to a
wait state.
6. A new `CntrlCmd` can also be set if `CmdChangeRequest` is FALSE. If
`CmdChangeRequest` changes to TRUE and the control command is valid in
this wait state, the state will be changed.
7. If no valid control command for the current state is written to input, edges at
`CmdChangeRequest` are ignored. To change from a wait to an acting state,
`CmdChangeRequest` has to be TRUE and the according `CntrlCmd` has to be
written to input `CntrlCmd`.
8. If no acting state is active the rising edge at the `SC` input is ignored.
9. If an invalid `CntrlCmd` is written to input `CntrlCmd` and `CmdChangeRequest` is
set to TRUE, the control command

## Interface

### Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| UnitMode | DInt |  Requested unit mode |
| UnitModeChangeRequest | Bool | TRUE: Request unit mode |
| CntrlCmd | DInt | Request control command |
| CmdChangeRequest | Bool | TRUE: Enable change into requested state |
| SC | Bool | State change from FALSE to TRUE (rising edge) triggers state complete signal |
| config | `LPMLV2022_typeConfiguration` | onfiguration (is taken into account in first call after STOP/RUN) |

### Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| UnitModeCurrent |   DInt | Current unit mode |
| StateCurrent |   DInt | Current state |
| StateRequested |   DInt | Requested state |
| StateChangeInProcess |   Bool | State change in process |
| CurDisabledStates |   DWord | Disabled states in current unit mode |
| curHoldCmdCfg |   DWord | Bit locations within the DWORD represent State numbers. A value of 1 in a bit location indicates that the Hold control command is taken into account in the corresponding state |
| curCompleteCmdCfg |   DWord | Bit locations within the DWORD represent State numbers. A value of 1 in a bit location indicates that the Complete control command is taken into account in the corresponding state |
| unitModeChangeNotAllowed |   Bool | TRUE: Requested unit mode change is not allowed (output is reset with the next successful unit mode change or if input 'UnitMode' is set to 0 or if input `UnitModeChangeRequest` is set to FALSE) |
| cntrlCmdNotAllowed |   Bool | TRUE: Control command is not allowed (output is reset with the next successful `CntrlCmd` or if input `CntrlCmd` is set to 0 or if input `CmdChangeRequest` is set to FALSE) |
| diagnostics |   `LPMLV2022_typeDiagnostics` | Diagnostics information |

### Status and error codes

| Status | Meaning | Remedy / notes |
|-----------|------|-------------|
| BYTE#16#00 | MSG_NO_MESSAGE |  Initial value |
| BYTE#16#01 | MSG_MODE_CHANGED_SUCCESSFULLY |  Unit mode changed successfully |
| BYTE#16#02 | MSG_STATE_CHANGED_SUCCESSFULLY |  State changed successfully |
| BYTE#16#03 | MSG_MODE_ALREADY_ACTIVE |  Requested unit mode already active |
| BYTE#16#80 | MSG_MODE_NOT_DEFINED |  Unit mode not defined |
| BYTE#16#81 | MSG_CMD_NOT_DEFINED |  Control command not defined |
| BYTE#16#82 | MSG_REQ_MODE_NOT_CONFIGURED |  Requested unit mode not configured - check `config.EnabledModesCfg` |
| BYTE#16#83 | MSG_MODE_TRANSITION_NOT_ALLOWED |  Unit mode transition in this state not allowed - check `config.ModeTransitionCfg[]` of the current mode and the requested mode. The corresponding state bit must be set for both modes |
| BYTE#16#84 | MSG_CMD_NOT_ALLOWED |  Control command in this state not allowed |
| BYTE#16#85 | MSG_SC_NOT_ALLOWED |  `SC` in this state not allowed |
| BYTE#16#86 | MSG_STATE_CONFIG_FORCED |  State configuration forced to OMAC standard (corrected configuration -> see output `CurDisabledStates`) |
| BYTE#16#87 | MSG_MODE_TRANSITION_NOT_POSSIBLE |  Unit mode transition in this state not possible, because the current state is not available in the requested mode - check `config.DisabledStatesCfg[]` of the requested mode |
| BYTE#16#88 | MSG_SC_OVERRIDDEN_BY_CMD_HOLD |  `SC` overridden by control command Hold |
