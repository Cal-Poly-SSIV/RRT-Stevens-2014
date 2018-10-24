function this = mpcstate(MPCobj,plant,dist,noise,lastu)  
%MPCSTATE Constructor

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2007/11/09 20:40:39 $   

this = mpcdata.mpcstate;

if nargin==0
    return
end
    
if ~isa(MPCobj,'mpc'),
    ctrlMsgUtils.error('MPC:general:InvalidMPCObject');    
end

MPCData = getmpcdata(MPCobj);
if ~MPCData.Init,
    % Initialize MPC object
    try
        MPCstruct = mpc_struct(MPCobj,[],'base');
    catch ME
        throw(ME);
    end
    MPCData.MPCstruct = MPCstruct;
    MPCData.Init = 1;
    MPCData.QP_ready = 1;
    MPCData.L_ready = 1;
    setmpcdata(MPCobj,MPCData);
    % Before invoking SS, update object (init, ready) when necessary   
    if ~isempty(inputname(1))
        assignin('caller',inputname(1),MPCobj);
    end
else
    MPCstruct = MPCData.MPCstruct;
end

nxp = MPCstruct.nxp;
nxumd = MPCstruct.nxumd;
nxnoise = MPCstruct.nxnoise;
nu = MPCstruct.nu;

% Possibly assign default values
if nargin<2,
    plant = MPCstruct.xoff(1:nxp);
end
if nargin<3,
    dist = MPCstruct.xoff(nxp+1:nxp+nxumd);
end
if nargin<4,
    noise = MPCstruct.xoff(nxp+nxumd+1:nxp+nxumd+nxnoise);
end
if nargin<5,
    lastu = MPCstruct.uoff;
end

% Assign props
set(this,'Plant',plant,'Disturbance',dist,'Noise',noise,'LastMove',lastu);

try
    mpc_chkstate(this,'Plant',nxp,MPCstruct.xoff(1:nxp));
    mpc_chkstate(this,'Disturbance',nxumd,MPCstruct.xoff(nxp+1:nxp+nxumd));
    mpc_chkstate(this,'Noise',nxnoise,MPCstruct.xoff(nxp+nxumd+1:nxp+nxumd+nxnoise));
    mpc_chkstate(this,'LastMove',nu,MPCstruct.uoff);
catch ME
    throw(ME);
end
