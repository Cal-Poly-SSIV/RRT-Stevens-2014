function this = MPCSim(Name)
%  Constructor for the MPCSim node

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.8 $ $Date: 2007/11/09 20:44:29 $

% Create class instance
this = mpcnodes.MPCSim;
if nargin == 0
    % Recreating during a load.  Just return
    return
end
this.icon = fullfile('toolbox','mpc','mpcutils','mpc_scenario_icon.gif');

this.Handles = struct('PopupMenuItems', []);

this.rLookAhead = false;
this.vLookAhead = false;
this.ClosedLoop = true;
this.ConstraintsEnforced = true;
this.Tend = '10';
this.setInitial;

this.SaveFields = {'Handles.Setpoints', ...
    'Handles.MeasDist', ...
    'Handles.UnMeasDist'};

this.label = Name;
