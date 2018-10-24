function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.12 $ $Date: 2007/11/09 20:42:36 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Controller');

item2 = JMenuItem('Copy Controller');
item3 = JMenuItem('Delete Controller');
item4 = JMenuItem('Rename Controller');
item5 = JMenuItem('Export Controller');

Menu.add(item2);
Menu.add(item3);
Menu.add(item4);
Menu.add(item5);

Handles.PopupMenuItems = [item2; item3; item4; item5];
set(handle(item2,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item2,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});
set(handle(item3,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item3,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});
set(handle(item4,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item4,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});
set(handle(item5,'callbackproperties'), 'ActionPerformedCallback', {@LocalAction, this});
set(handle(item5,'callbackproperties'), 'MouseClickedCallback',    {@LocalAction, this});

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)

if strcmpi(eventData.getActionCommand, 'Copy controller')
    this.up.copyController(this.Label);
elseif strcmpi(eventData.getActionCommand, 'Delete controller')
    this.up.deleteController(this.Label);
elseif strcmpi(eventData.getActionCommand, 'Rename controller')
    OldName = this.Label;
    NewName = this.up.getNewControllerName({OldName});
    if ~isempty(deblank(NewName))
        OK = this.renameController(OldName, NewName);
    end
elseif strcmpi(eventData.getActionCommand, 'Export controller')
    this.getRoot.Handles.mpcExporter.show;
end
