function offset=cloffset(MPCobj)
%CLOFFSET computes the MPC closed-loop DC gain from output disturbances to
%measured outputs based on the unconstrained response (for zero references,
%measured, and unmeasured input disturbances).
%
%   DC=CLOFFSET(MPCobj) returns an (nym,nym) DC gain matrix where
%   nym is the number of measured plant outputs.  MPCobj is an MPC object 
%   specifying the controller for which the closed-loop gain is calculated.
%   DC(i,j) represents the gain from an additive (constant) disturbance
%   on output j to measured output i.  If row i is zero, there will be no
%   steady-state offset on output i.
%
%   See also MPC, MPC/SS.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2007/11/09 20:39:07 $   

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','cloffset');
end

MPCData=getmpcdata(MPCobj);
InitFlag=MPCData.Init;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer)             
    try
        MPCstruct = mpc_struct(MPCobj,[],'base'); % xmpc0=[]
    catch ME
        throw(ME);
    end
    MPCobj = mpc_updatempcdata(MPCobj,MPCstruct,1,1,1);        
    % Before invoking SS, update object (init, ready) when necessary   
    if ~isempty(inputname(1))
        assignin('caller',inputname(1),MPCobj);
    end
else
    MPCstruct=MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct
nym=MPCstruct.nym;
A=MPCstruct.A;
Bu=MPCstruct.Bu;
Cm=MPCstruct.Cm;

try
    sysmpc=ss(MPCobj);
catch ME
    throw(ME);
end

Abar=sysmpc.A;
Bbar=sysmpc.B;
Cbar=sysmpc.C;
Dbar=sysmpc.D;
nxbar=size(Abar,1);

bigC=[Cm,zeros(nym,nxbar)];
bigA=[A+Bu*Dbar*Cm,Bu*Cbar;
    Bbar*Cm,Abar];
bigB=[Bu*Dbar;Bbar];
bigD=eye(nym);

offset=dcgain(ss(bigA,bigB,bigC,bigD,MPCobj.Ts));

