function node = getOpCondNode(this)
%Get the operating condition generation node

%  Author(s): John Glass
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/12/04 22:44:01 $

% Overloaded to search for the operating condition node when the
% MPClieanrizationSettings node is part of an MPC task

%% Get the project node
project = this.up.up;

%% Get the children
Children = project.getChildren;

%% Loop over children the get the operating conditions
for ct = 1:length(Children)
    node = Children(ct);
    if isa(node,'OperatingConditions.OperatingConditionTask')
        break
    end
end