function MPCSims = getMPCSims(this)
% MPCSims Navigates the tree to the MPCSims node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:45:18 $

% First go up to the root node.
Root = this.getMPCStructure;
% Now find the MPCSims node
MPCSims = Root.find('-class','mpcnodes.MPCSims');
