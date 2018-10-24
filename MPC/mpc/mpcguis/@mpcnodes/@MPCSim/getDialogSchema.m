function DialogPanel = getDialogSchema(this, manager) %#ok<INUSD>
% DIALOGPANEL Construct the MPCSim dialog panel

%  Author:  Larry Ricker
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.22 $ $Date: 2008/10/31 06:21:34 $

import com.mathworks.toolbox.mpc.*;
import com.mathworks.toolbox.control.util.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

S=this.getMPCStructure;
if isempty(this.Dialog)
    % Create new panel.
    mpcCursor(S.Frame, 'wait');

    MPCStructure = this.getMPCStructure;
    [NumMV, NumMD] = getMPCsizes(MPCStructure);

    % Sizing dimensions
    nHor = 450;
    nVer = 130;
    % LabelDimension = Dimension(110,20);

    % Simulation parameter controls
    ControllerLabel = MJLabel('Controller');
    sControllerLabel = ControllerLabel.getPreferredSize;
    sControllerLabel.width = 110;
    ControllerLabel.setPreferredSize(sControllerLabel);
    %ControllerLabel.setHorizontalAlignment(SwingConstants.RIGHT);
    ModelLabel = MJLabel('Plant');
    ModelLabel.setPreferredSize(sControllerLabel);
    %ModelLabel.setHorizontalAlignment(SwingConstants.RIGHT);
    LoopLabel = MJLabel('Close loops');
    LoopLabel.setPreferredSize(sControllerLabel);
    %LoopLabel.setHorizontalAlignment(SwingConstants.RIGHT);
    ConstraintLabel = MJLabel('Enforce constraints');
    ConstraintLabel.setPreferredSize(sControllerLabel);
    %ConstraintLabel.setHorizontalAlignment(SwingConstants.RIGHT);

    %ComboDimension = Dimension(130,20);
    ControllerCombo = MJComboBoxForLongStrings;
    sControllerCombo = ControllerCombo.getPreferredSize;
    sControllerCombo.width = 130;
    ControllerCombo.addItem('Dummy');
    ControllerCombo.setEditable(false);
    ControllerCombo.setSelectedIndex(0);
    ControllerCombo.setPreferredSize(sControllerCombo);
    ControllerCombo.setName('Sim_ControllerCombo');
    ModelCombo = MJComboBoxForLongStrings;
    ModelCombo.addItem('Dummy');
    ModelCombo.setEditable(false);
    ModelCombo.setSelectedIndex(0);
    ModelCombo.setPreferredSize(sControllerCombo);
    ModelCombo.setName('Sim_ModelCombo');
    LoopCheckBox = MJCheckBox('Close loops', this.ClosedLoop);
    LoopCheckBox.setName('Sim_LoopCheckBox');
    ConstraintCheckBox = MJCheckBox('Enforce constraints', this.ConstraintsEnforced);
    ConstraintCheckBox.setName('Sim_ConstraintCheckBox');
    
    TsLabel = MJLabel('Control interval');
    TsLabel.setPreferredSize(sControllerLabel);
    %TsLabel.setHorizontalAlignment(SwingConstants.RIGHT);
    TsValue = MJLabel('1.0');
    TsValue.setPreferredSize(Dimension(50,20));
    TendLabel = MJLabel('Duration');
    TendLabel.setPreferredSize(sControllerLabel);
    %TendLabel.setHorizontalAlignment(SwingConstants.RIGHT);
    TendField = MJTextField(5);
    TendField.setText(this.Tend);
    TendField.setName('Sim_Tend');

    % Simulation parameter panel assembly
    pLoop = MJPanel(BorderLayout);
    simSettingsOuterPNL = MJPanel(BorderLayout(5,5));
    simSettingsOuterPNL.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
    pLoop.add(simSettingsOuterPNL,BorderLayout.NORTH);
    simSettingsInnerPNL = MJPanel(GridLayout(3,1,5,5));

    controllPnl = MJPanel(BorderLayout(10,10));
    controllPnl.add(ControllerLabel,BorderLayout.WEST);
    controllPnl.add(ControllerCombo,BorderLayout.CENTER);
    controllPnl.add(LoopCheckBox,BorderLayout.EAST);
    simSettingsInnerPNL.add(controllPnl);

    plantPnl = MJPanel(BorderLayout(10,10));
    plantPnl.add(ModelLabel,BorderLayout.WEST);
    plantPnl.add(ModelCombo,BorderLayout.CENTER);
    plantPnl.add(ConstraintCheckBox,BorderLayout.EAST);
    simSettingsInnerPNL.add(plantPnl);

    timePnl = MJPanel(BorderLayout(10,10));
    timePnl.add(TendLabel,BorderLayout.WEST);
    timePnl.add(TendField,BorderLayout.CENTER);
    intervalPnl = MJPanel;
    intervalPnl.add(TsLabel);
    intervalPnl.add(TsValue);
    % Size the checkboxes
    sintervalPnl = intervalPnl.getPreferredSize;
    sLoopCheckBox = LoopCheckBox.getPreferredSize;
    sLoopCheckBox.width = sintervalPnl.width;
    LoopCheckBox.setPreferredSize(sLoopCheckBox);
    sConstraintCheckBox = ConstraintCheckBox.getPreferredSize;
    sConstraintCheckBox.width = sintervalPnl.width;
    ConstraintCheckBox.setPreferredSize(sConstraintCheckBox);    
    
    timePnl.add(intervalPnl,BorderLayout.EAST);
    simSettingsInnerPNL.add(timePnl);
    simSettingsOuterPNL.add(simSettingsInnerPNL,BorderLayout.NORTH);
    
    % Signal controls

    % Table constants
    SignalCombo = MJComboBox;
    SignalCombo.setEditable(0);
    SignalCombo.addItem('Constant');
    SignalCombo.addItem('Step');
    SignalCombo.addItem('Ramp');
    SignalCombo.addItem('Sine');
    SignalCombo.addItem('Pulse');
    SignalCombo.addItem('Gaussian');
    ViewportSize = [nHor-50, round(0.70*nVer)];
    ColumnSizes=50*ones(1,8);
    ResizePolicy = '';
    isEditable = [false false true true false false false true];
    javaClass = logical([ones(1,7) 0]);
    CellData = {' ',' ',' ',' ',' ',' ',' ', false};
    % Setpoint definition table
    ColNames = {'Name', 'Units', 'Type', 'Initial Value', 'Size', ...
        'Time', 'Period', 'Look Ahead'};
    if isempty(this.SaveData)
        Setpoints = mpcobjects.TableObject(ColNames, isEditable, ...
            javaClass, CellData, @SignalCheckFcn);
    else
        Saved = this.SaveData{1};
        Setpoints = mpcobjects.TableObject(ColNames, Saved.isEditable, ...
            javaClass, Saved.CellData, @SignalCheckFcn);
        Setpoints.Defaults = Saved.Defaults;
    end
    Setpoints.Table = MPCTable(Setpoints, ColNames, ...
        Setpoints.isEditable', Setpoints.CellData', javaClass);
    Setpoints.Table.setName('Sim_SetpointTable');
    Col4 = Setpoints.Table.getColumnModel.getColumn(2);
    Col4.setCellEditor(DefaultCellEditor(SignalCombo));
    Setpoints.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);

    % Measured disturbance definition table
    if NumMD > 0
        if isempty(this.SaveData)
            MeasDist = mpcobjects.TableObject(ColNames, isEditable, ...
                javaClass, CellData, @SignalCheckFcn);
        else
            Saved = this.SaveData{2};
            MeasDist = mpcobjects.TableObject(ColNames, Saved.isEditable, ...
                javaClass, Saved.CellData, @SignalCheckFcn);
            MeasDist.Defaults = Saved.Defaults;
        end
        MeasDist.Table = MPCTable(MeasDist, ColNames, ...
            MeasDist.isEditable', MeasDist.CellData', javaClass);
        MeasDist.Table.setName('Sim_MeasDistTable');
        Col4 = MeasDist.Table.getColumnModel.getColumn(2);
        Col4.setCellEditor(DefaultCellEditor(SignalCombo));
        MeasDist.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
    end

    % Unmeasured disturbance definition table
    if isempty(this.SaveData)
        UnMeasDist = mpcobjects.TableObject(ColNames(1,1:7), isEditable(1,1:7), ...
            javaClass(1,1:7), CellData(1,1:7), @SignalCheckFcn);
    else
        Saved = this.SaveData{3};
        UnMeasDist = mpcobjects.TableObject(ColNames(1,1:7), Saved.isEditable, ...
            javaClass(1,1:7), Saved.CellData, @SignalCheckFcn);
        UnMeasDist.Defaults = Saved.Defaults;
    end
    UnMeasDist.Table = MPCTable(UnMeasDist, ColNames(1,1:7), ...
        UnMeasDist.isEditable', UnMeasDist.CellData', javaClass(1,1:7));
    UnMeasDist.Table.setName('Sim_UnMeasDistTable');
    Col4 = UnMeasDist.Table.getColumnModel.getColumn(2);
    Col4.setCellEditor(DefaultCellEditor(SignalCombo));
    UnMeasDist.sizeTable(ViewportSize,ColumnSizes(1,1:7),ResizePolicy);

    % Signal panel assembly

    vSB = MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED;
    hSB = MJScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED;
    % r.c. initialize c as a GridBagConstraints object
    c = GridBagConstraints;
    c.fill = GridBagConstraints.BOTH;
    c.gridx = 0;
    c.gridy = 0;
    c.weightx = 1;
    c.weighty = 1;
    c.insets = Insets(2, 2, 2, 2);
    pSetpoints = MJPanel(GridBagLayout);
    pSetpoints.add(MJScrollPane(Setpoints.Table, vSB, hSB), c);
    pUDisturbances = MJPanel(GridBagLayout); 
    pUDisturbances.add(MJScrollPane(UnMeasDist.Table, vSB, hSB), c);

    Title = TitledBorder(' Simulation settings ');
    Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
    pLoop.setBorder(Title);
    Title = TitledBorder(' Setpoints ');
    Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
    pSetpoints.setBorder(Title);
    Title = TitledBorder(' Unmeasured disturbances ');
    Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
    pUDisturbances.setBorder(Title);

    if NumMD > 0
        pDisturbances = MJPanel(GridBagLayout); 
        pDisturbances.add(MJScrollPane(MeasDist.Table, vSB, hSB), c);
        Title = TitledBorder(' Measured disturbances ');
        Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
        pDisturbances.setBorder(Title);
    end

    % Run button
    RunButton = MJButton('Simulate');
    RunButton.setName('Sim_RunButton');
    HelpButton = MJButton('Help');
    HelpButton.setName('Sim_HelpButton');
    AdvisorButton = MJButton('Tuning Advisor');
    AdvisorButton.setName('Sim_AdvisorButton');
    RunPanel = MJPanel;
    RunPanel.add(RunButton);
    RunPanel.add(HelpButton);
    RunPanel.add(AdvisorButton);

    % Dialog panel assembly
    DialogPanel = MJPanel;
    DialogPanel.setLayout(GridBagLayout);
    c.fill = GridBagConstraints.BOTH;
    c.gridx = 0;
    c.gridy = GridBagConstraints.RELATIVE;
    c.weightx = 1;
    c.weighty = 0.2;
    c.insets = Insets(5, 5, 5, 5);
    DialogPanel.add(pLoop, c);

    c.fill = GridBagConstraints.BOTH;
    c.gridx = 0;
    c.gridy = GridBagConstraints.RELATIVE;
    c.weightx = 1;
    c.weighty = 0.5;
    c.insets = Insets(5, 5, 5, 5);
    DialogPanel.add(pSetpoints, c);
    % Add measured disturbances table if they are part of the structure
    if NumMD > 0
        DialogPanel.add(pDisturbances, c);
    end
    DialogPanel.add(pUDisturbances, c);
    c.weighty = 0;
    c.fill = GridBagConstraints.HORIZONTAL;
    DialogPanel.add(RunPanel, c);

    % Save handles

    this.Handles.RunButton = RunButton;
    this.Handles.AdvisorButton = AdvisorButton;
    this.Handles.ControllerCombo = ControllerCombo;
    this.Handles.ModelCombo = ModelCombo;
    this.Handles.LoopCheckBox = LoopCheckBox;
    this.Handles.ConstraintCheckBox = ConstraintCheckBox;
    this.Handles.Setpoints = Setpoints;
    this.Handles.UnMeasDist = UnMeasDist;
    this.Handles.TsValue = TsValue;
    this.Handles.TendField = TendField;
    this.Handles.SignalCombo = SignalCombo;  % Cell editor for signal type column
    
    this.Advisor = mpcobjects.advisor(this);
    
    % Define callbacks
    set(handle(RunButton,'callbackproperties'), ...
        'ActionPerformedCallback',{@LocalCBs, this, 'RunButton', RunButton});
    set(handle(TendField,'callbackproperties'),...
        'ActionPerformedCallback',{@LocalCBs, this, 'Tend', TendField});
    set(handle(TendField,'callbackproperties'),...
        'FocusLostCallback',{@LocalCBs, this, 'Tend', TendField});
    set(handle(LoopCheckBox,'callbackproperties'),...
        'ActionPerformedCallback',{@LocalCBs, this, 'Loops', LoopCheckBox});
    set(handle(ConstraintCheckBox,'callbackproperties'),...
        'ActionPerformedCallback', {@LocalCBs, this, 'Constraints', ConstraintCheckBox});
    set(handle(ModelCombo,'callbackproperties'), ...
        'ActionPerformedCallback', {@LocalModelSelection, this});
    set(handle(ControllerCombo,'callbackproperties'), ...
        'ActionPerformedCallback', {@LocalControllerSelection, this});
    set(handle(HelpButton, 'callbackproperties'), ...
        'ActionPerformedCallback', {@mpcCSHelp, 'MPCSIMMAIN'});
    set(handle(AdvisorButton, 'callbackproperties'), ...
        'ActionPerformedCallback', {@LocalTuningAdvisor, this});

    % Define listeners

    this.addListeners(handle.listener(this, this.findprop('Tend'), ...
        'PropertyPostSet',{@localPanelListener, this, TendField}));
    this.addListeners(handle.listener(this, this.findprop('ClosedLoop'), ...
        'PropertyPostSet',{@localPanelListener, this, LoopCheckBox}));
    this.addListeners(handle.listener(this, this.findprop('ConstraintsEnforced'), ...
        'PropertyPostSet',{@localPanelListener, this, ConstraintCheckBox}));

    % These react to a change in the MPCStructures node tabular data
    S = this.getMPCStructure;
    this.addListeners(handle.listener(S, S.findprop('InData'), ...
        'PropertyPostSet',{@StructureDataListener, this}));
    this.addListeners(handle.listener(S, S.findprop('OutData'), ...
        'PropertyPostSet',{@StructureDataListener, this}));

    % These listen for changes that require the scenario to be recalculated
    this.addListeners(handle.listener(this, this.findprop('Ts'), ...
        'PropertyPostSet',{@localUpdateListener, this}));
    this.addListeners(handle.listener(this, this.findprop('Tend'), ...
        'PropertyPostSet',{@localUpdateListener, this}));
    this.addListeners(handle.listener(Setpoints, Setpoints.findprop('CellData'), ...
        'PropertyPostSet',{@localTableListener, this, Setpoints, true}));
    if NumMD > 0
        this.Handles.MeasDist = MeasDist;
        this.addListeners(handle.listener(MeasDist, MeasDist.findprop('CellData'), ...
            'PropertyPostSet',{@localTableListener, this, MeasDist, false}));
    else
        this.Handles.MeasDist = {};
    end
    this.addListeners(handle.listener(UnMeasDist, UnMeasDist.findprop('CellData'), ...
        'PropertyPostSet',{@localTableListener, this, UnMeasDist, false}));

    % Listen for an update in scenario property
    this.addListeners(handle.listener(this, this.findprop('Scenario'), ...
        'PropertyPostSet',{@ScenarioUpdateListener, this}));

    % Set default values
    if isempty(this.SaveData)
        setDefaultValues(this);
    end
    LocalRefreshTsLabel(this);

    this.Dialog = DialogPanel;
    % Force creation of MPCSims panel
    MPCSims = this.up;
    if isempty(MPCSims.Dialog)
        MPCSims.getDialogInterface(S.TreeManager);
    end
    mpcCursor(S.Frame, 'default');
