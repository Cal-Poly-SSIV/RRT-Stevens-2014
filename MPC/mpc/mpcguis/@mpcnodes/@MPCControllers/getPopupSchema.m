function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2007/11/09 20:43:03 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Scenarios');

item1 = JMenuItem('New Controller');
item2 = JMenuItem('Import Controller');
item3 = JMenuItem('Export Controller');

Menu.add(item1);
Menu.add(item2);
Menu.add(item3);

Handles.PopupMenuItems = [item1; item2; item3];
set(handle(item1,'callbackproperties'), 'ActionPerformedCallback', {@LocalNewAction, this});
set(handle(item1,'callbackproperties'), 'MouseClickedCallback',    {@LocalNewAction, this});
set(handle(item2,'callbackproperties'), 'ActionPerformedCallback', {@LocalImportAction, this});
set(handle(item2,'callbackproperties'), 'MouseClickedCallback',    {@LocalImportAction, this});
set(handle(item3,'callbackproperties'), 'ActionPerformedCallback', {@LocalExportAction, this});
set(handle(item3,'callbackproperties'), 'MouseClickedCallback',    {@LocalExportAction, this});

% --------------------------------------------------------------------------- %

function LocalNewAction(eventSrc, eventData, this)
% Respond to New Controller menu item
this.addController;

% --------------------------------------------------------------------------- %

function LocalImportAction(eventSrc, eventData, this)
% Respond to Import Controller menu item
I = this.up.Handles.ImportMPC;
I.javasend('Show','dummy');

% --------------------------------------------------------------------------- %

function LocalExportAction(eventSrc, eventData, this)
% Respond to Export Controller menu item
this.up.Handles.mpcExporter.show;
