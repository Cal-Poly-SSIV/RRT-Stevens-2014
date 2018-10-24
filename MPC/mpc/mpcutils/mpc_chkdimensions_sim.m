function mpc_chkdimensions_sim
%MPC_CHK_DIMENSIONS Check correct dimensions of signals to MPC Simulink block

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.11 $  $Date: 2008/05/19 23:19:20 $

% (jgo) Run open loop when no mpcobj is present
if isempty(get_param(gcb,'mpcobj'))
    return
end

% Retrieves object info from MPCstruct stored in block's Userdata
mpcdata = get_param(gcbh,'Userdata');
nym = mpcdata.nym;
nv = mpcdata.nv;
ny = mpcdata.ny;
nu = mpcdata.nu;

% get current connection status
ports=get_param(gcbh,'PortConnectivity');
widths=get_param(gcbh,'CompiledPortWidths');

% prepare error message
err='';

% if output signal is connected ...
if ~(ports(1).SrcBlock<0) && widths.Inport(1)~=nym
    err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionMO',nym,widths.Inport(1)));
end

% if reference signal is connected ...
if ~(ports(2).SrcBlock<0) && widths.Inport(2)~=ny
    err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionRef',ny,widths.Inport(2)));    
end

is_multiple=mpcdata.is_multiple;

if ~is_multiple,
    MDenabled = strcmp(get_param(gcb,'md_inport'),'on');
    MVenabled = strcmp(get_param(gcb,'mv_inport'),'on');
    LIMSenabled = strcmp(get_param(gcb,'lims_inport'),'on');
    % if measured disturbance signal is connected ...
    if length(widths.Inport)>=3 && MDenabled && ~(ports(3).SrcBlock<0) && widths.Inport(3)~=nv-1
        err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionMD',nv-1,widths.Inport(3)));    
    end

    % if externally supplied MV signal is connected ...
    portnum=3;
    if length(widths.Inport)>=4 && MDenabled,
        portnum=4;
    end
    if length(widths.Inport)>=portnum && MVenabled && ~(ports(portnum).SrcBlock<0) && widths.Inport(portnum)~=nu
        err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionExtMV',nu,widths.Inport(portnum)));    
    end

    % if boundary signals are connected ...
    portnum=3;
    if length(widths.Inport)>=4 && (MDenabled || MVenabled), % either MD or Ext.MV are present
        portnum=4;
    end
    if length(widths.Inport)>=5 && MDenabled && MVenabled, % both MD and Ext.MV are present
        portnum=5;
    end
    if length(widths.Inport)>=portnum && LIMSenabled,
        % if UMIN signal is connected ...
        if ~(ports(portnum).SrcBlock<0) && widths.Inport(portnum)~=nu
            err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionInputLowerBound',nu,widths.Inport(portnum)));    
        end
        % if UMAX signal is connected ...
        if ~(ports(portnum+1).SrcBlock<0) && widths.Inport(portnum+1)~=nu
            err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionInputUpperBound',nu,widths.Inport(portnum+1)));    
        end
        % if YMIN signal is connected ...
        if ~(ports(portnum+2).SrcBlock<0) && widths.Inport(portnum+2)~=ny
            err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionOutputLowerBound',ny,widths.Inport(portnum+2)));
        end
        % if YMAX signal is connected ...
        if ~(ports(portnum+3).SrcBlock<0) && widths.Inport(portnum+3)~=ny
            err = sprintf('%s%s\n',err,ctrlMsgUtils.message('MPC:utility:InvalidBlockSignalDimensionOutputLowerBound',ny,widths.Inport(portnum+3)));           
        end
    end

    if ~isempty(err)
         ctrlMsgUtils.error('InvalidBlockSignalDimensionGeneral',err);
    end
    
end
