function this = MPCSims(varargin)
%  MPCSIMS Constructor for @MPCSims class

%  Author(s): Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:44:46 $

% Create class instance
this = mpcnodes.MPCSims;
if nargin == 0
    return      % Recreating during a load
end
this.AllowsChildren = true;
this.Editable = false;
this.label = varargin{1};
this.icon = fullfile('toolbox','mpc','mpcutils','mpc_scenario_folder.gif');
this.Handles = struct('PopupMenuItems', []);
this.setInitial;
