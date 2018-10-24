function cleanup(this) 
% CLEANUP
%
 
% Author(s): Rong Chen 14-Oct-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:21:26 $

delete(this.Listeners);

if ~isempty(this.Dialog)
    javaMethodEDT('removeAll',this.Dialog);
end

if ~isempty(this.MenuBar)
    awtinvoke( this.MenuBar, 'dispose()')
    this.MenuBar = [];
end
 
if ~isempty(this.ToolBar)
    awtinvoke(this.ToolBar, 'dispose()')
    this.ToolBar = [];
end

% remove all the child nodes
ModelsNode = this.getMPCModels;
if ishandle(ModelsNode)
    delete(ModelsNode.Listeners);
    delete(ModelsNode);
end

ControllersNode = this.getMPCControllers;
if ishandle(ControllersNode)
    delete(ControllersNode.Listeners);
    delete(ControllersNode);
end

SimsNode = this.getMPCSims;
if ishandle(SimsNode)
    delete(SimsNode.Listeners);
    delete(SimsNode)
end

% close all the plots
this.closePlots;

% delete all the persistent dialogs
if ishandle(this.Handles.ImportLTI)
    this.Handles.ImportLTI.javasend('Hide','');
    delete(this.Handles.ImportLTI);
end
if ishandle(this.Handles.ImportMPC)
    this.Handles.ImportMPC.javasend('Hide','');
    delete(this.Handles.ImportMPC);
end
if ishandle(this.Handles.mpcExporter)
    this.Handles.mpcExporter.hide;
    delete(this.Handles.mpcExporter);
end

if ishandle(this.InUDD)
    delete(this.InUDD)
end
if ishandle(this.OutUDD)
    delete(this.OutUDD)
end
