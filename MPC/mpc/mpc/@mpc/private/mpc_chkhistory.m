function newhist=mpc_chkhistory(hist)
%MPC_CHKHISTORY Check correctness of history field and possibly convert it to
%   CLOCK format
%
%   See DATESTR, DATENUM, DATEVEC, CLOCK

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2007/11/09 20:40:08 $ 

if ischar(hist),
    % Assume time is given in DATESTR format
    newhist=datevec(hist);
    return
end

if isnumeric(hist),
    if numel(hist)==1,
        % Assume time is given in DATENUM format (one number)
        newhist=datevec(hist);
    else
        newhist=hist(:)';
        if length(newhist)~=6,
            ctrlMsgUtils.error('MPC:utility:InvalidHistoryTimeFormat');
        end
    end
end     