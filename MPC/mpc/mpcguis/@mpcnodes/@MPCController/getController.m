function MPCobj = getController(this, Flag)
% GETCONTROLLER Uses the data stored in the MPCController node
% to construct an MPC object.
%
% If an MPC object has been stored and none of its data have
% changed, use the stored version.  Else, if MPCController.HasUpdated
% is true, construct a new MPC object.
%
% If a new MPC object is generated, save it, and reset the 
% MPCController.HasUpdated property to false.

%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.14 $  $Date: 2008/05/19 23:19:00 $
%   Author:  Larry Ricker

Controller = this.label;
S = this.IOdata;

if nargin > 1 && strcmp(Flag, 'NoErrorDlg')
    showErrorDlg = false;
else
    showErrorDlg = true;
end

%% Special case -- if Handle and SaveData properties are empty, we are
% trying to extract the controller from a saved controller node in the
% default state.  Calculate the default controller and return.
if isempty(this.Handles) && isempty(this.SaveData)
    MPCModel = this.Model;
    [Plant, InIx, OutIx] = mpcStripNeglected(MPCModel.Model, S);
    if Plant.Ts > 0
        Ts = Plant.Ts;
    else
        Ts = str2double(this.Ts);
    end
    Model.Plant = Plant;
    Model.Nominal.U = LocalStr2Num(S.InData(InIx,5));
    Model.Nominal.Y = LocalStr2Num(S.OutData(OutIx,5));
    try
        MPCobj = mpc(Model, Ts);
    catch ME
        MPCobj = LocalErrorDisplay(this, showErrorDlg, ME);
    end
    return
end

%% If the user has updated MPCStructure data, move changes into this
% controller's tables before going on.
if ~isempty(this.SaveData) && isempty(this.Dialog)
    % Force object calculation when restoring from saved data.
    this.HasUpdated = true;
end

