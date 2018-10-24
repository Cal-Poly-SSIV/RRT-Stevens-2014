function [nmo,nmv,nr,nmd] = mpcportsizes(blockname)
%MPCPORTSIZES

%   Author(s): A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.6 $  $Date: 2008/05/31 23:22:05 $

%% If necessary comile the model
if strcmp(get_param(bdroot(blockname), 'SimulationStatus'),'stopped')
    feval(bdroot(blockname),[],[],[],'compile');
end

%% Get the number of MV, MO and MD
ports = get_param(blockname, 'PortHandles');
nmv = get(ports.Outport,'compiledportwidth');
nr = get(ports.Inport(2),'compiledportwidth');
blkp = get_param(blockname,'Parent');
try
    get_param(blkp,'Nmpc');
    nmd = mpc_getnmd_multiple(blkp);
catch ME
    nmd = mpc_getnmd(blockname);
end
nmo = get(ports.Inport(1),'compiledportwidth');

% %% Get the number of UMO and UMD
% numd = 0;
% numo = 0;
% for k=1:length(ioobj)
%     if strcmp(ioobj(k).Type,'in') && strcmp(ioobj(k).Active,'on') && ~strcmp(ioobj(k).Block,blockname) 
%        port = get_param(ioobj(k).Block, 'PortHandles');
%        numd = numd+get(port.Outport(ioobj(k).PortNumber),'compiledportwidth');
%     elseif strcmp(ioobj(k).Type,'out') && strcmp(ioobj(k).Active,'on') && ~strcmp(ioobj(k).Block,blockname) 
%        port = get_param(ioobj(k).Block, 'PortHandles');
%        numo = numo+get(port.Outport(ioobj(k).PortNumber),'compiledportwidth');
%     end
% end

%% Stop the model
if ~strcmp(get_param(bdroot(blockname), 'SimulationStatus'),'stopped')
    feval(bdroot(blockname),[],[],[],'term');
end
