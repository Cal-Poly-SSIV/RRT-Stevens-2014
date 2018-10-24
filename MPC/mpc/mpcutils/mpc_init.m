function mpc_init
% MPC_INIT Extract data from MPC Object

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.20 $  $Date: 2008/05/31 23:21:58 $


% Get parameters from MPC block

%gc=get_param(gcb,'Parent'); % Use this when InitFcn or StartFcn is part of the mpcsfun block
gc=gcbh;  % Use this when InitFcn or StartFcn is part of the MPC block

% (jgo) run open loop if MPC is empty
mpcobjname = strtrim(get_param(gc,'mpcobj'));
if isempty(mpcobjname)
    nmv = eval(get_param(gc,'n_mv'));
    if ~isnumeric(nmv) || length(nmv)~=1
        set_param(bdroot(gcs),'SimulationCommand','Stop');
    end
    set_param(gc,'Userdata',[]);
    return
end

mpcobjname=strtrim(get_param(gc,'mpcobj'));
InitialState=strtrim(get_param(gc,'x0'));
if isempty(InitialState),
    InitialState='[]';
end

ref_from_ws = get_param(gc,'ref_from_ws');
ref_signal_name = get_param(gc,'ref_signal_name');
if isempty(ref_signal_name),
    ref_signal_name='[]';
end
ref_preview = get_param(gc,'ref_preview');

md_from_ws = get_param(gc,'md_from_ws');
md_signal_name = get_param(gc,'md_signal_name');
if isempty(md_signal_name),
    md_signal_name='[]';
end
md_preview = get_param(gc,'md_preview');

% The object name is obtained from the mask as a string. It must be evaluated.
xmpc0=evalin('base',InitialState); % This may change mpcobj if InitialState=mpcstate(mpcobj)

% Signal enabling the optimization. QP is NOT formed and solved when
% the switching signal is enabled and connected to the MPC block and
% the switching signal is not equal to the enable_value
% This is used with multiple MPC blocks, to enable one block at the time.
enable_value=str2double(strtrim(get_param(gc,'enable_value')));

% The flag "is_multiple" distinguishes between stand-alone MPC blocks and
% blocks that belong to a multiple MPC block set. 
is_multiple=str2double(strtrim(get_param(gc,'is_multiple')));
if is_multiple,
    gcp=get_param(get_param(gc,'Parent'),'Handle');
end

% from_project=get_param(gc,'from_project');
% MPCfromWS=0;
% if strcmp(from_project,'off'),
%     % MPC controller from workspace
%     if ~isempty(mpcobjname),
%         [GUIopen,hGUI]=mpc_getGUIstatus(gc);
%         if ~GUIopen,
%             MPCfromWS=1;
%         else
%             % Get current controller in the GUI
%             mpcobj=hGUI.getController(mpcobjname);
%             if isempty(mpcobj),
%                 % Controller is no more in the GUI
%                 MPCfromWS=1;
%             end
%         end
%     else
%         mpcobj=mpc;
%     end
%     if MPCfromWS,
%         try
%             % Load from workspace
%             mpcobj=evalin('base',mpcobjname);
%         catch ME
%             throw(ME);
%         end
%     end
% else
%     % MPC controller from project
%     project_file=get_param(gc,'project_file');    
%     project_name=get_param(gc,'project_name');
%     
%     task_name=get_param(gc,'task_name');
% 
%     hmask=maskhandle;
%     if ~isempty(hmask), % mask is open
%         % Is the GUI also open ?
%         [GUIopen,hGUI]=mpc_getGUIstatus(gc);
%         if GUIopen
%             % Load from GUI (if GUI and mask is open)
%             % Extracts "current" MPC object most recently viewed/modified
%             mpcobj=hGUI.getController;
%         end
%     else
%         % Load from project (GUI closed)
%         mpcobj=mpc_loadobj(project_file,project_name,task_name,mpcobjname);
%     end
% end

MPCfromWS=0;
if ~isempty(mpcobjname)
    [GUIopen,hGUI]=mpc_getGUIstatus(gc);
    if ~GUIopen,
        MPCfromWS=1;
    else
        % Get current controller in the GUI
        mpcobj=hGUI.getController(mpcobjname);
        if isempty(mpcobj),
            % Controller is no more in the GUI
            MPCfromWS=1;
        end
    end
else
    mpcobj=mpc;
end
if MPCfromWS,
    try
        % Load from workspace
        mpcobj=evalin('base',mpcobjname);
    catch ME
        throw(ME);
    end
end

if ~isa(mpcobj,'mpc'),
    ctrlMsgUtils.error('MPC:designtool:InvalidMPCObject',gcb);
end
if isempty(mpcobj),
    ctrlMsgUtils.error('MPC:designtool:EmptyMPCObject',gcb);
end

MPCData=getmpcdata(mpcobj);
InitFlag=MPCData.Init;

nu=MPCData.nu;
ny=MPCData.ny;
nv=length(MPCData.mdindex)+1;

