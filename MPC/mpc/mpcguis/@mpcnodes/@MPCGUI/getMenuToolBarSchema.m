function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Create menubar and toolbar.  Also, set the callbacks
% for the menu items and toolbar buttons.

% Author(s):  Larry Ricker
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.14 $ $Date: 2008/10/31 06:21:29 $

% Create menubar
%drawnow % explorer.MenuBar constructor can lock out the java figure thread
menubar = manager.getMenuBar(this.getGUIResources);
% Create toolbar
toolbar = manager.getToolBar(this.getGUIResources);
%drawnow
% Menu callbacks

this.Handles.PlantMenu = menubar.getMenuItem('model');
set( handle(this.Handles.PlantMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalModelSelected, this } );
this.Handles.ObjectMenu = menubar.getMenuItem('object');
set( handle(this.Handles.ObjectMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalObjectSelected, this } );
this.Handles.ExportMenu = menubar.getMenuItem('export');
set( handle(this.Handles.ExportMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalExportSelected, this } );
this.Handles.SimulateMenu = menubar.getMenuItem('simulate');
set(handle(this.Handles.SimulateMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalNewSimulation, this } );
this.Handles.SaveMenu = menubar.getMenuItem('save');
set(handle(this.Handles.SaveMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalSaveSelected, this} );
this.Handles.OpenMenu = menubar.getMenuItem('open');
set(handle(this.Handles.OpenMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalLoadSelected, this} );
this.Handles.ExitMenu = menubar.getMenuItem('exit');
set(handle(this.Handles.ExitMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalExitSelected, this } );
this.Handles.ProjectMenu = menubar.getMenuItem('project');
set(handle(this.Handles.ProjectMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalProjectSelected } );
this.Handles.AboutMenu = menubar.getMenuItem('about');
set(handle(this.Handles.AboutMenu,'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalAboutMPC,this,manager});

% Toolbar button callbacks
this.Handles.SimulateButton = toolbar.getToolbarButton('simulate');
set(handle(this.Handles.SimulateButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalNewSimulation, this } );
this.Handles.SaveButton = toolbar.getToolbarButton('save');
set(handle(this.Handles.SaveButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalSaveSelected, this} );
this.Handles.OpenButton = toolbar.getToolbarButton('open');
set(handle(this.Handles.OpenButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalLoadSelected, this} );
this.Handles.ProjectButton = toolbar.getToolbarButton('project');
set(handle(this.Handles.ProjectButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalProjectSelected } );
this.Handles.OutputButton = toolbar.getToolbarButton('output');
set(handle(this.Handles.OutputButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalOutputSelected, this, manager } );

% Initial menu state
Controllers = this.getMPCControllers.getChildren;
if length(Controllers) <= 0
    % No controllers to export yet
    awtinvoke(this.Handles.ExportMenu.getAction,'setEnabled(Z)',false);
end
Scenarios = this.getMPCSims.getChildren;
if length(Scenarios) <= 0
    % No scenarios to simulate yet
    awtinvoke(this.Handles.SimulateMenu.getAction,'setEnabled(Z)',false);
end

% --------------------------------------------------------------------------- %
function LocalModelSelected(eventSrc, eventData, this)
% Open the model import dialog window
I = this.Handles.ImportLTI;
I.javasend('Show','dummy');

% --------------------------------------------------------------------------- %
function LocalObjectSelected(eventSrc, eventData, this)
% Show the mpc object import window
I = this.Handles.ImportMPC;
I.javasend('Show','dummy');

% --------------------------------------------------------------------------- %
function LocalExportSelected(eventSrc, eventData, this)
this.Handles.mpcExporter.show;

% --------------------------------------------------------------------------- %
function LocalNewSimulation(eventSrc, eventData, this)
% Run the current scenario
this.getMPCSims.runSimulation;

% ------------------------------------------------------------------------
function LocalSaveSelected(eventSrc, eventData, this)
% Save the mpc design.  Default the file name to the root node label.
if isempty(this.SaveAs)
    FileName = this.Label;
else
    FileName = this.SaveAs;
end
% Remove any white space from proposed file name -- only if a project
iBlank = find(isspace(FileName));
if ~isempty(iBlank)
    FileName(iBlank) = '';
end
this.SaveAs = FileName;
if isa(this.up, 'explorer.Workspace');
    this.TreeManager.saveas(this);
else
    this.TreeManager.saveas(this.up);
end
    
% ------------------------------------------------------------------------
function LocalLoadSelected(eventSrc, eventData, this)
% Load a project
this.TreeManager.loadfrom(this);

% ------------------------------------------------------------------------
function LocalExitSelected(eventSrc, eventData, this)
% Exit the project
this.closeTool;

% ------------------------------------------------------------------------
function LocalProjectSelected(eventSrc, eventData)
% Create a new project
newMPCproject;

function LocalOutputSelected(hSrc, hData, this, manager)
isVisible = hData.getSource.isSelected;
awtinvoke(manager.Explorer, 'setStatusArea', isVisible ); % Thread safe

function LocalAboutMPC(es,ed,this,manager)

import javax.swing.JOptionPane;

%% Get the version number from ver
verdata = ver('mpc');
%% Create the version message
message = sprintf('%s %s\n%s', verdata.Name, verdata.Version, ...
    ['Copyright 2002-' datestr(verdata.Date,10) ' The MathWorks, Inc.']);
%% Show the dialog
JOptionPane.showMessageDialog(manager.Explorer, message, ...
                              'About Model Predictive Control', ...
                              JOptionPane.PLAIN_MESSAGE);
                          