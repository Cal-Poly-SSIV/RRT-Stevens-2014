function MPCControllers = getMPCControllers(this)
% GETMPCCONTROLLERS Navigates the tree to the MPCControllers node.

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2007/11/09 20:43:23 $

% Find the MPCControllers node
MPCControllers = this.find('-class','mpcnodes.MPCControllers');
if isempty(MPCControllers)
    % Need to add the node
    MPCControllers = mpcnodes.MPCControllers('Controllers');
    this.addNode(MPCControllers);
end