else
    % Use existing panel.  Update tabular displays 
    % if necessary.
    if this.updateTables
        mpcCursor(S.Frame, 'wait');
        this.SignalLabelUpdate;
        mpcCursor(S.Frame, 'default');
    end
    % Also possible update in the sampling period display, which might
    % trigger an mpc object update:
    LocalRefreshTsLabel(this);
    DialogPanel = this.Dialog;
    % Now return the dialog panel for display.
end

% Update combo boxes
MPCModels = this.getMPCModels;
mpc_combo_updater(this.Handles.ModelCombo, MPCModels.Labels, ...
    this.PlantName);
MPCControllers = this.getMPCControllers;
mpc_combo_updater(this.Handles.ControllerCombo, ...
    MPCControllers.Controllers, this.ControllerName);

% Indicate that this is the current scenario
this.up.CurrentScenario = this.Label;

% ------------------------------------------------------

function StructureDataListener(eventSrc, eventData, this) %#ok<*INUSL>

% Respond to a user modification to the tabular data on the 
% MPCStructure node.  Only affects the non-editable columns
% in the MPCController tables.

this.updateTables = 1;

% ------------------------------------------------------

function localUpdateListener(eventSrc, eventData, this)

% Responds to a change in the scenario data.  Set the flag
% that causes the scenario to be updated when next used in
% a simulation.

