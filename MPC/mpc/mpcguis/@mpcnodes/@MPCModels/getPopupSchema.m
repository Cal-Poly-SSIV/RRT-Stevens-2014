function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2007/11/09 20:44:20 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Models');

item1 = JMenuItem('Import Model');

Menu.add(item1);

% (jgo) Add linearization node
linnode = [];
mpcnodes = this.up.getChildren;
for k=1:length(mpcnodes)
    if isa(mpcnodes(k),'mpcnodes.MPCLinearizationSettings')
       linnode = mpcnodes(k);
       break
    end
end
linModItem = [];
if ~isempty(linnode)    
    linnodes = linnode.getChildren;
    linearizationItem = JMenu('Import linearized model');
    Menu.add(linearizationItem); 
    for k=1:length(linnodes)-1
        newlinModItem = JMenuItem(linnodes(k).Label);
        linModItem = [linModItem newlinModItem];
        set(handle(newlinModItem,'callbackproperties'), 'ActionPerformedCallback', {@LocalLinearizationAction, this,linnodes(k)});
        set(handle(newlinModItem,'callbackproperties'), 'MouseClickedCallback',    {@LocalLinearizationAction, this, linnodes(k)});
        linearizationItem.add(newlinModItem);
    end
end


Handles.PopupMenuItems = [item1]; %#ok<NBRAK>
set(handle(item1,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item1,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});

% --------------------------------------------------------------------------- %

function LocalAction(eventSrc, eventData, this)

I = this.up.Handles.ImportLTI;
I.javasend('Show','dummy');

% --------------------------------------------------------------------------- %

function LocalLinearizationAction(eventSrc, eventData, this, linnode)

% (jgo) Callback for import of linearizated model

% Import selected linearized model
x.name = linnode.Label; % Create struct for ".addModelToList"
linmodel = linnode.LinearizedModel; % First linearzed model in Analsis node
linmodel.d = zeros(size(linmodel.d)); % zero out D matrix for MPC
this.addModelToList(x,linmodel); % Add a default MPC Controller based on the new model

OpCondData = linnode.getOperatingPoints;

% Update the output signal table with new nominal
outtablevals = this.up.OutUDD.celldata;
outtablevals{5} = OpCondData.Outputs.Value;
setCellData(this.up.OutUDD,outtablevals);

