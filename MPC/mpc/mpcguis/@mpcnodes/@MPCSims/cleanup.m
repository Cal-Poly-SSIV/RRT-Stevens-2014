function cleanup(this) 
% CLEANUP  Enter a description here!
%
 
% Author(s): Rong Chen 14-Oct-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:21:39 $

% remove all the child nodes
Nodes = this.getChildren;
for ct = 1:length(Nodes)
    if ishandle(Nodes(ct))
        delete(Nodes(ct));
    end
end
if isfield(this.Handles,'UDDtable')
    delete(this.Handles.UDDtable)
end