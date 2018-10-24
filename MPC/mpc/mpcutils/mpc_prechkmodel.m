function [Model,nu,ny,nutot,mvindex,mdindex,unindex,myindex]=...
    mpc_prechkmodel(Model,Ts)
% MPC_PRECHKMODEL Check the Model structure, and consistency of Model.Plant.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.12 $  $Date: 2008/06/13 15:25:53 $

verbose = mpccheckverbose;

fields={'Plant','Disturbance','Noise','Nominal'};
names=fieldnames(Model);

% Check names and convert to right case
for i=1:length(names),
    j=find(ismember(lower(fields),lower(names{i}))==1);
    if isempty(j)
        ctrlMsgUtils.error('MPC:utility:InvalidModelField')
    else
        Model.(fields{j})=Model.(names{i});
        if ~strcmp(names{i},fields{j}),
            %remove field
            Model=rmfield(Model,names{i});
        end
    end
end

for i=1:length(fields),
    isf=isfield(Model,fields{i});
    if ~isf,
        Model.(fields{i})=[];
    end
end

% Handle IDMODELs from Identification Toolbox
if isa(Model.Plant,'idmodel'),
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertIDToSS'));
    end
    % Convert Model.Plant to SS:
    [plant,noise,dist]=mpc_id2ss(Model.Plant);
    % dist,noise are a static gains
    if isempty(Model.Disturbance),
        Model.Disturbance=dist;
    else
        Model.Disturbance=dist*Model.Disturbance; 
    end
    if isempty(Model.Noise),
        Model.Noise=noise;
    else
        Model.Noise=noise*Model.Noise;
    end
    Model.Plant=plant;
    clear plant noise dist
end

if ~isa(Model.Plant,'lti'),
    ctrlMsgUtils.error('MPC:utility:ModelIsNotLTI')
end

if length(size(Model.Plant))>2,
    ctrlMsgUtils.error('MPC:utility:ModelIsArray')    
end

if ~isreal(Model.Plant),
    ctrlMsgUtils.error('MPC:utility:ModelIsComplex')        
end

if Model.Plant.Ts==0 && isempty(Ts),
    ctrlMsgUtils.error('MPC:utility:ModelIsContinuous')    
end

% Check correctness of signal types
[mvindex,mdindex,unindex,myindex,uyindex,Model.Plant.InputGroup]=mpc_chkindex(Model.Plant,Model.Plant.InputGroup);

if isempty(mvindex),
    ctrlMsgUtils.error('MPC:utility:ModelHasNoMV')    
