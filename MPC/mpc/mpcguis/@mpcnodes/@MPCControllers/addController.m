function addController(this,Name,MPCobj)
% ADDCONTROLLER Add a new controller node.  "this" is the MPCControllers
% node. If Name and MPCobj are specified, new controller is to be created
% with specified name and properties of the specified mpc object.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.16 $ $Date: 2008/12/04 22:43:57 $

S = this.up;  % Points to the MPCGUI node

if nargin == 1
    Name = 'MPC1';
    Num = 2;
    Controllers = this.getChildren;
    while ~isempty(Controllers.find('Label',Name))
        Name = sprintf('MPC%i', Num);
        Num = Num + 1;
    end
else
    if nargin == 3 && S.ModelImported
        % Make sure the MPCobj size is compatible
        NumIn = length(MPCobj.Model.Plant.InputName);
        NumOut = length(MPCobj.Model.Plant.OutputName);
        if NumIn ~= S.Sizes(6) || NumOut ~= S.Sizes(7)
            Msg1 = ctrlMsgUtils.message('MPC:designtool:ControllerSizeConflict1', S.Sizes(6), S.Sizes(7));
            Msg2 = ctrlMsgUtils.message('MPC:designtool:ControllerSizeConflict2', Name, NumIn, NumOut);            
            Msg3 = ctrlMsgUtils.message('MPC:designtool:ControllerSizeConflict3', Name);            
            Msg = sprintf('%s\n\n%s\n\n%s',Msg1,Msg2,Msg3);
            uiwait(errordlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
            mpcupdatecetmstatus(S, '');
            return
        end
    end
    % Make sure the name is unique
    Children = this.getChildren;
    if ~isempty(Children)
        isValid = false;
        while ~isValid
            ExistingController = Children.find('Label',Name);
            if ~isempty(ExistingController)
                Message = sprintf('%s\n',ctrlMsgUtils.message('MPC:designtool:DuplicatedControllerNode', Name));
                OldName = Name;
                Name = char(inputdlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 1, {Name}));
                pause(0.1); % a fraction of a second pause is added to avoid thread deadlock
                if isempty(Name)
                    % User cancelled, so return
                    mpcupdatecetmstatus(S, '');
                    mpcupdatecetmtext(S, ctrlMsgUtils.message('MPC:designtool:ImportControllerCancel', OldName));
                    return
                end
            else
                isValid = true;
            end
        end
    end
end

% If we get here, a valid name was assigned.  Create the node.
mpcupdatecetmstatus(S, ctrlMsgUtils.message('MPC:designtool:AddingNodeToTree', Name));
MPCModels = S.getMPCModels;
if nargin < 3
    % Create a new controller node
    New = mpcnodes.MPCController(Name);
    this.addNode(New);
    New.setIOdata(S);
    % No MPCobj has been supplied ...
    % Default to first model in list
    New.ModelName = MPCModels.Labels{1};
    New.Model = MPCModels.Models(1);
    mpcupdatecetmstatus(S, ctrlMsgUtils.message('MPC:designtool:InitializingSettings', Name));    
    New.getDialogInterface(S.TreeManager);
