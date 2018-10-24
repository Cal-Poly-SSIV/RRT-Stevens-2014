function copyScenario(this, Sim)
%  COPYSCENARIO Copy the scenario whose Label is "Sim"

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.9 $ $Date: 2008/12/29 02:12:14 $

% "this" is the MPCSims node.
Old = this.getChildren.find('Label',Sim);
% Generate a name
Name = sprintf('%s_copy', Sim);
Num = 1;
Scenarios = this.getChildren;
while ~isempty(Scenarios.find('Label',Name))
    Name = sprintf('%s_copy%i', Sim, Num);
    Num = Num + 1;
end

% Valid name was assigned, so copy the node.
New = mpcnodes.MPCSim(Name);
this.addNode(New);
New.PlantName = Old.PlantName;
New.ControllerName = Old.ControllerName;
New.getDialogInterface(this.up.TreeManager);
New.Tend = Old.Tend;
New.updateTables = Old.updateTables;
New.HasUpdated = Old.HasUpdated;
New.Scenario = Old.Scenario;
New.Results = Old.Results;
New.ClosedLoop = Old.ClosedLoop;
New.ConstraintsEnforced = Old.ConstraintsEnforced;
New.Notes = Old.Notes;
New.rLookAhead = Old.rLookAhead;
New.vLookAhead = Old.vLookAhead;
pause(0.1);
LocalCopyTable(New.Handles.Setpoints, Old.Handles.Setpoints);
LocalCopyTable(New.Handles.MeasDist, Old.Handles.MeasDist);
LocalCopyTable(New.Handles.UnMeasDist, Old.Handles.UnMeasDist);
this.RefreshSimList;

% ========================================

function LocalCopyTable(New,Old)

% Copy UDD table characteristics

if isempty(Old)
    New = []; %#ok<NASGU>
else
    New.isEditable = Old.isEditable;
    New.isString = Old.isString;
    New.Defaults = Old.Defaults;
    New.CellData = Old.CellData;
end
