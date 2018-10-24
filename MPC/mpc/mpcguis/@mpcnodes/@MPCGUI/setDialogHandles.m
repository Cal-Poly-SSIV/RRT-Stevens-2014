function setDialogHandles(this)
% SETDIALOGHANDLES Set handles in common dialogs to keep track of the active MPC task

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:43:44 $

Importer = this.Handles.ImportLTI;
Importer.SelectedRoot = this;
Importer = this.Handles.ImportMPC;
Importer.SelectedRoot = this;
Exporter = this.Handles.mpcExporter;
Exporter.SelectedRoot = this;