Root = this.getRoot;
this.HasUpdated = 1;
Root.Dirty = true;

% ----------------------------------------------------------------------- %

function localTableListener(eventSrc, eventData, this, UTable, isRef)

% Responds to a change in the tablular data.

% Update notification
localUpdateListener(eventSrc, eventData, this);

% Initialization
hasChanged = false;
Data = UTable.CellData;
[Rows,Cols]=size(Data);

% Force look-ahead to be same for all signals in this table
if Cols == 8
    if isRef
        Test = this.rLookAhead;
    else
        Test = this.vLookAhead;
    end
    for i = 1:Rows
        if Data{i,8} ~= Test
            hasChanged = true;
            break
        end
    end
    if hasChanged
        if isRef
            this.rLookAhead = ~Test;
        else
            this.vLookAhead = ~Test;
        end
        for i = 1:Rows
            UTable.CellData{i,8} = logical(~Test);
        end
    end
end

% Possible update of editable status
isEditable = UTable.isEditable;
ix = 5:7;  % These are the columns that depend on signal type
newDefaults = false;
if all(size(isEditable) == [Rows, Cols])
    % isEditable is correct size, so check row contents.
    for i = 1:Rows
        Correct = localGetIsEditable(Data(i,3));
        if any(isEditable(i,ix) ~= Correct)
            isEditable(i,ix) = Correct;
            hasChanged = true;
            newDefaults = true;
        end
    end
