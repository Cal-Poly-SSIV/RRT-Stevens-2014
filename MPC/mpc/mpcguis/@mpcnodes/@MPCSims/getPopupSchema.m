function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2007/11/09 20:45:01 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Scenarios');

item1 = JMenuItem('New Scenario');

Menu.add(item1);

Handles.PopupMenuItems = item1;
set(handle(item1,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item1,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)

this.addScenario;