function MPCControllers = getMPCControllers(this)
% MPCCONTROLLERS Navigates the tree to the MPCControllers node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:45:15 $

% First go up to the root node.
Root = this.getMPCStructure;
% Now find the MPCControllers node
MPCControllers = Root.find('-class','mpcnodes.MPCControllers');