else
    % isEditable is wrong size, so update
    isEditable = logical(ones(Rows,1)*isEditable(1,:));
    for i = 1:Rows
        isEditable(i,ix)= localGetIsEditable(Data(i,3));
    end
    hasChanged = true;
    newDefaults = true;
end
% Force update if user has changed signal type
if ~isempty(UTable.Defaults)
    for i = 1:Rows
        Type = char(UTable.CellData(i,3));
        if ~strcmp(Type, UTable.Defaults.OldType{i,1})
            hasChanged = true;
            newDefaults = true;
            break
        end
    end
end

if hasChanged
    if newDefaults
        UTable.CellData = localResetDefaultValues(Data, UTable.Defaults);
    end
    UTable.isEditable = isEditable;
    UTable.Table.getModel.updateTableData(UTable.Table, UTable, ...
        UTable.isEditable', UTable.CellData');
end

% Save settings in case signal type changes back to current one
if isempty(UTable.Defaults)
    DefCell = cell(Rows,1);
    UTable.Defaults = struct('Constant', {DefCell}, 'Step', {DefCell}, ...
            'Ramp', {DefCell}, 'Sine', {DefCell}, 'Pulse', {DefCell}, ...
            'Gaussian', {DefCell}, 'OldType', {DefCell});
end
for i=1:Rows
    Type = char(UTable.CellData{i,3});
    UTable.Defaults.(Type){i,1} = UTable.CellData(i,4:7);
    UTable.Defaults.OldType{i,1} = Type;
