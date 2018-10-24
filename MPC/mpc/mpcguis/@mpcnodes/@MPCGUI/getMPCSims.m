function MPCSims = getMPCSims(this)
% GETMPCSIMS Navigates the tree to the MPCSims node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2007/11/09 20:43:26 $

% Find the MPCSims node
MPCSims = this.find('-class','mpcnodes.MPCSims');
if isempty(MPCSims)
    % Need to add the node
    MPCSims = mpcnodes.MPCSims('Scenarios');
    this.addNode(MPCSims);
end
