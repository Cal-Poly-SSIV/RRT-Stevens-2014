function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.12 $ $Date: 2007/11/09 20:43:31 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Models');

item1 = JMenuItem('Import Plant Model');
item1a = JMenuItem('Import Controller');
item2 = JMenuItem('Clear MPC Task');
item3 = JMenuItem('Delete MPC Task');

Menu.add(item1);
Menu.add(item1a);
Menu.add(item2);
Menu.add(item3);

Handles.PopupMenuItems = [item1; item2];
set(handle(item1,'callbackproperties'), 'ActionPerformedCallback', {@LocalImportAction, this});
set(handle(item1,'callbackproperties'), 'MouseClickedCallback',    {@LocalImportAction, this});
set(handle(item1a,'callbackproperties'), 'ActionPerformedCallback', {@LocalImportMPCAction, this});
set(handle(item1a,'callbackproperties'), 'MouseClickedCallback',    {@LocalImportMPCAction, this});
set(handle(item2,'callbackproperties'), 'ActionPerformedCallback', {@LocalClearAction, this});
set(handle(item2,'callbackproperties'), 'MouseClickedCallback',    {@LocalClearAction, this});
set(handle(item3,'callbackproperties'), 'ActionPerformedCallback', {@LocalDeleteAction, this});
set(handle(item3,'callbackproperties'), 'MouseClickedCallback',    {@LocalDeleteAction, this});

% --------------------------------------------------------------------------- %
function LocalImportAction(eventSrc, eventData, this)

I = this.Handles.ImportLTI;
I.javasend('Show' ,'dummy');

% --------------------------------------------------------------------------- %
function LocalImportMPCAction(eventSrc, eventData, this)

I = this.Handles.ImportMPC;
I.javasend('Show' ,'dummy');

% --------------------------------------------------------------------------- %
function LocalClearAction(eventSrc, eventData, this)
Message1 = ctrlMsgUtils.message('MPC:designtool:ClearAction1');
Message2 = ctrlMsgUtils.message('MPC:designtool:ClearAction2', this.Label);
Message = sprintf('%s\n\n%s',Message1,Message2);
ButtonName = questdlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'Yes', 'No', 'No');
switch ButtonName
case 'No'
    % Return without doing anything
    return
case 'Yes'
    % Clear the design
    this.clearTool;
end

% --------------------------------------------------------------------------- %

function LocalDeleteAction(eventSrc, eventData, this)
Message = ctrlMsgUtils.message('MPC:designtool:DeleteProjectAction', this.Label);
Button = questdlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'Yes', 'No', 'No');
Parent = this.up;
Manager = this.TreeManager;
if strcmpi(Button, 'Yes')
    Parent.removeNode(this);
end
% Select an existing project, if any.
% Also make sure the window closing event points to a valid project.
Projects = Parent.getChildren;
if ~isempty(Projects)
    P = Projects(1);
else
    P = Parent;
end
Manager.Explorer.setSelected(P.getTreeNodeInterface);
if isa(P, 'mpcnodes.MPCGUI') && ~P.ModelImported
    P.TreeManager.Explorer.collapseNode(P.TreeNode);
end

% geck 291904: replace with new syntax to set callback to extended MJFrame
%set(Frame,'WindowClosingCallback',{@ClosingMPCGUI, P});
% prophandle = handle(Frame, 'callbackproperties');
% set(prophandle,'WindowClosingCallback',{@ClosingMPCGUI, P});