end

% ------------------------------------------------------

function CellData = localResetDefaultValues(Data, SavedData)

% Resets defaults when signal types change.
Rows = size(Data,1);
CellData = Data;
jNullStr = java.lang.String('');
jOne = java.lang.String('1.0');
jZero = java.lang.String('0.0');
for i = 1:Rows
    Type = char(CellData{i,3});
    IVal = CellData{i,4};
    if isempty(SavedData) || isempty(SavedData.(Type){i,1})
        switch Type
            case {'Constant'}
                Defaults = {IVal, jNullStr, jNullStr, jNullStr};
            case {'Step', 'Ramp'}
                Defaults = {IVal, jOne, jOne, jNullStr};
            case {'Sine', 'Pulse'}
                Defaults = {IVal, jOne, jZero, jOne};
            case {'Gaussian'}
                Defaults = {IVal, jOne, jOne, jNullStr};
%             otherwise
%                 error('Unexpected signal type "%s"',Type);
        end
    else
        Defaults = SavedData.(Type){i,1};
    end
    CellData(i,4:7) = Defaults;
end

% ------------------------------------------------------

function Settings = localGetIsEditable(Type)

% Get appropriate isEditable settings for given signal type
SignalTypes = {'Constant','Step','Ramp','Sine','Pulse','Gaussian'};
itype = strcmp(SignalTypes,Type);
% if isempty(itype)
%     error('Unable to match signal type "%s"',Type{1});
% end
Settings = [false, false, false
    true, true, false
    true, true, false
    true, true, true
    true, true, true
    true, true, false];
