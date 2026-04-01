# LPMLV2022.Message

| Parameter | Type | Value | Description |
| ---------- | ----- | ------ | ------------ |
| NO_MESSAGE | BYTE | BYTE#16#00 | Initial value |
| MODE_CHANGED_SUCCESSFULLY | BYTE | BYTE#16#01 | Unit mode changed successfully |
| STATE_CHANGED_SUCCESSFULLY | BYTE | BYTE#16#02 | State changed successfully |
| MODE_ALREADY_ACTIVE | BYTE | BYTE#16#03 | Requested unit mode already active |
| MODE_NOT_DEFINED | BYTE | BYTE#16#80 | Unit mode not defined |
| CMD_NOT_DEFINED | BYTE | BYTE#16#81 | Control command not defined |
| REQ_MODE_NOT_CONFIGURED | BYTE | BYTE#16#82 | Requested unit mode not configured - check 'config.EnabledModesCfg' |
| MODE_TRANSITION_NOT_ALLOWED | BYTE | BYTE#16#83 | Unit mode transition in this state not allowed - check 'config.ModeTransitionCfg[]' of the current mode and the requested mode. The corresponding state bit must be set for both modes |
| CMD_NOT_ALLOWED | BYTE | BYTE#16#84 | Control command in this state not allowed |
| SC_NOT_ALLOWED | BYTE | BYTE#16#85 | SC in this state not allowed |
| STATE_CONFIG_FORCED | BYTE | BYTE#16#86 | State configuration forced to OMAC standard |
| MODE_TRANSITION_NOT_POSSIBLE | BYTE | BYTE#16#87 | Unit mode transition in this state not possible, because the current state is not available in the requested mode - check 'config.DisabledStatesCfg[]' of the requested mode |
| SC_OVERRIDDEN_BY_CMD_HOLD | BYTE | BYTE#16#88 | SC overridden by control command Hold |
