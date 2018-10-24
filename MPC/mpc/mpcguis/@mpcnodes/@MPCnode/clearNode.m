function clearNode(this)
% CLEARNODE Deletes an MPC node and its children.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2007/11/09 20:45:09 $

% Clear listeners so we don't get unexpected callbacks.
if ~isa(this,'mpcnodes.MPCGUI')
    delete(this.Listeners);
end

Children = this.getChildren;
% If children exist, remove them recursively.
for i = 1:length(Children)
    Children(i).clearNode;
end
clear Children

% No children remaining.  If this isn't the root node, remove it.
if ~isa(this,'mpcnodes.MPCGUI')
    this.up.removeNode(this);
end
