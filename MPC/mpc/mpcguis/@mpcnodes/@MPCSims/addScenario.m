function addScenario(this)
% React to user push of New button on MPCSims panel (or popup menu).

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc. 
%  $Revision: 1.1.8.6 $ $Date: 2007/11/09 20:44:52 $

Name = 'Scenario1';
Num = 2;
Scenarios = this.getChildren;
while ~isempty(Scenarios.find('Label',Name))
    Name = sprintf('Scenario%i', Num);
    Num = Num + 1;
end
% A valid name was assigned.  Create the node.
this.addNode(mpcnodes.MPCSim(Name));
NewNode = this.getChildren.find('Label', Name);
% Set the controller and plant to the ones most recently used
CellData = this.Handles.UDDtable.CellData;
NewNode.ControllerName = CellData{end,2};
NewNode.PlantName = CellData{end,3};

NewNode.getDialogInterface(this.up.TreeManager);
this.RefreshSimList
[rows, cols] = size(this.Handles.UDDtable.CellData);
this.Handles.UDDtable.SelectedRow = rows;