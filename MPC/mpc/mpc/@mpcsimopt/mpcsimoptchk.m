function [MPCstruct,params,SimOptions]=mpcsimoptchk(SimOptions,MPCobj)
%MPCSIMOPTCHK Check SimOptions object

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2007/11/09 20:40:46 $   

error(nargchk(2,2,nargin));

verbose = mpccheckverbose;

if ~isa(MPCobj,'mpc')
    ctrlMsgUtils.error('MPC:general:Invalid2ndMPCObject','mpcsimoptchk');        
end
if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','mpcsimoptchk');        
end

MPCData=getmpcdata(MPCobj);
if ~MPCData.Init,
    % This should never happen
    ctrlMsgUtils.error('MPC:general:Invalid2ndMPCObject','mpcsimoptchk');        
end
MPCstruct=MPCData.MPCstruct;

constraints=SimOptions.Constraints;
if isempty(constraints),
    constraints='on';
end
SimOptions.Constraints=constraints;
constraints=strcmp(constraints,'on');

simBar=SimOptions.StatusBar;
if isempty(simBar),
    simBar='off';
end
SimOptions.StatusBar=simBar;

% bar
simBar=strcmp(simBar,'on');

md_preview=SimOptions.MDLookAhead;
if isempty(md_preview),
    md_preview='off';
end
SimOptions.MDLookAhead=md_preview;

ref_preview=SimOptions.RefLookAhead;
if isempty(ref_preview),
    ref_preview='off';
end
SimOptions.RefLookAhead=ref_preview;

% Check preview flags
if ~ischar(ref_preview),
    ref_preview=''; % to generate an error
end
if ~strcmp(ref_preview,'on') && ~strcmp(ref_preview,'off'),
    ctrlMsgUtils.error('MPC:computation:InvalidSimOptRefPreviewFlag');
end
MPCstruct.ref_preview=double(strcmp(ref_preview,'on'));

if ~ischar(md_preview),
    md_preview=''; % to generate an error
end
if ~strcmp(md_preview,'on') && ~strcmp(md_preview,'off'),
    ctrlMsgUtils.error('MPC:computation:InvalidSimOptMDPreviewFlag');    
end
MPCstruct.md_preview=double(strcmp(md_preview,'on'));

MPCstruct.ref_from_ws=1; %boolean(1);
MPCstruct.md_from_ws=1; %boolean(1);
MPCstruct.no_ref=0; %boolean(0);
MPCstruct.no_md=0; %boolean(0);
MPCstruct.no_ym=0; %boolean(0);

x0=SimOptions.ControllerInitialState;
if isempty(x0),
    x0=mpcstate(MPCobj);
end
if ~isa(x0,'mpcdata.mpcstate'),
    ctrlMsgUtils.error('MPC:computation:InvalidState','mpcsimoptchk');    
end
SimOptions.ControllerInitialState=x0;

ny=MPCstruct.ny;
nv=MPCstruct.nv;
nym=MPCstruct.nym;
nu=MPCstruct.nu;
nd=length(MPCData.unindex);
% Note: nd here equals the number of UMDs to Plant, while MPCstruct.nd denotes
%       the number of unmeasured disturbances entering the extended system

nxp=MPCstruct.nxp;
nxumd=MPCstruct.nxumd;
nxnoise=MPCstruct.nxnoise;
xoff=MPCstruct.xoff;
uoff=MPCstruct.uoff;

plantstates=1:nxp;
diststates=nxp+1:nxp+nxumd;
noisestates=nxp+nxumd+1:nxp+nxumd+nxnoise;

