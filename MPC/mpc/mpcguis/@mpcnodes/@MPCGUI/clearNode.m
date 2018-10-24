function clearNode(this)
% Deletes an MPC node and its children.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:43:13 $

Children = this.getChildren;
% If children exist, remove them recursively.
for i = 1:length(Children)
    Children(i).clearNode;
end
clear Children
