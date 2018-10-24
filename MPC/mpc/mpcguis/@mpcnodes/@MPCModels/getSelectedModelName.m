function Name = getSelectedModelName(this)
% Gets name of selected model from the list display on the MPCModels node.

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:44:22 $

UDDList = this.Handles.UDDList;
Name = UDDList.SelectedItemValue;
