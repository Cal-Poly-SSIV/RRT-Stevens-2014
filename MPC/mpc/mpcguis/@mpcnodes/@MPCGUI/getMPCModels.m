function MPCModels = getMPCModels(this)
% GETMPCMODELS Navigates the tree to the MPCModels node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2007/11/09 20:43:25 $

% Find the MPCModels node
MPCModels = this.find('-class','mpcnodes.MPCModels');
if isempty(MPCModels)
    % Need to add the node
    MPCModels = mpcnodes.MPCModels('Plant models');
    this.addNode(MPCModels);
end
