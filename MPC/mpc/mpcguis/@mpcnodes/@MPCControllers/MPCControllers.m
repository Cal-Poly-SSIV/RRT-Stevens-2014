function this = MPCControllers(varargin)
%  MPCCONTROLLERS Constructor for @MPCControllers class

%  Author(s): 
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:42:50 $

% Create class instance
this = mpcnodes.MPCControllers;
this.Label = 'Controllers';
this.Editable = false;
this.AllowsChildren = true;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.CurrentController = '';

this.icon = fullfile('toolbox','mpc','mpcutils','mpc_controller_folder.gif');
this.setInitial;