if isfield(MPCData,'MPCstruct'),
    MPCstruct=MPCData.MPCstruct;
else
    MPCstruct='';
end
if ~isfield(MPCstruct,'wtab'),      % Reset objects saved in earlier 
    InitFlag=0;                     % versions of the MPC toolbox
    pack(mpcobj);
end

% Determine if measured disturbance port is connected
no_md=false;
thisports=get_param(gc,'PortConnectivity');
if ~is_multiple,
    md_inport = get_param(gc,'md_inport');
    ports=thisports;
    port=3;
else
    md_inport = get_param(gcp,'md_inport_multiple');
    ports=get_param(gcp,'PortConnectivity');
    port=4;
end

if strcmp(md_inport,'on'),
    % MD signal enabled
    if ports(port).SrcBlock<0,
        % Measured disturbance is not connected, but Simulink has added a
        % scalar zero
        no_md=true;
    end
else
    no_md=true;
end

if (~no_md) && (nv-1==0),
    ctrlMsgUtils.error('MPC:designtool:MDSignalInSLButInModel',gcb);
end

no_mv=false; % This remains false in case of multiple MPC's
if ~is_multiple,
    % Determine if external MV port is connected
    mv_inport = get_param(gc,'mv_inport');
    if strcmp(mv_inport,'on'),
        % MV signal enabled
        if strcmp(md_inport,'on'),
            port=4;
        else
            port=3;
        end
        if thisports(port).SrcBlock<0,
            % External manipulated variables is not connected, but Simulink 
            % has added a scalar zero
            no_mv=true;
        end
    else
        no_mv=true;
    end
else
    mv_inport='on';
end

% Determine if ports for varying limits and switching signal are connected
no_umin=false;
no_umax=false;
no_ymin=false;
no_ymax=false;
no_switch=false;

if ~is_multiple,
    lims_inport = get_param(gc,'lims_inport');
    switch_inport = get_param(gc,'switch_inport');
else
    lims_inport = get_param(gcp,'lims_inport_multiple');
    switch_inport = 'on'; % A switching signal is always present in multiple MPC block
end

