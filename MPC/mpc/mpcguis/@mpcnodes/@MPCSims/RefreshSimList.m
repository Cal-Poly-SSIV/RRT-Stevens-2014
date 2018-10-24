function RefreshSimList(this)
% REFRESHSIMLIST Compensate for change in number of scenario nodes or other
% factors affecting the scenario list display.

%  Author:  Larry Ricker
%  Copyright 1986-2008 The MathWorks, Inc. 
%  $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:21:38 $

% "this" is the MPCSims node handle.
if isfield(this.Handles, 'UDDtable')
    UDDtable = this.Handles.UDDtable;
else
    return
end
if isempty(UDDtable)
    return
end

% Need to make invisible, then reset to visible in order for changes to
% appear
awtinvoke(UDDtable.Table,'setVisible(Z)',false);
Sims = this.getChildren;
Count = length(Sims);

List = cell(Count,6);
for i=1:Count
    Sim = Sims(i);
    MPCName = Sim.ControllerName;
    PlantName = Sim.PlantName;
    List(i,:) = {Sim.Label, MPCName, PlantName, java.lang.Boolean(Sim.ClosedLoop), ...
            java.lang.Boolean(Sim.ConstraintsEnforced), Sim.Tend};
end

% Set the selected scenario
row = UDDtable.selectedRow;
if Count > 0
    if row > Count
        row = Count;
    elseif row < 1
        row = 1;
    end
else
    % Set no-scenario state
    row = 0;
    awtinvoke(this.up.Handles.SimulateMenu.getAction,'setEnabled(Z)',false);
    this.CurrentScenario = '';
end
if row > 0
    UDDtable.selectedRow = row;
end
UDDtable.setCellData(List);

awtinvoke(UDDtable.Table,'setVisible(Z)',true);
this.RefreshSimSummary;