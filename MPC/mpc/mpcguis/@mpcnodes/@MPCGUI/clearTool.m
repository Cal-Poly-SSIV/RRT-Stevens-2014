function clearTool(this)
% CLEARTOOL Clears an MPC project.  Deletes all loaded models, controllers,
% and scenarios.  The MPC project (root) node reverts to its empty state.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.9 $ $Date: 2007/11/09 20:43:14 $

% Delete any associated response plots
this.closePlots;
% Collapse the tree and clear all the leaf nodes
this.TreeManager.Explorer.setSelected(this.getTreeNodeInterface);
this.TreeManager.Explorer.collapseNode(this.TreeNode);
this.getMPCSims.clearNode;
this.getMPCControllers.clearNode;
MPCModels = this.getMPCModels;
% (JGO) The listener to the "Models" property will rebuild empty
% Controller and Simulation nodes. These nodes should not be added
% after this line or the user will be asked if they want to 
% replace these nodes (which makes no sense when the user has just
% cleared the project)
MPCModels.Models = [];
% Remove linearization subnodes
linnodes = MPCModels.find('-class', 'mpcnodes.LinearAnalysisResultNode');
for k=1:length(linnodes)
    MPCModels.removeNode(linnodes(k));
end
MPCModels.Labels = {};
MPCModels.Dialog = [];
% Set variables to force new dialogs to be created
this.ModelImported = 0;
this.Sizes = zeros(1,7);
this.InData = cell(0,5);
this.OutData = cell(0,5);
this.InUDD.CellData = cell(0,5);
this.OutUDD.CellData = cell(0,5);
this.SpecsChanged = false;
%this.addNode(mpcnodes.MPCControllers('Controllers'));
%this.addNode(mpcnodes.MPCSims('Scenarios'));
set(this, 'iMV', [], 'iMD', [], 'iUD', [], 'iMO', [], 'iUO', []);
awtinvoke(this.Handles.SimulateMenu.getAction,'setEnabled(Z)',false);