Settings = Settings(itype,:);


% ------------------------------------------------------

function LocalModelSelection(eventSrc, eventData, this)

% Callback when user selects a model in the combo box.
NewModel = this.Handles.ModelCombo.getSelectedItem;
if ischar(NewModel) && ~isempty(NewModel)
    this.PlantName = NewModel;
end

% ------------------------------------------------------

function LocalControllerSelection(eventSrc, eventData, this)

% Callback when user selects a controller in the combo box.
NewController = this.Handles.ControllerCombo.getSelectedItem;
if ischar(NewController) && ~isempty(NewController)
    this.ControllerName = NewController;
    LocalRefreshTsLabel(this);
end

% ------------------------------------------------------

function ScenarioUpdateListener(varargin)

this = varargin{end};
this.setNewDate;

% ------------------------------------------------------

function LocalRefreshTsLabel(varargin)

% Refreshes the controller sampling period label.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
        
%disp('In LocalRefreshTsLabel')
this = varargin{end};
Controller = this.ControllerName;
ControllerNode = this.getMPCControllers.find('Label',Controller);
Ts = ControllerNode.Ts;        % String format
if isempty(Ts)
    Ts = '1';   % Default if controller node hasn't been opened yet.
end
this.Ts = evalin('base', Ts);  % Double
TsValue = this.Handles.TsValue;
Str = java.lang.String(num2str(this.Ts));
awtinvoke(TsValue,'setText(Ljava.lang.String;)',Str);

% ------------------------------------------------------

function setDefaultValues(this)

% Sets default values and initial conditions.

S = this.getRoot;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
OutIx =  1:NumOut;
if ~isempty(S.iNO)
    OutIx(S.iNO) = [];
    NumOut = length(OutIx);
end
% Initialize tabular data
Setpoints = cell(NumOut,8);
NumUMD = NumUD + NumMO + NumMV;
UnMeasDist = cell(NumUMD, 7);
Setpoints(:,:) = {java.lang.String(' ')};
Setpoints(:,3) = {'Constant'};
Setpoints(:,4) = {java.lang.String('0.0')};
Setpoints(:,8) = {false};
ix = [1 2 4];
jx = [1 4 5];
Setpoints(:,ix) = S.OutData(OutIx,jx);
if NumMD > 0
    MeasDist = cell(NumMD, 8);
    MeasDist(:,:) = {java.lang.String(' ')};
    MeasDist(:,3) = {'Constant'};
    MeasDist(:,4) = {java.lang.String('0.0')};
    MeasDist(:,8) = {false};
    MeasDist(:,ix) = S.InData(S.iMD,jx);
    this.Handles.MeasDist.setCellData(MeasDist);
end
UnMeasDist(:,:) = {java.lang.String(' ')};
UnMeasDist(:,3) = {'Constant'};
UnMeasDist(:,4) = {java.lang.String('0.0')};

ix = [1 2];
jx = [1 4];
if NumUD > 0
    UnMeasDist(1:NumUD,ix) = S.InData(S.iUD,jx);
end
UnMeasDist(NumUD+1:NumUD+NumMO,ix) = S.OutData(S.iMO,jx);
UnMeasDist(NumUD+NumMO+1:end,ix) = S.InData(S.iMV,jx);

% Move local data to permanent storage
this.Handles.Setpoints.setCellData(Setpoints);
this.Handles.UnMeasDist.setCellData(UnMeasDist);

% -----------------------------------------------------

function localPanelListener(eventSrc, eventData, this, thisJava)

% Updates the dialog panel in response to changes in the underlying UDD
% objects.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

