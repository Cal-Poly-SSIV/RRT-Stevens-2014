function indist=getindist(MPCobj)
%GETINDIST retrieves the model used for representing input disturbances
%
%   indist=GETINDIST(MPCobj) retrieves the model used by the mpc object 
%   MPCobj to represent unmeasured input disturbances entering the plant.
%
%   See also SETINDIST, SET.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2009/11/09 16:28:13 $   

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','getindist');
end

MPCData=getmpcdata(MPCobj);
unindex=MPCData.unindex;

if isempty(unindex),
    indist=ss;
    return
end

if ~isempty(MPCobj.Model.Disturbance),
    % User defined input disturbance
    indist=MPCobj.Model.Disturbance;
    indist.OutputName=MPCobj.Model.Plant.InputName(unindex);
    for i=1:size(indist,2),
        if isempty(indist.InputName{i}),
            indist.InputName{i}=sprintf('Noise#%d',i);
        end
    end
    indist=mpc_chkoutdistmodel(indist,length(unindex),MPCobj.Ts,'Input');
    return
end

% Input disturbance model is the default one
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

% One integrator per input channel, assuming the system remains observable
indistchannels=MPCstruct.indistchannels;

ts=MPCobj.Ts;
nun=length(unindex);
nindist=length(indistchannels);
notindist=setdiff(1:nun,indistchannels);
M=eye(nun);
M(:,notindist)=[];
indist=c2d(M*tf(1,[1 0]),ts);

% User defined input disturbance
innames=MPCobj.Model.Plant.InputName(unindex);
indist.OutputName=innames;
for i=1:nindist,
    if isempty(indist.InputName{i}),
        indist.InputName{i}=[innames{indistchannels(i)} '-wn'];
    end
end