function [ts,A,Cm,Dvm,Bu,Bv,...
    PTYPE,nu,nv,nym,ny,nx,...
    degrees,M,MuKduINV,KduINV,Kx,Ku1,Kut,Kr,Kv,zmin,rhsc0,...
    Mlim,Mx,Mu1,Mv,rhsa0,TAB,optimalseq,utarget,... %rv,anticipate,
    lastx,lastu,p,Jm,DUFree,uoff,yoff,voff,myoff,no_md,no_ref,...
    ref_from_ws,ref_signal,ref_preview,md_from_ws,md_signal,md_preview,...
    maxiter,nxQP,openloopflag,md_inport,no_ym,mv_inport,no_mv,wtab,...
    lims_inport,no_umin,no_umax,no_ymin,no_ymax,...
    switch_inport,no_switch,enable_value,is_multiple] = mpc_get_param_sim

%MPC_GET_PARAM_SIM Get all necessary matrices needed by the MPC S-function

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.14 $  $Date: 2009/03/23 16:41:32 $

MPCstruct=get_param(gcbh,'Userdata');

% If there is no MPC object set all param to be empty - jgo
openloopflag = 0;
if isempty(MPCstruct) || ~isstruct(MPCstruct)
    [ts,A,Cm,Dvm,Bu,Bv,...
        PTYPE,nu,nv,nym,ny,nx,...
        degrees,M,MuKduINV,KduINV,Kx,Ku1,Kut,Kr,Kv,zmin,rhsc0,...
        Mlim,Mx,Mu1,Mv,rhsa0,TAB,optimalseq,utarget,... %rv,anticipate,
        lastx,lastu,p,Jm,DUFree,uoff,yoff,voff,myoff,no_md,no_ref,...
        ref_from_ws,ref_signal,ref_preview,md_from_ws,md_signal,md_preview,...
        maxiter,nxQP,md_inport,no_ym,mv_inport,no_mv,wtab,...
        lims_inport,no_umin,no_umax,no_ymin,no_ymax,...
        switch_inport,no_switch,enable_value,is_multiple] = deal(0);
    % (jgo) When the mask is initialized with no MPC object the userdata
    % property is used to store the number of outputs. This must be passed
    % to the mpc_sfun so that it can initialize the number of open loop
    % states
    nu = eval(get_param(gcb,'n_mv'));
    openloopflag = 1;
    return
end

names=fieldnames(MPCstruct);

for i=1:length(names),
    aux=names{i};
    eval(sprintf('%s=MPCstruct.%s;',aux,aux));
end

% Get name of root simulink diagram
root=bdroot(gcs);

% Get start time
StartTimeExpression = get_param(root,'StartTime');
t0 = str2double(StartTimeExpression);
if isnan(t0)
    % a variable in model workspace?
    try 
        mwk = get_param(root,'ModelWorkspace');
        t0 = mwk.evalin(StartTimeExpression);
    catch ME
        try
            t0 = evalin('base',StartTimeExpression);
        catch ME
            ctrlMsgUtils.error('MPC:utility:InvalidStartTime');
        end
    end
end
if ~isreal(t0) || ~isscalar(t0) || t0<0
    ctrlMsgUtils.error('MPC:utility:InvalidStartTime');
end

% Define ref_preview_signal from base workspace
ref_signal=[];
if MPCstruct.ref_from_ws,
    try
        % Try evaluating signal_name
        ref_signal=evalin('base',ref_signal_name);
    catch ME
        ctrlMsgUtils.error('MPC:utility:InvalidRefPreviewSignal',ref_signal_name);
    end
    ref_signal=mpc_chk_ext_signal(ref_signal,'Reference',ny,ts,yoff,t0); %#ok<NODEF,NODEF>
end
MPCstruct.ref_signal=ref_signal;

% Define md_preview_signal from base workspace
md_signal=[];
if MPCstruct.md_from_ws,
    try
        % Try evaluating signal_name
        md_signal=evalin('base',md_signal_name);
    catch ME
        ctrlMsgUtils.error('MPC:utility:InvalidMDPreviewSignal',md_signal_name);
    end
    md_signal=mpc_chk_ext_signal(md_signal,'Measured disturbance',nv-1,ts,voff,t0); %#ok<NODEF,NODEF>
end
MPCstruct.md_signal=md_signal;

set_param(gcbh,'Userdata',MPCstruct);