try
    xp0=mpc_chkstate(x0,'Plant',nxp,xoff(plantstates'));
    xd0=mpc_chkstate(x0,'Disturbance',nxumd,xoff(diststates'));
    xn0=mpc_chkstate(x0,'Noise',nxnoise,xoff(noisestates'));
    u0=mpc_chkstate(x0,'LastMove',nu,uoff);
catch ME
    throw(ME);
end
x0=[xp0;xd0;xn0]; % Offset-free initial state

ynoise=SimOptions.OutputNoise;
if isempty(ynoise),
    ynoise=zeros(1,nym);
end
if any(isinf(ynoise(:))) || ~isreal(ynoise),
    ynoise=zeros(0,nym+1); % to generate an error
end
[n_ny,m]=size(ynoise);
if m~=nym,
    ctrlMsgUtils.error('MPC:computation:InvalidMeasurementNoise',nym);    
end
SimOptions.OutputNoise=ynoise;

unoise=SimOptions.InputNoise;
if isempty(unoise),
    unoise=zeros(1,nu);
end
if any(isinf(unoise(:))) || ~isreal(unoise),
    unoise=zeros(0,nu+1); % to generate an error
end
[n_nu,m]=size(unoise);
if m~=nu,
    ctrlMsgUtils.error('MPC:computation:InvalidInputNoise',nu);        
end
SimOptions.InputNoise=unoise;

openloop=SimOptions.OpenLoop;
if isempty(openloop),
    openloop='on';
end
SimOptions.OpenLoop=openloop;
openloop=strcmp(openloop,'on');

mv_signal=SimOptions.MVSignal;
if isempty(mv_signal),
    mv_signal=zeros(1,nu);
end
SimOptions.MVSignal=mv_signal;

if ~openloop && ~isempty(mv_signal) && norm(mv_signal,'inf')>0,
    if verbose,
        fprintf('-->%s',ctrlMsgUtils.message('MPC:computation:ClosedLoopIgnoreMV'));        
    end
end

% Check correctness of manipulated var signal
if ~isa(mv_signal,'double'),
    mv_signal=zeros(0,nu+1); % to generate an error
elseif any(isinf(mv_signal(:))) || ~isreal(mv_signal),
    mv_signal=zeros(0,nu+1); % to generate an error
end
[n_mv,m]=size(mv_signal);
if m~=nu,
    ctrlMsgUtils.error('MPC:computation:InvalidMVSignal',nu);    
end

% Check plant model provided by the user
sModel=SimOptions.Model;
if isempty(sModel),
    sModel=[];
end

if ~isempty(sModel),
    if isa(sModel,'lti'), % |~isa(sModel,'fir'), %<<<<<========== CHECK OUT for FIR models !!!
        sModel=struct('Plant',sModel);
    end
    if ~isa(sModel,'struct'),
        ctrlMsgUtils.error('MPC:computation:InvalidSimModel');            
    end
    if isfield(sModel,'Disturbance'),
        if verbose,
            fprintf('-->%s',ctrlMsgUtils.message('MPC:computation:IgnoreDisturbanceSignal'));
        end
    end
    if isfield(sModel,'Noise'),
        if verbose,
            fprintf('-->%s',ctrlMsgUtils.message('MPC:computation:IgnoreNoiseSignal'));
        end
    end

    % Default to MPCobj.Model
    if isfield(sModel,'Plant'),
        if isempty(sModel.Plant),
            sModel.Plant=MPCobj.Model.Plant;
        end
    end

    % Inherit sModel.Nominal from MPCobj.Model.Nominal
    stateinherited=0;
    if ~isfield(sModel,'Nominal') || isempty(sModel.Nominal),
        sModel.Nominal=MPCobj.Model.Nominal;
        stateinherited=1;
    else
        % Partial inheritance
        if ~isfield(sModel.Nominal,'X'),
            sModel.Nominal.X=MPCobj.Model.Nominal.X;
            stateinherited=1;
        end
        if ~isfield(sModel.Nominal,'DX'),
            sModel.Nominal.DX=MPCobj.Model.Nominal.DX;
            stateinherited=1;
        end
        if ~isfield(sModel.Nominal,'U'),
            sModel.Nominal.U=MPCobj.Model.Nominal.U;
        end
        if ~isfield(sModel.Nominal,'Y'),
            sModel.Nominal.U=MPCobj.Model.Nominal.Y;
        end
    end

    % Check if dimensions of Nominal.X, Nominal.DX are ok
    if stateinherited && isa(MPCobj.Model.Plant,'ss'), % if Model.Plant is not SS, then Nominal.X/DX=[], no problem.
        if ~isa(sModel.Plant,'ss') || size(MPCobj.Model.Plant.A,1)~=size(sModel.Plant.A,1),
            sModel.Nominal.X=[];
            sModel.Nominal.DX=[];
            if norm(MPCobj.Model.Nominal.X)>0 || norm(MPCobj.Model.Nominal.DX)>0,
                if verbose,
                    fprintf('-->%s',ctrlMsgUtils.message('MPC:computation:NominalValueIncompatible'));
                end
            end
        end
    end

    % Check the simModel structure and consistencies
    swarn=warning;
    warning off

    Ts=MPCobj.Ts;

    try
        [sModel,snu,sny,snutot,smvindex,smdindex,sunindex,smyindex]=mpc_prechkmodel(sModel,Ts);
    catch ME
        warning(swarn)
        throw(ME);
    end

    SimOptions.Model=sModel;

    snym=length(smyindex);
    snv=length(smdindex);
    snd=length(sunindex);

    % Check number of inputs,outputs
    nu=MPCstruct.nu;
    if snu~=nu,
        warning(swarn)
        ctrlMsgUtils.error('MPC:computation:InvalidSimModelPlantMV',nu);                    
    end
    if sny~=ny,
        warning(swarn)
        ctrlMsgUtils.error('MPC:computation:InvalidSimModelPlantAllOutput',ny);                    
    end
    if snym~=nym,
        warning(swarn)
        ctrlMsgUtils.error('MPC:computation:InvalidSimModelPlantMO',nym);                    
    end
    if snv~=nv-1,
        warning(swarn)
        ctrlMsgUtils.error('MPC:computation:InvalidSimModelPlantMD',nv);                    
    end
    if ~all(smyindex==MPCData.myindex),
        warning(swarn)
        ctrlMsgUtils.error('MPC:computation:InvalidSimModelPlantMOMatch');                    
    end
    if ~all(smvindex==MPCData.mvindex),
        warning(swarn)
        ctrlMsgUtils.error('MPC:computation:InvalidSimModelPlantMVMatch');                    
    end
    if ~all(smdindex==MPCData.mdindex),
        warning(swarn)
        ctrlMsgUtils.error('MPC:computation:InvalidSimModelPlantMDMatch');                    
    end

    sPlant=sModel.Plant;
    sNominal=sModel.Nominal;

    try
        [smodel,ts,sx0,su1,suoff,syoff,sxoff,sdxoff]=mpc_chkmodel(sPlant,Ts,sNominal,[],[],smvindex,smyindex);
    catch ME
        warning(swarn)
        throw(ME);
    end

    % Offsets for UMDs are not allowed by MPC_CHKMODEL, so there's no need
    % to consider them here

    svoff=suoff(smdindex);
    suoff=suoff(smvindex);
    smyoff=syoff(smyindex);
    smdindex=[smdindex;snutot+1]; % The last input is the MD introduced to model plant offsets
    snx=size(smodel.A,1);

    MPCstruct.Ap=smodel.A;
    MPCstruct.Bup=smodel.B(:,smvindex);
    MPCstruct.Bvp=smodel.B(:,smdindex);
    MPCstruct.Bdp=smodel.B(:,sunindex);
    MPCstruct.Cp=smodel.C;
    MPCstruct.Dvp=smodel.D(:,smdindex);
    MPCstruct.Ddp=smodel.D(:,sunindex);
    MPCstruct.dxpoff=sdxoff;
    MPCstruct.nxp=snx;
    MPCstruct.ndp=snd;
    MPCstruct.xpoff=sxoff;
    MPCstruct.ypoff=syoff;
    MPCstruct.upoff=suoff;
    MPCstruct.vpoff=svoff;

    warning(swarn)

else
    % Do nothing, default are already defined and obtained from MPCobj.Model

    MPCstruct.ypoff=MPCstruct.yoff;
    MPCstruct.upoff=MPCstruct.uoff;
    MPCstruct.vpoff=MPCstruct.voff;
    MPCstruct.xpoff=MPCstruct.xoff(1:nxp); % Only nominal values of Plant
    MPCstruct.ndp=nd;
end

% Check initial condition on Plant
nxp=MPCstruct.nxp; % This may have changed if sModel~=Model
x0plant=SimOptions.PlantInitialState;
if isempty(x0plant),
    x0plant=MPCstruct.xpoff(:)';
end
% Check correctness of x0plant
if ~isa(x0plant,'double'),
    x0plant=zeros(0,nxp+1); % to generate an error
elseif any(isinf(xp0(:)))
    x0plant=zeros(0,nxp+1); % to generate an error
end
x0plant=x0plant(:);
[n_xp0,m]=size(x0plant);
if n_xp0~=nxp,
    ctrlMsgUtils.error('MPC:computation:InvalidStateSize',nxp);    
end
MPCstruct.xp0=x0plant;
SimOptions.PlantInitialState=x0plant;

% Check correctness of unmeasured disturbance signal
ndp=MPCstruct.ndp;
d=SimOptions.UnmeasuredDisturbance;
if isempty(d),
    d=zeros(1,ndp);
end
if ~isa(d,'double'),
    d=zeros(0,ndp+1); % to generate an error
elseif any(isinf(d(:)))
    r=zeros(0,ndp+1); % to generate an error
end
[n_d,m]=size(d);
if m~=ndp,
    ctrlMsgUtils.error('MPC:computation:InvalidUMDSignal',ndp);                    
end

MPCstruct.unconstr=double(~constraints); % Flag. If =1, the MPC constraints are removed
MPCstruct.openloop=double(openloop);     % Flag. If =1, open-loop simulation is run
MPCstruct.mv_signal=mv_signal';   % Sequence of manipulated vars (with offset) for open-loop simulation
MPCstruct.lastu=u0;
MPCstruct.lastx=x0;

params=struct('n_d',n_d,'n_ny',n_ny,'n_nu',n_nu,'n_mv',n_mv,...
    'd',d,'ynoise',ynoise,'unoise',unoise,'mv_signal',mv_signal,...
    'plantstates',plantstates,'diststates',diststates,'noisestates',noisestates,...
    'simBar',simBar,'u0',u0);