Prop = eventSrc.Name;
Val = get(this,Prop);
switch Prop
    case 'Tend'
        % Source is a JTextField
        Str=java.lang.String(Val);
        awtinvoke(thisJava,'setText(Ljava.lang.String;)',Str);
    case {'ClosedLoop', 'ConstraintsEnforced'}
        % Source is a check box
        awtinvoke(thisJava,'setSelected(Z)',(Val>0));
%     otherwise
%         errordlg(['Unexpected property code "',Prop,'" in localPanelListener']);
end

% ---------------------------------------------

function LocalCBs(eventSrc, eventData, this, thisProp, thisJava)

% Handles callbacks for standard java controls.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

switch thisProp
    case 'Tend'
        % Store if valid.  Must be scalar >0 0.
        Num = char(thisJava.getText);
        Value = LocalStr2Double(Num);
        if ~isnan(Value) == 1 && Value > 0
            this.Tend = Num;
        else
            % Invalid, so replace java display with UDD value
            localFieldError(thisJava, 'Duration must be positive, finite.');
            PropS = java.lang.String(this.Tend);
            awtinvoke(thisJava,'setText(Ljava.lang.String;)',PropS);
        end
    case 'Loops'
        % Source is a check box
        this.ClosedLoop = thisJava.isSelected;
    case 'Constraints'
        % Source is a check box
        this.ConstraintsEnforced = thisJava.isSelected;
    case 'RunButton'
        % User has pushed the run button
        this.runSimulation;
%     otherwise
%         errordlg(sprintf('Unexpected property code "%s" in LocalCBs', thisProp));
end

% --------------------------------------------------------------
function LocalTuningAdvisor(eventSrc, eventData, this)
% get controller node
Controllers = this.getMPCControllers;
Controller = Controllers.find('Label', this.Handles.ControllerCombo.getSelectedItem);
% time varying and non-diagonal weights are not supported in GUI
MPCobj = Controller.getController;
if iscell(MPCobj.Weights.ManipulatedVariables) || size(MPCobj.Weights.ManipulatedVariables,1)>1 || ...
    iscell(MPCobj.Weights.ManipulatedVariablesRate) || size(MPCobj.Weights.ManipulatedVariablesRate,1)>1 || ...
    iscell(MPCobj.Weights.OutputVariables) || size(MPCobj.Weights.OutputVariables,1)>1 
    uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:InvalidWeightsForAdvisor'), ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    return
end
% create tuning advisor dialog
if ~ishandle(this.Advisor)
    this.Advisor = mpcobjects.advisor(this);
end
if isempty(this.Advisor.Handles)
    this.Advisor.createDialog(this.getMPCSims.CurrentScenario,this.ControllerName,Controller);
end
this.Advisor.show;

% --------------------------------------------------------------
function Value = LocalStr2Double(String)
try
    Value = evalin('base', String);
    if ~isreal(Value) || length(Value) ~= 1
        Value = NaN;
    end
catch ME %#ok<*NASGU>
    Value = NaN;
end

% --------------------------------------------------------------------------- %

function Valid = localFieldError(thisJava,Message)
% Temporarily disable the field's loss of focus callback and display an
% error message.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

CB=get(thisJava,'FocusLostCallback');
set(thisJava,'FocusLostCallback',[]);
waitfor(errordlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
set(thisJava,'FocusLostCallback',CB);
awtinvoke(thisJava,'requestFocus(Z)',true);
Valid = false;

% ---------------------------------------------

function OK = SignalCheckFcn(String, row, col)
% Check validity of user input.  Always accept a null string.
if col == 8
    % Editor is a checkbox, so must be OK
    OK = 1;
    return
end
String = char(String);
if isempty(String)
    OK = 1;
    return
end
switch col
    case {3}
        % String controlled by a combo box, must be OK
        OK = 1;
    case {4, 5}
        % Any finite number is OK
        Value = LocalStr2Double(String);
        if isnan(Value) || abs(Value) == Inf
            Message = ctrlMsgUtils.message('MPC:designtool:SignalInitialValueSize');                        
            uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
            OK = 0;
        else
            OK = 1;
        end
    otherwise
        % Must be non-negative, finite
        Value = LocalStr2Double(String);
        if isnan(Value) || Value < 0 || abs(Value) == Inf
            Message = ctrlMsgUtils.message('MPC:designtool:SignalInitialTimePeriod');                        
            uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
            OK = 0;
        else
            OK = 1;
        end
end
