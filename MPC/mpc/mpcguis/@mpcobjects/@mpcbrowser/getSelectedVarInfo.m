function varStruc = getSelectedVarInfo(h)
% GETSELECTEDVARINFO  Retrieves the selected variable structure 

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:46:21 $

thisSelection = h.javahandle.getSelectedRows;
varStruc = [];
if ~isempty(thisSelection)
    varStruc = h.variables(double(thisSelection(1))+1);
end

