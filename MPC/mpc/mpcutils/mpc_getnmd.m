function [nmd, mdsrcblk] = mpc_getnmd(blockname)
% MPC_GETNMD  returns number of MD signals connected to a MPC block.
%
 
% Author(s): Rong Chen 02-May-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/12/04 22:44:09 $

ports = get_param(blockname, 'PortHandles');
portconnection = get_param(blockname, 'PortConnectivity');
nmd = 0;
mdsrcblk = '';
if strcmp(get_param(blockname,'md_inport'),'on')
    % there is a md_inport
    mdport = handle(ports.Inport(3));
    if portconnection(3).SrcBlock ~=-1
        % connected to a block
        nmd = get(mdport,'compiledportwidth');
        mdsrcblk = getfullname(portconnection(3).SrcBlock);
    end
end
