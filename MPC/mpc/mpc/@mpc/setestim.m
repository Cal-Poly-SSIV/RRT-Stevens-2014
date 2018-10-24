function setestim(MPCobj,M)
%SETESTIM modifies an MPC object's linear state estimator.
%
%   SETESTIM(MPCobj,M) where MPCobj is an MPC object -- changes the default
%   Kalman estimator gain stored in MPCobj to that specified by matrix M.
%
%   SETESTIM(MPCobj,'default') restores the default Kalman gain.
%
%   The estimator used in MPC is
%            y[n|n-1] = Cm x[n|n-1] + Dvm v[n]
%            x[n|n] = x[n|n-1] + M (y[n]-y[n|n-1])
%            x[n+1|n] = A x[n|n] + Bu u[n] + Bv v[n]
%
%   where v[n] are the measured disturbances
%         u[n] are the manipulated plant inputs
%         y[n] are the measured plant outputs
%         x[n] are the state estimates
%
%   To design an estimator by pole placement, one can use the commands
% 
%   [M,A,Cm]=getestim(MPCobj);
%   L=place(A',Cm',observer_poles)';
%   M=A\L;
%   setestim(MPCobj,M);
%
%   assuming that the system A*M=L is solvable.
%
%   NOTE:  variable M in SETESTIM is equivalent to variable M in DKALMAN.
%
%   See also GETESTIM, DKALMAN, MPCPROPS.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2007/11/09 20:39:43 $   

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','setestim');
end

MPCData=getmpcdata(MPCobj);
InitFlag=MPCData.Init;
update_flag=0;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer) 
    try
        MPCstruct=mpc_struct(MPCobj,[],'base'); % xmpc0=[]
    catch ME
        throw(ME);
    end
    update_flag=1;
else
    MPCstruct=MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct

nym=MPCstruct.nym;
nx=MPCstruct.nx;

A=MPCstruct.A;
Cm=MPCstruct.Cm;

if nargin>=2,
    if ischar(M),
        if strcmp(M,'default'),
            MPCstruct=mpc_struct(MPCobj,[],'base');
            update_flag=1;
        else
            ctrlMsgUtils.error('MPC:estimation:InvalidEstimOption','setestim');
        end
    else        
        if ~isa(M,'double') || ~all(isfinite(M(:)))
            ctrlMsgUtils.error('MPC:estimation:InvalidEstimGain','setestim');
        else
            [n,m]=size(M);
            if (n~=nx) || (m~=nym), 
                ctrlMsgUtils.error('MPC:estimation:InvalidEstimGainSize','setestim',nx,nym);
            end
            e=eig(A-A*M*Cm);
            if any(abs(e)>1),
                warning('MPC:estimation:Unstable',ctrlMsgUtils.message('MPC:estimation:Unstable'));    
            end
            MPCstruct.M=M;
            update_flag=1;
        end
    end
end

if update_flag,
    MPCobj = mpc_updatempcdata(MPCobj,MPCstruct,1,1,1);        
    % Before invoking SS, update object (init, ready) when necessary   
    if ~isempty(inputname(1))
        assignin('caller',inputname(1),MPCobj);
    end
end
