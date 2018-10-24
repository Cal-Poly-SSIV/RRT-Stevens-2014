function var = getSelectedVar(h)
% GETSELECTEDVAR  Retrieves the selected variable 

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2007/11/09 20:46:20 $

thisSelection = h.javahandle.getSelectedRows;
var = [];
if ~isempty(thisSelection)
    varStruc = h.variables(double(thisSelection(1))+1);
    if isempty(h.filename)
        var=evalin('base',varStruc.name);
    else
        S=load(h.filename);
        var=S.(varStruc.name);
    end        
end

