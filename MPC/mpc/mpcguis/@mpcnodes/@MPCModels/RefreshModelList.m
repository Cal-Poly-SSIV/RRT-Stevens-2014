function RefreshModelList(this)
%REFRESHMODELLIST Check for addition or deletion of an MPCModel.  
% Refresh the MPCModels list.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc. 
%  $Revision: 1.1.8.5 $ $Date: 2007/11/09 20:44:08 $

% Input "this" is the MPCModels node handle.
UDDtable = this.Handles.UDDtable;
if isempty(UDDtable)
    return
end

Models = this.Models;
NumModels = length(Models);

List = cell(NumModels,4);
for i=1:NumModels
    Model = Models(i).Model;
    List(i,:) = {Models(i).Name, class(Model), num2str(Model.Ts), Models(i).Imported};
end
this.Labels = List(:,1);

% Set the selected model
row = UDDtable.selectedRow;
if NumModels > 0
    if row > NumModels
        row = NumModels;
    elseif row < 1
        row = 1;
    end
else
    row = 0;
end
if row > 0
    UDDtable.selectedRow = row;
end
UDDtable.setCellData(List);

this.RefreshModelSummary;
UDDtable.setHeaderHeight(35);
