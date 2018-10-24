function this = MPCGUI(label)
%  MPCGUI Constructor for @MPCGUI class

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.10 $ $Date: 2008/05/31 23:21:43 $

% Create class instance
this = mpcnodes.MPCGUI;
if nargin == 0
    % Reconstruction during a project load.  Just return
    return
end
this.icon = fullfile('toolbox','mpc','mpcutils','mpc_project_folder.gif');
this.Resources = 'com.mathworks.toolbox.mpc.resources.mpcgui';
this.AllowsChildren = true;
this.setInitial;
this.Reset = false;
this.SpecsChanged = false;
this.SimulinkProject = 0;
this.Dirty = 0;
this.label = label;
this.InData = cell(0,5);
this.OutData = cell(0,5);
this.MPCObject = {};

this.Handles = struct('PopupMenuItems', [], 'ImportLTI', []);
this.Sizes = zeros(1,7);

this.getMPCModels;
this.getMPCControllers;
this.getMPCSims;
