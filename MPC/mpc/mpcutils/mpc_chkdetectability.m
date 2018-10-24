function yesno=mpc_chkdetectability(A,C,Ts)
% MPC_CHKDETECTABILITY Check whether a pair (A,C) is detectable
%
% Usage: yesno=MPC_CHKDETECTABILITY(A,C,Ts) returns yesno=1 if (A,C) is detectable,
% i.e. it does not have unstable or marginally stable unobservable modes. 
% Ts is the sampling time (Ts=0 means continuous time)

%   Authors: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/19 23:19:19 $

error(nargchk(3,3,nargin));
n=size(A,1);
p=size(C,1);
if n>0,
    if Ts==0,
        % Continuous-time
        X1=care(A',C',eye(n),eye(p),[],[],'factor');
    else
        % Discrete-time
        X1=dare(A',C',eye(n),eye(p),[],[],'factor');
    end
    yesno=(rank(X1)==n);
else
    % Empty state vector, no state to observe
    yesno=1;
end

