function Bool = isEnabled(this)
% Determines whether or not the MPCControllers panel should
% be enabled.  Enabling requires that at least one model
% has been imported.

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:43:04 $

% "this" is the handle of the MPCControllers panel.
% Get parent node, then MPCModels node.
P=this.up;
MPCModels = P.find('-class','mpcnodes.MPCModels');
if isempty(MPCModels.getChildren)
    Bool = 0;
else
    Bool = 1;
end

