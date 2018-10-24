function MPCModels = getMPCModels(this)
% MPCCONTROLLERS Navigates the tree to the MPCModels node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:45:17 $

% First go up to the root node.
Root = this.getMPCStructure;
% Now find the MPCModels node
MPCModels = Root.find('-class','mpcnodes.MPCModels');
