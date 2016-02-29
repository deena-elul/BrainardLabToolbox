% Method to send a parameter value
% ex.: OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something');
% or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something', params.protocolName, timeOutSecs, 2.0, 'maxAttemptsNum', 3);
% or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.go, []);

function sendParamValue(obj, paramNameAndValue,  varargin)
    
    % parse input
    defaultTimeOutSecs = 2;
    defaultMaxAttemptsNum = 3;
    p = inputParser;
    p.addRequired('obj');
    p.addRequired('paramNameAndValue', @iscell);
    p.addParamValue('timeOutSecs', defaultTimeOutSecs,   @isnumeric);
    p.addParamValue('maxAttemptsNum', defaultMaxAttemptsNum, @isnumeric);
    p.parse(obj, paramNameAndValue, varargin{:});
    
    
    % Send the message
    messageLabel = p.Results.paramNameAndValue{1};
    if (numel(p.Results.paramNameAndValue) == 2)
    	messageValue = p.Results.paramNameAndValue{2};
    else
        messageValue = nan;
    end
    status = p.Results.obj.sendMessage(messageLabel, 'withValue', messageValue, p.Results.timeOutSecs, 'maxAttemptsNum', p.Results.maxAttemptsNum);

    
    % Get this backtrace of all functions leading to this point
    dbs = dbstack;
    backTrace = ''; depth = length(dbs);
    while (depth >= 1)
        backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
        depth = depth - 1;
    end
    
    % Check status to ensure we received a 'TRANSMITTED_MESSAGE_MATCHES_EXPECTED' message
    assert(strcmp(status, p.Results.obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED), sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, p.Results.obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, status));
end
