NAMESPACE Simatic.Ax.LPMLV2022
    TYPE
        Message : BYTE (
            /// Initial value
            NO_MESSAGE := BYTE#16#00,
            /// Unit mode changed successfully
            MODE_CHANGED_SUCCESSFULLY := BYTE#16#01,
            /// State changed successfully
            STATE_CHANGED_SUCCESSFULLY := BYTE#16#02,
            /// Requested unit mode already active
            MODE_ALREADY_ACTIVE := BYTE#16#03,
            /// Unit mode not defined
            MODE_NOT_DEFINED := BYTE#16#80,
            /// Control command not defined
            CMD_NOT_DEFINED := BYTE#16#81,
            /// Requested unit mode not configured - check 'config.EnabledModesCfg'
            REQ_MODE_NOT_CONFIGURED := BYTE#16#82,
            /// Unit mode transition in this state not allowed - check 'config.ModeTransitionCfg[]' of the current mode and the requested mode. The corresponding state bit must be set for both modes
            MODE_TRANSITION_NOT_ALLOWED := BYTE#16#83,
            /// Control command in this state not allowed
            CMD_NOT_ALLOWED := BYTE#16#84,
            /// SC in this state not allowed
            SC_NOT_ALLOWED := BYTE#16#85,
            /// State configuration forced to OMAC standard
            STATE_CONFIG_FORCED := BYTE#16#86,
            /// Unit mode transition in this state not possible, because the current state is not available in the requested mode - check 'config.DisabledStatesCfg[]' of the requested mode
            MODE_TRANSITION_NOT_POSSIBLE := BYTE#16#87,
            /// SC overridden by control command Hold
            SC_OVERRIDDEN_BY_CMD_HOLD := BYTE#16#88
            );
    END_TYPE
END_NAMESPACE