else
    % MPCobj has been supplied.  Use its properties to initialize
    % the node.
    Struc.name = [Name,'_Plant'];
    mpcupdatecetmtext(S, ctrlMsgUtils.message('MPC:designtool:AddingPlantModel', Struc.name));
    if length(this.getChildren) <= 0
        FirstController = true;
    else
        FirstController = false;
    end
    Done = this.getMPCModels.addModelToList(Struc, MPCobj.Model.Plant);
    if ~Done
        mpcupdatecetmtext(S, ctrlMsgUtils.message('MPC:designtool:ImportControllerCancel', Name));
        return
    end
    Controllers = this.getChildren;
    if FirstController && length(Controllers) == 1 
        % In this case, controller node was created when model was
        % added to list.
        New = Controllers(1);
        New.Label = Name;
    else
        % Add the new node
        New = mpcnodes.MPCController(Name);
        this.addNode(New);
    end
    New.EstimRefreshOK = false;
    New.setIOdata(S);
    New.MPCobject = MPCobj;
    New.ModelName = Struc.name;
    New.Model = mpcnodes.MPCModel(New.ModelName, MPCobj.Model.Plant);
    mpcupdatecetmstatus(S, ctrlMsgUtils.message('MPC:designtool:InitializingSettings', Name));    
    Panel = New.getDialogInterface(this.up.TreeManager);
    New.Dialog = Panel;
    Nominal = MPCobj.Model.Nominal;
    if ~isempty(Nominal)
        if ~isempty(Nominal.U)
            S.InUDD.CellData(:,5) = cellstr(num2str(Nominal.U(:)));
        end
        if ~isempty(Nominal.Y)
            S.OutUDD.CellData(:,5) = cellstr(num2str(Nominal.Y(:)));
        end
    end
    
    New.Ts = num2str(MPCobj.Ts);
    New.P = num2str(MPCobj.PredictionHorizon);
    if length(MPCobj.ControlHorizon) > 1
        New.Blocking = 1;
        New.M = int2str(length(MPCobj.ControlHorizon));
        New.BlockMoves = New.M;
        New.BlockAllocation = 'Custom';
        New.CustomAllocation = ['[ ',num2str(MPCobj.ControlHorizon),' ]'];
    else
        New.Blocking = 0;
        New.M = num2str(MPCobj.ControlHorizon);
        New.BlockMoves = '3';
        New.BlockAllocation = 'Beginning';
        New.CustomAllocation = '[ 2 3 5 ]';
    end
    New.setBlockingEnabledState;
    ULimits = New.Handles.ULimits.CellData;
    NumMV = size(ULimits);
    YLimits = New.Handles.YLimits.CellData;
    NumOV = size(YLimits);
    Uwts = New.Handles.Uwts.CellData;
    Ywts = New.Handles.Ywts.CellData;
    Usoft = New.Handles.Usoft.CellData;
    Ysoft = New.Handles.Ysoft.CellData;
    ODspecs = New.Handles.eHandles(1).UDD.CellData;
    IDspecs = New.Handles.eHandles(2).UDD.CellData;
    Nspecs = New.Handles.eHandles(3).UDD.CellData;
    estimdata = New.estimdata;
    
    New.Handles.TrackingUDD.Value = 0.8;
    MaxWt = max([max(MPCobj.Weights.ManipulatedVariables), ...
            max(MPCobj.Weights.ManipulatedVariablesRate), ...
            max(MPCobj.Weights.OutputVariables)]);
    New.Handles.HardnessUDD.Value = (3/28)*(log10(MPCobj.Weights.ECR/MaxWt) + 2);
    New.Handles.GainUDD.Value = 0.5;
        
    DefaultEstimator = true;
    Task = this.getRoot.Label;
    MPCdata=getmpcdata(MPCobj);
    UserModelFlag=MPCdata.OutDistFlag;
    if UserModelFlag
        estimdata(1).ModelUsed = 1;
        New.Handles.eHandles(1).rbModel.setSelected(true);
        estimdata(1).Model = MPCdata.OutDistModel;
        estimdata(1).ModelName = ['From:  ', Task];
        DefaultEstimator = false;
    else
        estimdata(1).ModelUsed = 0;
    end
    
    NumUD = size(IDspecs, 1);
    if NumUD > 0
        if isempty(MPCobj.Model.Disturbance)
            estimdata(2).ModelUsed = 0;
        else
            estimdata(2).ModelUsed = 1;
            New.Handles.eHandles(2).rbModel.setSelected(true);
            estimdata(2).Model = MPCobj.Model.Disturbance;
            estimdata(2).ModelName = ['From:  ', Task];
            DefaultEstimator = false;
        end
    end
    if ~isempty(MPCobj.Model.Noise)
        estimdata(3).ModelUsed = 1;
        New.Handles.eHandles(3).rbModel.setSelected(true);
        estimdata(3).Model = MPCobj.Model.Noise;
        estimdata(3).ModelName = ['From:  ', Task];
        DefaultEstimator = false;
    else
        estimdata(3).ModelUsed = 0;
    end
    for i = 1:NumMV
        ULimits{i,3} = ConstraintValue(MPCobj.ManipulatedVariables(i).Min);
        ULimits{i,4} = ConstraintValue(MPCobj.ManipulatedVariables(i).Max);
        ULimits{i,5} = ConstraintValue(MPCobj.ManipulatedVariables(i).RateMin);
        ULimits{i,6} = ConstraintValue(MPCobj.ManipulatedVariables(i).RateMax);
        Usoft{i,4} = ConstraintValue(MPCobj.ManipulatedVariables(i).MinECR);
        Usoft{i,6} = ConstraintValue(MPCobj.ManipulatedVariables(i).MaxECR);
        Usoft{i,8} = ConstraintValue(MPCobj.ManipulatedVariables(i).RateMinECR);
        Usoft{i,10} = ConstraintValue(MPCobj.ManipulatedVariables(i).RateMaxECR);
        Uwts{i,4} = WeightValue(MPCobj.Weights.ManipulatedVariables,i);
        Uwts{i,5} = WeightValue(MPCobj.Weights.ManipulatedVariablesRate,i);
    end
    for i = 1:NumOV
        YLimits{i,3} = ConstraintValue(MPCobj.OutputVariables(i).Min);
        YLimits{i,4} = ConstraintValue(MPCobj.OutputVariables(i).Max);
        Ysoft{i,4} = ConstraintValue(MPCobj.OutputVariables(i).MinECR);
        Ysoft{i,6} = ConstraintValue(MPCobj.OutputVariables(i).MaxECR);
        Ywts{i,4} = WeightValue(MPCobj.Weights.OutputVariables,i);
    end    
    New.Notes = char(MPCobj.Notes);
    New.Handles.ULimits.setCellData(ULimits);
    New.Handles.YLimits.setCellData(YLimits);
    New.Handles.Uwts.setCellData(Uwts);
    New.Handles.Ywts.setCellData(Ywts);
    New.Handles.Usoft.setCellData(Usoft);
    New.Handles.Ysoft.setCellData(Ysoft);
    New.estimdata = estimdata;
    New.HasUpdated = 0;
    New.DefaultEstimator = DefaultEstimator;
    if DefaultEstimator        
        New.setDefaultEstimator;
    else
        ODspecs(:,3) = {'White'};
        ODspecs(:,4) = {'0.0'};
        Nspecs(:,3) = {'White'};
        Nspecs(:,4) = {'1.0'};
        New.Handles.eHandles(1).UDD.setCellData(ODspecs);
        New.Handles.eHandles(3).UDD.setCellData(Nspecs);
        if NumUD > 0
            IDspecs(:,3) = {'White'};
            IDspecs(:,4) = {'0.0'};
            New.Handles.eHandles(2).UDD.setCellData(IDspecs);
        end
        New.EstimRefreshOK = true;
        New.RefreshEstimStates;
    end
end
New.ExportNeeded = 0;
this.RefreshControllerList;
this.Handles.UDDtable.SelectedRow = length(this.Controllers);
mpcupdatecetmstatus(S, '');    
mpcupdatecetmtext(S, ctrlMsgUtils.message('MPC:designtool:AddedPlantModel', Name, S.Label));

% ========================================================================

function WtVal = WeightValue(Weight,ind)
w = Weight(:,ind);
w(w<0)=0;
foo = num2str(w);
len = size(foo,1);
if len==1
    WtVal = foo;
else
    WtVal = '[';
    for ct = 1:len
        WtVal = [WtVal strtrim(foo(ct,:)) ';']; %#ok<*AGROW>
    end
    WtVal(end)=']';
end

function ConsVal = ConstraintValue(Constraint)
foo = num2str(Constraint);
len = size(foo,1);
if len==1
    ConsVal = foo;
else
    ConsVal = '[';
    for ct = 1:len
        ConsVal = [ConsVal strtrim(foo(ct,:)) ';'];
    end
    ConsVal(end)=']';
end