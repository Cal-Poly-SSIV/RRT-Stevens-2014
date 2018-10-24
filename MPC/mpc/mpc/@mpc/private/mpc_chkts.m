function mpc_chkts(Ts)

%MPC_CHKTS Check correctness of sampling time

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2007/11/09 20:40:19 $   

%Sample time must be a scalar finite real positive number or empty.
if ~isempty(Ts)
    if ~isscalar(Ts) || ~isreal(Ts) || ~isfinite(Ts) || Ts<=0,
        ctrlMsgUtils.error('MPC:utility:InvalidSampleTime');
    end
end
