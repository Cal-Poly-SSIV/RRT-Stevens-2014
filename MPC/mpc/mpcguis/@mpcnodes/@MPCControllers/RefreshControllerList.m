function RefreshControllerList(this)
% Check for addition or deletion of an MPC controller node.  

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2007/11/09 20:42:52 $

% Input "this" is the MPCControllers node handle.

if isfield(this.Handles, 'UDDtable')
    UDDtable = this.Handles.UDDtable;
else
    % Possible that UDDtable hasn't been created.
    return
end
if isempty(UDDtable)
    return
end

% Need to make invisible, then reset to visible in order for changes to
% appear
awtinvoke(UDDtable.Table,'setVisible(Z)',false);
Controllers = this.getChildren;
Count = length(Controllers);

List = cell(Count, 5);
ControllerList = cell(Count, 1);
for i=1:Count
    Controller = Controllers(i);
    List(i,:) = {Controller.Label, Controller.ModelName, ... 
        Controller.Ts, Controller.P, Controller.Updated};
    ControllerList{i,1} = Controller.Label;
end
this.Controllers = ControllerList;
% Set the selected controller
row = UDDtable.selectedRow;
if Count > 0
    if row > Count
        row = Count;
    elseif row < 1
        row = 1;
    end
else
    % Indicate no controller and disable object export
    row = 0;
    awtinvoke(this.Handles.ExportMenu.getAction,'setEnabled(Z)',false);
    this.CurrentController = '';
end
if row > 0
    UDDtable.selectedRow = row;
end
UDDtable.setCellData(List);

awtinvoke(UDDtable.Table,'setVisible(Z)',true);
UDDtable.setHeaderHeight(35);
this.RefreshControllerSummary;