%% Now see if we need to construct a new object.
if this.HasUpdated
    % We need to construct a new object and store it.
    % Get parameters from gui in numerical form
    mpcCursor(this.Frame, 'wait');
    MPCModel = this.Model;
    [Model.Plant, InIx, OutIx] = mpcStripNeglected(MPCModel.Model, S);
    % Get data from tables
    Ts = evalin('base',this.Ts);
    P = evalin('base',this.P);
    if this.Blocking
        M = getBlockedMoves(this);
    else
        M = evalin('base',this.M);
    end
    
    if isempty(this.SaveData) || ~isempty(this.Dialog)
        ULimits = this.Handles.ULimits.CellData;
        YLimits = this.Handles.YLimits.CellData;
        Uwts = this.Handles.Uwts.CellData;
        Ywts = this.Handles.Ywts.CellData;
        Usoft = this.Handles.Usoft.CellData;
        Ysoft = this.Handles.Ysoft.CellData;
        TrackingValue = this.Handles.TrackingUDD.Value;
        HardnessValue = this.Handles.HardnessUDD.Value;
    else
        ULimits = this.SaveData{5};
        YLimits = this.SaveData{6};
        Uwts = this.SaveData{7};
        Ywts = this.SaveData{8};
        Usoft = this.SaveData{9};
        Ysoft = this.SaveData{10};
        TrackingValue = this.SaveData{11};
        HardnessValue = this.SaveData{12};
    end
    
    Tracking = exp(4*(TrackingValue - 0.8));
    Hardness = 10^((28/3)*HardnessValue - 2);
           
    NumOV = size(YLimits, 1);
    NumMV = size(ULimits, 1);
    NumMD = length(S.iMD);
    NumUD = length(S.iUD);

    if ~this.DefaultEstimator
        % Using user-specified estimator
        if isempty(this.SaveData) || ~isempty(this.Dialog)
            ODspecs = this.Handles.eHandles(1).UDD.CellData;
            IDspecs = this.Handles.eHandles(2).UDD.CellData;
            Nspecs = this.Handles.eHandles(3).UDD.CellData;
            GainValue = this.Handles.GainUDD.Value;
        else
            GainValue = this.SaveData{1};
            ODspecs = this.SaveData{2};
            IDspecs = this.SaveData{3};
            Nspecs = this.SaveData{4};
        end

        EstGain = 10^(8*(GainValue - 0.5));
        if NumUD > 0
            if this.EstimData(2).ModelUsed && ...
                    ~isempty(this.EstimData(2).Model)
                % Use a specified input disturbance model
                Model.Disturbance = EstGain*this.EstimData(2).Model;
            else
                % create the input disturbance model
                this.EstimData(2).ModelUsed = false;
                Model.Disturbance = EstGain*LocalLTIModel(IDspecs, Ts);
            end
        end
        if this.EstimData(3).ModelUsed && ...
                ~isempty(this.EstimData(3).Model)
            % Use a specified noise model
            Model.Noise = ss((1/EstGain)*this.EstimData(3).Model);
        else
            this.EstimData(3).ModelUsed = false;
            Model.Noise = (1/EstGain)*LocalLTIModel(Nspecs, Ts);
        end
        Dmn = Model.Noise.d;
        if min(eig(Dmn*Dmn')) < 1e-6
            Dmn = Dmn + 1.01e-3*eye(size(Dmn));
        end
        Model.Noise.d = Dmn;
        iMO = Model.Plant.OutputGroup.MO;
        if isfield(Model.Plant.OutputGroup,'UO')
            iUO = Model.Plant.OutputGroup.UO;
        else
            iUO = [];
        end
        for i = 1:length(iMO)
            OV(iMO(i)).Integrator = str2double(ODspecs{i, 4});
        end
        for i = 1:length(iUO)
            OV(iUO(i)).Integrator = 0;
        end
    end
    
    Model.Nominal.U = LocalStr2Num(S.InData(InIx,5));
    Model.Nominal.Y = LocalStr2Num(S.OutData(OutIx,5));
    for i = 1:NumMV
        MV(i).Units = char(ULimits{i,2});
        MV(i).Min = minConstraint(ULimits(i,3));
        MV(i).Max = maxConstraint(ULimits(i,4));
        MV(i).RateMin = -abs(minConstraint(ULimits(i,5)));
        MV(i).RateMax = abs(maxConstraint(ULimits(i,6)));
        MV(i).MinECR = MVecValue(Usoft(i,4));
        MV(i).MaxECR = MVecValue(Usoft(i,6));
        MV(i).RateMinECR = MVecValue(Usoft(i,8));
        MV(i).RateMaxECR = MVecValue(Usoft(i,10));
        try
            Weights.MV(:,i) = Tracking * weightValue(Uwts(i,4));
        catch ME
            msgstr = ctrlMsgUtils.message('MPC:designtool:TimeVaryingWeightMVError');
            errordlg(msgstr, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal');
            MPCobj = [];
            this.MPCobject = MPCobj;
            mpcCursor(this.Frame, 'default');
            return
        end
        try
            Weights.MVRate(:,i) = (1/Tracking) * max(weightValue(Uwts(i,5)), 1e-10);
        catch ME
            msgstr = ctrlMsgUtils.message('MPC:designtool:TimeVaryingWeightMVRateError');
            errordlg(msgstr, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal');
            MPCobj = [];
            this.MPCobject = MPCobj;
            mpcCursor(this.Frame, 'default');
            return
        end
    end
    for i = 1:NumOV
        OV(i).Units = char(YLimits{i,2});
        OV(i).Min = minConstraint(YLimits(i,3));
        OV(i).Max = maxConstraint(YLimits(i,4));
        OV(i).MinECR = OVecValue(Ysoft(i,4));
        OV(i).MaxECR = OVecValue(Ysoft(i,6));
        try
            Weights.OV(:,i) = Tracking * weightValue(Ywts(i,4));
        catch ME
            msgstr = ctrlMsgUtils.message('MPC:designtool:TimeVaryingWeightOVError');
            errordlg(msgstr, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal');
            MPCobj = [];
            this.MPCobject = MPCobj;
            mpcCursor(this.Frame, 'default');
            return
        end
    end    
    MaxWeight = max([max(Weights.MV), ...
            max(Weights.MVRate), ...
            max(Weights.OV)]);
    Weights.ECR = Hardness*MaxWeight;
    
    % Construct MPC object (if possible ...)
    try
        MPCobj = mpc(Model, Ts, P, M, Weights, MV, OV);
        if isempty(this.Notes)
            MPCobj.Notes = {};
        else
            MPCobj.Notes = {this.Notes};   
        end
        if NumMD+NumUD > 0
            for i = 1:NumMD
                MPCobj.DV(i).Units = char(S.InData{S.iMD(i),4});
            end
            for i = 1:NumUD
                MPCobj.DV(i+NumMD).Units = char(S.InData{S.iUD(i),4});
            end
        end
        if ~this.DefaultEstimator
            % Add output disturbance estimation options
            if this.EstimData(1).ModelUsed && ~isempty(this.EstimData(1).Model)
                % Use specified output disturbance model
                setoutdist(MPCobj, 'model', EstGain*this.EstimData(1).Model);
            else
                % Signal-by-signal output disturbance
                this.EstimData(1).ModelUsed = false;
                Model = LocalLTIModel(ODspecs, Ts);
                setoutdist(MPCobj, 'model', EstGain*Model);
            end
        end
    catch ME
        MPCobj = LocalErrorDisplay(this, showErrorDlg, ME);
    end
    if isempty(MPCobj)
        this.HasUpdated = 1;
    else
        this.HasUpdated = 0;
    end
    this.MPCobject = MPCobj;
    mpcCursor(this.Frame, 'default');
else
    % The stored object is still current.  Use it
    MPCobj = this.MPCobject;
end

% -----------------------------------------------------
function MPCobj = LocalErrorDisplay(this, showErrorDlg, ME)
Err = ME.message;
Id = ME.identifier;
if ~isempty(findstr(lower(Id), 'feedthrough'))
    Message = ctrlMsgUtils.message('MPC:designtool:DirectFeedThrough',this.Label);
else
    Message = ctrlMsgUtils.message('MPC:designtool:CreateMPCControllerFailed', this.Label, this.Label, Err);
end
if showErrorDlg
    errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal');
end
MPCobj = [];

% -----------------------------------------------------
function Value = minConstraint(String)
% If constraints are blank or empty, assume unconstrained.
Value = LocalStr2NumVector(String);
if isnan(Value)
    Value = -Inf;
end
% -----------------------------------------------------
function Value = maxConstraint(String)
% If constraints are blank or empty, assume unconstrained.
Value = LocalStr2NumVector(String);
if isnan(Value)
    Value = Inf;
end
% -----------------------------------------------------
function Value = weightValue(String)
% If weights are blank or empty, assume zero.
Value = LocalStr2NumVector(String);
if isnan(Value)
    Value = 0;
end
% -----------------------------------------------------
function Value = MVecValue(String)
% For MVs (or rates), if blank or empty, assume zero.
Value = LocalStr2NumVector(String);
if isnan(Value)
    Value = 0;
end
% -----------------------------------------------------
function Value = OVecValue(String)
% For OVs, if blank or empty, assume unity
Value = LocalStr2NumVector(String);
if isnan(Value)
    Value = 1;
end

% -----------------------------------------------------
function Value = LocalStr2Num(Str)
% Local string to number conversion.  Uses evalin to convert.
% Assumes that Str is a column cell array.
if isempty(Str) || ~iscell(Str)
    Value = NaN;
else
    [rows, cols] = size(Str);
    Value = NaN*ones(rows,1);
    if cols == 1
        for i = 1:rows
            try
                Value(i) = evalin('base', char(Str(i)));
            catch ME
                Value(i) = NaN;
            end
        end
    end
end

% -----------------------------------------------------
function Value = LocalStr2NumVector(Str)
% Local string to number conversion.  Uses evalin to convert.
% Assumes that Str is a cell .
if isempty(Str) || ~iscell(Str) || ~isscalar(Str)
    Value = NaN;
else
    try
        Value = evalin('base', Str{:});
        if isreal(Value) && isvector(Value)
            Value = Value(:);
        else
            Value = NaN;
        end
    catch ME
        Value = NaN;
    end
end

% -----------------------------------------------------
function Model = LocalLTIModel(Specs, Ts)
% Create a noise/disturbance model
[NumVar, dummy] = size(Specs);
Num = cell(NumVar, NumVar);
Den = cell(NumVar, NumVar);
Num(:,:) = {0};
Den(:,:) = {1};
for i = 1:NumVar
    Type = char(Specs{i, 3});
    Num(i, i) = {str2double(Specs{i, 4})};
    switch lower(Type)
        case 'white';
            % Gain is all we need ...
        case 'steps'
            Den(i, i) = {[1 0]};
        case 'ramps'
            Den(i, i) = {[1 0 0]};
    end
end
Model = c2d(ss(tf(Num, Den, 0)),Ts);
