function runSimulation(this)
% Operates on an MPCSim scenario to generate a simulation.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.14 $ $Date: 2009/02/06 14:23:28 $

% Get the controller.  May cause an MPC object update.
S = this.getRoot;
Controllers = this.getMPCControllers;
Controller = Controllers.find('Label', this.ControllerName);
% Force initialization of the controller dialog panel if necessary
if isempty(Controller.Dialog)
    Controller.getDialogInterface(S.TreeManager);
end
MPCobj = Controller.getController;
if isempty(MPCobj)
    return
end

% Make sure the MPCobj.Ts and the scenario Ts agree.  
this.Ts = MPCobj.Ts;

% Get the scenario.  If nothing has changed, this gets the version
% already saved.

Scenario = this.getSignalDefinitions;

% Don't run simulation if duration is too small relative to sampling
% period.
if Scenario.T < 2
    Message = ctrlMsgUtils.message('MPC:designtool:SimulationFailedShortDuration');
    LocalMessageDisplay(this, S, Message);
    return
end


% Define simulation options
SimOpts = mpcsimopt(MPCobj);

% Get the plant model.

mpcCursor(S.Frame, 'wait');
PlantName = this.PlantName;
[simModel.Plant, InIx, OutIx] =  ...
    mpcStripNeglected(this.getMPCModels.getLTImodel(PlantName), S);
simModel.Nominal.U = MPCobj.Model.Nominal.U;
simModel.Nominal.Y = MPCobj.Model.Nominal.Y;
SimOpts.Model = simModel;

% Indices for model stored in the object
iMV = MPCobj.Model.Plant.InputGroup.Manipulated;
iMO = MPCobj.Model.Plant.OutputGroup.Measured;


% Set simulation options

if this.ConstraintsEnforced
    SimOpts.Constraints = 'on';
else
    SimOpts.Constraints = 'off';
end

if this.ClosedLoop
    SimOpts.OpenLoop = 'off';
else
    SimOpts.OpenLoop = 'on';
    SimOpts.MVSignal = zeros(1,length(MPCobj.MV));
end

if this.rLookAhead
    SimOpts.RefLookAhead = 'on';
else
    SimOpts.RefLookAhead = 'off';
end
if this.vLookAhead
    SimOpts.MDLookAhead = 'on';
else
    SimOpts.MDLookAhead = 'off';
end

% Call the mpccontrol/sim method
SimOpts.StatusBar = 'on';
SimOpts.UnmeasuredDisturbance = Scenario.d;
SimOpts.InputNoise = Scenario.Noise.U;
SimOpts.OutputNoise = Scenario.Noise.Y;
if ~this.ClosedLoop
    MVSignal = simModel.Nominal.U(iMV);
    SimOpts.MVSignal = MVSignal(:)';
end
try
    [y, t, u]=sim(MPCobj, Scenario.T, Scenario.r, Scenario.v, SimOpts);
catch ME
    if ~isempty(findstr(lower(ME.identifier), 'feedthrough'))
        Message = ctrlMsgUtils.message('MPC:designtool:SimulationFailedFeedThrough', this.PlantName, this.Label);        
    else
        Message = ctrlMsgUtils.message('MPC:designtool:SimulationFailedOther', this.Label, ME.identifier, ME.message);        
    end
    LocalMessageDisplay(this, S, Message);
    return
end
y(:,iMO) = y(:,iMO) + Scenario.Noise.Y;
Root = this.getRoot;
if this.ClosedLoop
    r = Scenario.r;
else
    r = [];
end
% if plots exist, make it invisible for safety issue
cacheHin = '';
cacheHout = '';
if ishandle(Root.Hin)
    cacheHin = get(Root.Hin.AxesGrid.Parent,'CloseRequestFcn');
    set(Root.Hin.AxesGrid.Parent,'CloseRequestFcn','');
end
if ishandle(Root.Hout)
    cacheHout = get(Root.Hout.AxesGrid.Parent,'CloseRequestFcn');
    set(Root.Hout.AxesGrid.Parent,'CloseRequestFcn','');
end

% plot with forced invisibility
[Root.Hout, Root.Hin] = plot(MPCobj, t, y, r, u, ...
     Scenario.v, Scenario.d, Root.Hout, Root.Hin, this.Label);
Figi = Root.Hin.AxesGrid.Parent;
Figo = Root.Hout.AxesGrid.Parent;
% set plot properties
set(Figo, 'NumberTitle', 'off', 'Tag', 'mpc',  ...
    'Name', [Root.Label, ':  Outputs'], 'HandleVisibility', 'callback');
set(Figi, 'NumberTitle', 'off', 'Tag', 'mpc', ...
    'Name', [Root.Label, ':  Inputs'], 'HandleVisibility', 'callback');
% Hide irrelevant toolbar buttons. This is not done at the level of the
% plot method since mpc simulation plots created from the workspace may
% need these toolbar functions for other graphics objects.
toolBarIds = {'Plottools.PlottoolsOn','Plottools.PlottoolsOff','Standard.EditPlot',...
    'Annotation.InsertColorbar','Exploration.Rotate'};
for k=1:length(toolBarIds)    
    htoolbar = findall(Figo,'type','uitoolbar');
    fToolbar = findall(htoolbar,'Tag',toolBarIds{k});
    set(fToolbar,'Visible','off')
    htoolbar = findall(Figi,'type','uitoolbar');
    fToolbar = findall(htoolbar,'Tag',toolBarIds{k});
    set(fToolbar,'Visible','off')
end
menuIds =     {'figMenuRotate3D';...
    'figMenuToolsPlotedit';...
    'figMenuInsertLight';...
    'figMenuInsertAxes';...
    'figMenuInsertColorbar';...
    'figMenuPropertyEditor';...
    'figMenuPlotBrowser';...
    'figMenuFigurePalette';...
    'figMenuPloteditToolbar';...
    'figMenuCameraToolbar';...
    'figMenuEditRedo';...
    'figMenuEditUndo';...
    'figMenuOptionsDataBar';...
    'figMenuOptionsDatatip';...
    'figMenuOptionsYPan';...
    'figMenuOptionsXPan';...
    'figMenuOptionsXYPan';...
    'figMenuOptionsYZoom';...
    'figMenuOptionsXZoom';...
    'figMenuOptionsXYZoom'};
menuListi = findall(Figi,'type','uimenu');
menuListo = findall(Figo,'type','uimenu');
set(menuListi(ismember(get(menuListi,'Tag'),menuIds)),'Visible','off')
set(menuListo(ismember(get(menuListo,'Tag'),menuIds)),'Visible','off')
% make plot visible
figure(double(Figi));
figure(double(Figo));

if ~isempty(cacheHin)
    set(Root.Hin.AxesGrid.Parent,'CloseRequestFcn',cacheHin);
end
if ~isempty(cacheHout)
    set(Root.Hout.AxesGrid.Parent,'CloseRequestFcn',cacheHout);
end
mpcCursor(S.Frame, 'default');

% ==============================================

function LocalMessageDisplay(this, S, Message)
uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
this.Results = [];
mpcCursor(S.Frame, 'default');