if strcmp(switch_inport,'on'),
    % SWITCH signal is enabled (always enabled in case of multiple MPC's)
    if ~is_multiple,
        port=3;
        if strcmp(md_inport,'on'),
            port=port+1;
        end
        if strcmp(mv_inport,'on'),
            port=port+1;
        end
        if strcmp(lims_inport,'on'),
            port=port+4;
        end
    else
        port=1;
    end
    if ports(port).SrcBlock<0,
        % External SWITCH signal is not connected, but Simulink
        % has added a scalar zero
        no_switch=true;
    end
else
    no_switch=true;
end

if strcmp(lims_inport,'on'),
    % LIMS signals enabled
    if ~is_multiple,
        if strcmp(md_inport,'on'),
            port=4;
        else
            port=3;
        end
        if strcmp(mv_inport,'on'),
            port=port+1;
        end
    else
        if strcmp(md_inport,'on'),
            port=5;
        else
            port=4;
        end
    end
    if ports(port).SrcBlock<0,
        % External UMIN signal is not connected, but Simulink 
        % has added a scalar zero
        no_umin=true;
    end
    if ports(port+1).SrcBlock<0,
        % External UMAX signal is not connected, but Simulink 
        % has added a scalar zero
        no_umax=true;
    end
    if ports(port+2).SrcBlock<0,
        % External YMIN signal is not connected, but Simulink 
        % has added a scalar zero
        no_ymin=true;
    end
    if ports(port+3).SrcBlock<0,
        % External YMAX signal is not connected, but Simulink 
        % has added a scalar zero
        no_ymax=true;
    end
else
    no_umin=true;
    no_umax=true;
    no_ymin=true;
    no_ymax=true;
end

% Determine if output measurement port is connected
port=1;
if is_multiple,
    port=2;
end
no_ym=false;
if ports(port).SrcBlock<0,
    % Measured output signal is not connected, must replace the scalar zero 
    % added by Simulink to yrd with a vector of 0s
    no_ym=true;
end

% Determine if reference port is connected
port=port+1;
no_ref=false;
if ports(2).SrcBlock<0,
    % Reference signal is not connected, must replace the scalar zero added by Simulink to yrd
    % with a vector of 0s
    no_ref=true;
end

ws_mpcobj_update = true; % Flag indicating whether mpcobj should be updated in WS
if strcmp(lims_inport,'on'),
    % Adjust MPC object for handling time-varying limits

    dummy=1e6; % The actual value will be filled in during simulation
    MV=mpcobj.MV;
    for i=1:nu,
        if no_umin,
            MV(i).Min=-Inf; % Default: unconnected signal means variable is unbounded
        else
            MV(i).Min=-dummy; % Dummy values
        end
        if no_umax,
            MV(i).Max=Inf;
        else
            MV(i).Max=dummy;
        end
    end
    OV=mpcobj.OV;
    for i=1:ny,
        if no_ymin,
            OV(i).Min=-Inf; % Default: unconnected signal means variable is unbounded
        else
            OV(i).Min=-dummy; % Dummy values
        end
        if no_ymax,
            OV(i).Max=Inf;
        else
            OV(i).Max=dummy;
        end
    end

    % Now, all inputs and outputs are constrained within finite bounds.
    % Then, Mlim=[ymax(:);-ymin(:);umax(:);-umin(:);dumax;-dumin]
    % will not be reduced inside mpc_buildmat

    % Reset object after modification due to time-varying limits
    pack(mpcobj);
    set(mpcobj,'MV',MV,'OV',OV);
    try
        MPCstruct=mpc_struct(mpcobj,xmpc0,'mpc_init');
    catch ME
        throw(ME);
    end
    InitFlag=1;
    ws_mpcobj_update = false;
end

if ~isempty(xmpc0) && ~isa(xmpc0,'mpcdata.mpcstate'),
    ctrlMsgUtils.error('MPC:designtool:InvalidMPCStateObject',gcb);
end

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer)
    try
        MPCstruct=mpc_struct(mpcobj,xmpc0,'mpc_init');
    catch ME
        throw(ME);
    end
    % Update MPC object in the workspace
    MPCData=getmpcdata(mpcobj);
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
else
    % Update initial state and initial input
    nxp=MPCstruct.nxp;
    xpoff=MPCstruct.xpoff;

    if isempty(xmpc0), 
        xmpc0=mpcstate(mpcobj);
    end
    xp0=xmpc0.Plant;
    xd0=xmpc0.Disturbance;
    xn0=xmpc0.Noise;

    try
        xp0=mpc_chkx0u1(xp0,nxp,xpoff,...
            ctrlMsgUtils.message('MPC:utility:InitialStatePlantModel')); % Check consistency of xp0
        xp0=xp0-xpoff; % Initial condition for the linearized plant

        xd0=mpc_chkx0u1(xd0,MPCstruct.nxumd,zeros(MPCstruct.nxumd,1),...
            ctrlMsgUtils.message('MPC:utility:InitialStateUnmeasuredDisturbanceModel'));
        xn0=mpc_chkx0u1(xn0,MPCstruct.nxnoise,zeros(MPCstruct.nxnoise,1),...
            ctrlMsgUtils.message('MPC:utility:InitialStateNoiseModel'));

        % Form extended state vector
        x0=[xp0;xd0;xn0];

        u1=xmpc0.LastMove;
        uoff=MPCstruct.uoff;
        u1=mpc_chkx0u1(u1,nu,uoff,...
            ctrlMsgUtils.message('MPC:utility:InitialInput'));% Check consistency of u1
        u1=u1-uoff; % Initial condition for linearized input
    catch ME
        throw(ME);
    end

    MPCstruct.lastx=x0;
    MPCstruct.lastu=u1;
end

MPCstruct.no_ref=double(no_ref); % RTW doesn't like non-numerical values !!
MPCstruct.no_md=double(no_md);
MPCstruct.no_ym=double(no_ym);
MPCstruct.no_mv=double(no_mv);
MPCstruct.no_umin=double(no_umin);
MPCstruct.no_umax=double(no_umax);
MPCstruct.no_ymin=double(no_ymin);
MPCstruct.no_ymax=double(no_ymax);
MPCstruct.no_switch=double(no_switch);

% External signals and preview parameters
MPCstruct.ref_from_ws=double(strcmp(ref_from_ws,'on')); %1='on', 0='off'
MPCstruct.ref_preview=double(strcmp(ref_preview,'on'));
MPCstruct.ref_signal_name=ref_signal_name;
MPCstruct.md_from_ws=double(strcmp(md_from_ws,'on'));
MPCstruct.md_preview=double(strcmp(md_preview,'on'));
MPCstruct.md_signal_name=md_signal_name;
MPCstruct.md_inport=double(strcmp(md_inport,'on'));
MPCstruct.mv_inport=double(strcmp(mv_inport,'on'));
MPCstruct.lims_inport=double(strcmp(lims_inport,'on'));
MPCstruct.switch_inport=double(strcmp(switch_inport,'on'));

MPCstruct.enable_value=enable_value; 
MPCstruct.is_multiple=is_multiple; 

% Update MPC object in the workspace
MPCData.MPCstruct=MPCstruct;
setmpcdata(mpcobj,MPCData);
if MPCfromWS && ws_mpcobj_update
    % mpcobjname could be an expression
    try
        assignin('caller',mpcobjname,mpcobj);
    catch ME        
    end
end

set_param(gc,'Userdata',MPCstruct);

%-----------------------------------
function hfig=maskhandle

% Is the Simulink mask for this block already open?
blkh = gcbh;
oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag','MPC_mask');
set(0,'ShowHiddenHandles',oldsh');
hfig = findobj(fig, 'flat', 'UserData',blkh);
