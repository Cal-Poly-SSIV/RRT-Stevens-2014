function MPCStructure = getMPCStructure(this)
% MPCStructure Navigates the tree to the MPCGUI (root) node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:45:20 $

% Get the root node.
MPCStructure = this.getRoot;