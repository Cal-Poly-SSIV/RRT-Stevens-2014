function [outdist,outdistchannels]=getoutdist(MPCobj)
%GETOUTDIST retrieves the model used for representing output disturbances
%
%   outdist=GETOUTDIST(MPCobj) retrieves the model used to generate output
%   disturbances from the mpc object MPCobj.
%
%   [outdist,channels]=GETOUTDIST(MPCobj) also returns the output channels where
%   integrated white noise was added as output disturbance model (empty for
%   user-provided output disturbance models).
%
%   See also SETOUTDIST.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2009/11/09 16:28:14 $   


if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','getoutdist');
end

MPCData=getmpcdata(MPCobj);
ny=MPCData.ny;

if MPCData.OutDistFlag,
    % User defined output disturbance
    outdist=MPCData.OutDistModel;
    outdistchannels=[];
    outdist.OutputName=MPCobj.Model.Plant.OutputName;
    for i=1:size(outdist,2),
        outdist.InputName{i}=sprintf('Noise#%d',i);
    end
    return
end

% Output disturbance is the default one

InitFlag=MPCData.Init;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer) 
    try
        MPCstruct=mpc_struct(MPCobj,[],'mpc_init');
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

% One integrator per channel specified in outdistchannels
outdistchannels=MPCstruct.outdistchannels;

ts=MPCobj.Ts;

outnames=MPCobj.Model.Plant.OutputName;
if isempty(outdistchannels),
    outdist=ss(zeros(ny,0));
else
    nout=length(outdistchannels);
    A=eye(nout);
    B=eye(nout,nout)*ts;
    C=zeros(ny,nout);
    D=zeros(ny,nout);
    for i=1:nout,
        j=outdistchannels(i);
        C(j,i)=1;
    end
    outdist=tf(ss(A,B,C,D,ts));
    for i=1:nout,
        outdist.InputName{i}=[outnames{outdistchannels(i)} '-wn'];
    end
end
outdist.OutputName=MPCobj.Model.Plant.OutputName;