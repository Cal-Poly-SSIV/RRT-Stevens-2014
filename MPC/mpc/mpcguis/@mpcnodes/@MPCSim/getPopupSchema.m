function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:44:35 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Scenario');

item2 = JMenuItem('Copy Scenario');
item3 = JMenuItem('Delete Scenario');
item4 = JMenuItem('Rename Scenario');

Menu.add(item2);
Menu.add(item3);
Menu.add(item4);

Handles.PopupMenuItems = [item2; item3; item4];
set(handle(item2,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item2,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});
set(handle(item3,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item3,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});
set(handle(item4,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item4,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)

if strcmpi(eventData.getActionCommand, 'Copy Scenario')
    this.up.copyScenario(this.Label);
elseif strcmpi(eventData.getActionCommand, 'Delete Scenario')
    this.up.deleteScenario(this.Label);
elseif strcmpi(eventData.getActionCommand, 'Rename Scenario')
    OldName = this.Label;
    NewName = this.up.getNewSimName({OldName});
    if ~isempty(deblank(NewName))
        this.renameScenario(OldName, NewName);
    end
end