end
group=struct('Manipulated',mvindex(:)');
if ~isempty(mdindex), % Matlab 6 doesn't like empty indices
    group.Measured=mdindex(:)';
end
if ~isempty(unindex),
    group.Unmeasured=unindex(:)';
end
Model.Plant.InputGroup=group;

group=struct('Measured',myindex(:)');
if ~isempty(uyindex), % Matlab 6 doesn't like empty indices
    group.Unmeasured=uyindex(:)';
end
Model.Plant.OutputGroup=group;

Model.Nominal=mpc_chkoffsets(Model.Plant,Model.Nominal);

% Nonzero offsets on unmeasured disturbances are not allowed
if max(abs(Model.Nominal.U(unindex)))>0,
    ctrlMsgUtils.error('MPC:utility:ModelHasNonZeroOffsetOnUMD')    
end

[ny,nutot]=size(Model.Plant);% number of outputs and inputs
nu=length(mvindex);   % number of manipulated vars
nym=length(myindex);

% Check for direct feedthrough from manipulated variables to outputs
% We avoid here computing a full state-space realization, just compute the D matrix
Du=zeros(ny,nu);
sys=Model.Plant;
if hasdelay(sys), % Plant model has delays
    if sys.ts==0,
        % Continuous time model, we must discretize it before converting
        % delays to poles in z=0
        sys=c2d(sys,Ts);
    end
    sys=delay2z(sys);
end
if isa(sys,'ss'),
    Du=sys.D(:,mvindex);
elseif isa(sys,'tf'),
    for i=1:ny,
        for j=1:nu,
            num=sys.num{i,mvindex(j)};
            den=sys.den{i,mvindex(j)};
            if (length(num)==length(den)),
                Du(i,j)=num(1)/den(1);
            else
                Du(i,j)=0;
            end
        end
    end
elseif isa(sys,'zpk'),
    for i=1:ny,
        for j=1:nu,
            zer=sys.z{i,mvindex(j)};
            pol=sys.p{i,mvindex(j)};
            if (length(zer)==length(pol)),
                Du(i,j)=1;
            else
                Du(i,j)=0;
            end
        end
    end
    Du=sys.k(:,mvindex).*Du;
end

% check direct feedthrough
if norm(Du,'inf'),
    ctrlMsgUtils.error('MPC:utility:ModelHasDirectFeedthrough')    
end

% Check Model.Disturbance
if ~isempty(Model.Disturbance),
    if isa(Model.Disturbance,'double'),
        % Static gain, convert to LTI
        Model.Disturbance=tf(Model.Disturbance);
    end
    if ~isa(Model.Disturbance,'lti') && ~isa(Model.Disturbance,'idmodel'),
        ctrlMsgUtils.error('MPC:utility:MDModelIsNotLTI')    
    end
    if isa(Model.Disturbance,'lti') && length(size(Model.Disturbance))>2,
        ctrlMsgUtils.error('MPC:utility:MDModelIsArray')    
    end
    if ~isreal(Model.Disturbance),
        ctrlMsgUtils.error('MPC:utility:MDModelIsComplex')        
    end
    nun=length(unindex);
    if nun~=size(Model.Disturbance,1),
        ctrlMsgUtils.error('MPC:utility:MDModelWrongSize', nun)                
    end
    % The observability of the series Disturbance->Plant will be checked
    % by MPC_PRECHKMODEL when the MPC object is first used
end

% Check Model.Noise
if ~isempty(Model.Noise),
    if isa(Model.Noise,'double'),
        % Static gain, convert to LTI
        Model.Noise=tf(Model.Noise);
    end
    if ~isa(Model.Noise,'lti') && ~isa(Model.Noise,'idmodel'),
        ctrlMsgUtils.error('MPC:utility:NoiseModelIsNotLTI')            
    end
    if isa(Model.Noise,'lti') && length(size(Model.Noise))>2,
        ctrlMsgUtils.error('MPC:utility:NoiseModelIsArray')            
    end
    if ~isreal(Model.Noise),
        ctrlMsgUtils.error('MPC:utility:NoiseModelIsComplex')                
    end
    if nym~=size(Model.Noise,1),
        ctrlMsgUtils.error('MPC:utility:NoiseModelWrongSize', nym)                
    end
end

% Set Default I/O Names
uname=Model.Plant.InputName;
for i=1:nutot,
    if isempty(uname{i}),
        [yn,j]=ismember(i,mvindex);
        if yn,
            signal='MV';
            num=j;
        end
        [yn,j]=ismember(i,mdindex);
        if yn,
            signal='MD';
            num=j;
        end
        [yn,j]=ismember(i,unindex);
        if yn,
            signal='UD';
            num=j;
        end
        uname{i}=sprintf('%s%d',signal,num);
    end
end
Model.Plant.InputName=uname;

yname=Model.Plant.OutputName;
uyindex=setdiff((1:ny)',myindex(:));
for i=1:ny,
    if isempty(yname{i}),
        [yn,j]=ismember(i,myindex);
        if yn,
            signal='MO';
            num=j;
        end
        [yn,j]=ismember(i,uyindex);
        if yn,
            signal='UO';
            num=j;
        end
        yname{i}=sprintf('%s%d',signal,num);
    end
end
Model.Plant.OutputName=yname;

if ~isempty(Model.Disturbance) && ~isempty(Model.Disturbance.OutputName{:}) && ~isa(Model.Disturbance,'idmodel'),
    ctrlMsgUtils.error('MPC:utility:MDModelNames')
end