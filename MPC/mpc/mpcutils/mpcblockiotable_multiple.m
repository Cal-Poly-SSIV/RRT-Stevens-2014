function mpcblockiotable_multiple(mpcblockname, model, linsetting)
%MPCBLOCKIOTABLE automatically detect linearization i/o points for MV, MO
%and MD and store them into MPCLinearizationSettings object in that order.
%The number of MD signals is also saved into MPCLinearizationSettings
%object.  Existing i/o points in the model are not affected at all.
% 1. MV: linearization input points are open loop and active
% 2. MO: linearization output points are open loop and active
% 3. MD: linearization input points are open loop and active if present


%   Author(s): A. Bemporad, R. Chen
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2009/11/09 16:28:23 $

%% Initialization
md_index = [];
portconnection = get_param(mpcblockname, 'PortConnectivity');
ports = get_param(mpcblockname, 'PortHandles');

%% Model must be compiled to get port width
if strcmp(get_param(model, 'SimulationStatus'),'stopped')
    feval(model,[],[],[],'compile');
end

%% Get the MO port width and extract the source for the MO port
mosrcblk = getfullname(portconnection(2).SrcBlock);

%% Get the MD port width and extract the source for the MD port
[nmd, mdsrcblk] = mpc_getnmd_multiple(mpcblockname);

%% create LIP at MV
% add LIP (it can always be done)
mvpt = linio(mpcblockname, 1,'in','on');
mvpt.Description = 'MV';
io = mvpt;
% get port width for MD index computation
porthandles = get_param(mvpt.Block,'PortHandles');
mvportwidth = get(porthandles.Outport(mvpt.PortNumber),'CompiledPortWidth');

%% create LOP at MO
mosrcportnum = [];
% Find the right port number on the mosrcblk
mosrcblk_portconn = get_param(mosrcblk, 'PortConnectivity');
for k=1:length(mosrcblk_portconn)
    ind = find(mosrcblk_portconn(k).DstBlock==get_param(mpcblockname,'handle'));
    if ~isempty(ind) && any(mosrcblk_portconn(k).DstPort(ind)==1)
        % This port is connected to MO
        mosrcportnum = str2double(mosrcblk_portconn(k).Type);
        break;
    end
end
% Create the LOP
if ~isempty(mosrcportnum)
    mopt = linio(mosrcblk,mosrcportnum,'out','on');
    mopt.Description = 'MO';
    io = [io; mopt];
else
    feval(model,[],[],[],'term');
    ctrlMsgUtils.error('MPC:designtool:InfoLinearizationTooManyLOPAtMO');
end

%% create LIP at MD
if nmd>0
    mdsrcportnum = [];
    % Find the right port number on the mosrcblk
    mdsrcblk_portconn = get_param(mdsrcblk, 'PortConnectivity');
    for k=1:length(mdsrcblk_portconn)
        ind = find(mdsrcblk_portconn(k).DstBlock==get_param(mpcblockname,'handle'));
        if ~isempty(ind) && any(mdsrcblk_portconn(k).DstPort(ind)==3)
            % This port is connected to MD
            mdsrcportnum = str2double(mdsrcblk_portconn(k).Type);
            break;
        end
    end
    % Create the LIP
    if ~isempty(mdsrcportnum)
        mdpt = linio(mdsrcblk,mdsrcportnum,'in','on');
        mdpt.Description = 'MD';
        io = [io; mdpt];
        % get port width
        porthandles = get_param(mdpt.Block,'PortHandles');
        mdportwidth = get(porthandles.Outport(mdpt.PortNumber),'CompiledPortWidth');
        % compute md_index
        md_index = (mvportwidth+1):(mvportwidth+mdportwidth);
    else
        feval(model,[],[],[],'term');
        ctrlMsgUtils.error('MPC:designtool:InfoLinearizationTooManyLIPAtMD');
    end
end

%% save IO configuration to MPCLinearizationSettings object
linsetting.IOData = io;
linsetting.MDIndex = md_index;

%% Terminate simulation
if ~strcmp(get_param(model, 'SimulationStatus'),'stopped')
    feval(model,[],[],[],'term');
end
