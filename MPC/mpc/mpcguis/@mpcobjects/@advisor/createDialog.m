function createDialog(this,varargin)
% CREATEDIALOG Create the sensitivity analysis dialog window object.

% Author(s): Rong Chen
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/12/29 02:12:15 $

% Callback when user clicks tuning advisor button
% Create the advisor dialog that handles the sensitivity analysis
% One dialog per MPC design task 
% "this" is the calling MPCSim node.

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

%% Constants
nHor = 800;
nVer = 600;
DialogFont = Font('Dialog',Font.PLAIN,12);
vSB = MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED;
hSB = MJScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED;

%% GridBagLayout Constants
c = GridBagConstraints;
c.weightx = 1;
c.weighty = 1;

%% Dialog
jDialog = MJFrame;
jDialog.setName('MPCAdvisorDialog');
jDialog.setModal(true);
jDialog.setSize(Dimension(nHor,nVer));
jDialog.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
jDialog.setTitle([ctrlMsgUtils.message('MPC:designtool:AdvisorTitle'), ' - ' this.Task.Label]);
jDialog.setLocation(java.awt.Point(20,20));
if ~isempty(this.Scenario.AdvisorWindowLocation)
    jDialog.setLocation(this.Scenario.AdvisorWindowLocation);
end

%% Head Panel
c.fill = GridBagConstraints.HORIZONTAL;
% Scenario label
jScenarioLabel = MJLabel('Scenario in design:  ', SwingConstants.RIGHT);
jScenarioLabel.setFont(DialogFont);
jScenarioName = MJLabel('', SwingConstants.LEFT);
jScenarioName.setFont(DialogFont);
font = jScenarioName.getFont();
awtinvoke(jScenarioName,'setFont(Ljava.awt.Font;)',font.deriveFont(font.getStyle()|Font.BOLD));
jScenarioName.setName('ScenarioName');
% current mpc
jControllerLabel = MJLabel('Controller in design:  ', SwingConstants.RIGHT);
jControllerLabel.setFont(DialogFont);
jControllerName = MJLabel('', SwingConstants.LEFT);
jControllerName.setFont(DialogFont);
font = jControllerName.getFont();
awtinvoke(jControllerName,'setFont(Ljava.awt.Font;)',font.deriveFont(font.getStyle()|Font.BOLD));
jControllerName.setName('ControllerName');
% Performance function combo
jPerfFuncLabel = MJLabel('Select a performance function:  ', SwingConstants.RIGHT);
jPerfFuncLabel.setFont(DialogFont);
jPerfFuncLabel.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorPerfFuncTooltip'));
jPerfFuncCombo = MJComboBox({'ISE' 'IAE' 'ITSE' 'ITAE'});
jPerfFuncCombo.setEditable(false);
jPerfFuncCombo.setPreferredSize(Dimension(100,25));
jPerfFuncCombo.setName('PerfFuncCombo');
jPerfFuncCombo.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorPerfFuncTooltip'));
% panel
jPanelHead = MJPanel;
jPanelHead.setLayout(GridBagLayout);
c.gridx = 0;
c.gridy = 0;
jPanelHead.add(jScenarioLabel);
c.gridx = 1;
jPanelHead.add(jScenarioName);
c.gridx = 2;
jPanelHead.add(jControllerLabel,c);
c.gridx = 3;
jPanelHead.add(jControllerName,c);
c.gridx = 4;
jPanelHead.add(jPerfFuncLabel);
c.gridx = 5;
jPanelHead.add(jPerfFuncCombo);

%% common table parameters
NumOfCol = 5;
ColNames = {'Name','Performance Weight','Sensitivity','Tuning Direction','Current Tuning'};
isEditable = [false true false false true];
javaClass = true(1,NumOfCol);
ViewportSize = [nHor-50, round(0.25*nVer)];
ColumnSizes=50*ones(1,NumOfCol);
ResizePolicy = '';
c.fill = GridBagConstraints.BOTH;

%% Output Weights Panel
Yweight = mpcobjects.TableObject(ColNames, isEditable, javaClass, cell(0,NumOfCol), @weightCheckFcn, this);
Yweight.Table = MPCTable(Yweight, ColNames, isEditable', cell(NumOfCol,0), javaClass);
Yweight.Table.setName('MPC_AdvisorYweightTable');
Yweight.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
Yweight.Table.getTableHeader.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorTableHeaderTooltip'));
jPanelYweight = MJPanel;
jPanelYweight.setLayout(GridBagLayout);
Title = TitledBorder(' Output Weights ');
Title.setTitleFont(DialogFont);
jPanelYweight.setBorder(Title);
jPanelYweight.add(MJScrollPane(Yweight.Table, vSB, hSB), c);


%% Input Weights Panel
Uweight = mpcobjects.TableObject(ColNames, isEditable, javaClass, cell(0,NumOfCol), @weightCheckFcn, this);
Uweight.Table = MPCTable(Uweight, ColNames, isEditable', cell(NumOfCol,0), javaClass);
Uweight.Table.setName('MPC_AdvisorUweightTable');
Uweight.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
Uweight.Table.getTableHeader.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorTableHeaderTooltip'));
jPanelUweight = MJPanel;
jPanelUweight.setLayout(GridBagLayout);
Title = TitledBorder(' Input Weights ');
Title.setTitleFont(DialogFont);
jPanelUweight.setBorder(Title);
jPanelUweight.add(MJScrollPane(Uweight.Table, vSB, hSB), c);

%% Input Rate Weights Panel
URweight = mpcobjects.TableObject(ColNames, isEditable, javaClass, cell(0,NumOfCol), @weightCheckFcn, this);
URweight.Table = MPCTable(URweight, ColNames, isEditable', cell(NumOfCol,0), javaClass);
URweight.Table.setName('MPC_AdvisorURweightTable');
URweight.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
URweight.Table.getTableHeader.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorTableHeaderTooltip'));
jPanelURweight = MJPanel;
jPanelURweight.setLayout(GridBagLayout);
Title = TitledBorder(' Input Rate Weights ');
Title.setTitleFont(DialogFont);
jPanelURweight.setBorder(Title);
jPanelURweight.add(MJScrollPane(URweight.Table, vSB, hSB), c);

%% Display Panel
c.fill = GridBagConstraints.HORIZONTAL;
% Compute Baseline button
jComputeButton = MJButton('Baseline');
jComputeButton.setName('MPC_AdvisorCompute');
jComputeButton.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorBaselineButtonTooltip'));
% baseline performance
jOriginalPerformanceLabel = MJLabel('Baseline Performance: ', SwingConstants.RIGHT);
jOriginalPerformanceLabel.setFont(DialogFont);
jOriginalPerformanceValue = MJLabel('Click "Baseline"', SwingConstants.LEFT);
jOriginalPerformanceValue.setName('OriginalPerformanceValueLabel');
jOriginalPerformanceValue.setFont(DialogFont);
font = jOriginalPerformanceValue.getFont();
awtinvoke(jOriginalPerformanceValue,'setFont(Ljava.awt.Font;)',font.deriveFont(font.getStyle()|Font.BOLD));
% Analyze button
jCompareButton = MJButton('Analyze');
jCompareButton.setName('MPC_AdvisorCompare');
jCompareButton.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorAnalyzeButtonTooltip'));
% new performance
jNewPerformanceLabel = MJLabel('Current Tuning Performance: ', SwingConstants.RIGHT);
jNewPerformanceLabel.setFont(DialogFont);
jNewPerformanceValue = MJLabel('Click "Analyze"', SwingConstants.LEFT);
jNewPerformanceValue.setName('NewPerformanceValueLabel');
jNewPerformanceValue.setFont(DialogFont);
font = jNewPerformanceValue.getFont();
awtinvoke(jNewPerformanceValue,'setFont(Ljava.awt.Font;)',font.deriveFont(font.getStyle()|Font.BOLD));
% panel
jPanelDisplay = MJPanel;
jPanelDisplay.setLayout(GridBagLayout);
c.gridx = 0;
c.gridy = 0;
jPanelDisplay.add(jComputeButton,c);
c.gridx = 1;
jPanelDisplay.add(jOriginalPerformanceLabel,c);
c.gridx = 2;
jPanelDisplay.add(jOriginalPerformanceValue,c);
c.gridx = 3;
jPanelDisplay.add(jCompareButton,c);
c.gridx = 4;
jPanelDisplay.add(jNewPerformanceLabel,c);
c.gridx = 5;
jPanelDisplay.add(jNewPerformanceValue,c);

%% Buttons Panel
% modal checkbox 
jModalCheckBox = MJCheckBox('Tuning Advisor is Modal',true);
jModalCheckBox.setName('MPC_AdvisorModal');
jModalCheckBox.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorModalCheckBoxTooltip'));
% restore baseline button
jUpdateButton = MJButton('Update Controller in MPC Tool');
jUpdateButton.setName('MPC_AdvisorUpdate');
jUpdateButton.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorUpdateButtonTooltip'));
% update MPC tool button
jRestoreButton = MJButton('Restore Baseline Weights');
jRestoreButton.setName('MPC_AdvisorRestore');
jRestoreButton.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorRestoreButtonTooltip'));
% close button
jCloseButton = MJButton('Close');
jCloseButton.setName('MPC_AdvisorClose');
jCloseButton.setToolTipText(ctrlMsgUtils.message('MPC:designtool:AdvisorCloseButtonTooltip'));
% help button
jHelpButton = MJButton('Help');
jHelpButton.setName('MPC_MPC_AdvisorHelp');
% panel
jPanelButton = MJPanel;
jPanelButton.add(jModalCheckBox);
jPanelButton.add(jRestoreButton);
jPanelButton.add(jUpdateButton);
jPanelButton.add(jCloseButton);
jPanelButton.add(jHelpButton);

% Final panel assembly
p = jDialog.getContentPane;
p.setLayout(GridBagLayout);
c.fill = GridBagConstraints.BOTH;
c.weighty = 0.1;
c.insets = Insets(2, 5, 2, 5); % top left bottom right
c.gridx = 0;
c.gridy = 0;
p.add(jPanelHead, c);
c.weighty = 0.25;
c.gridy = 1;
p.add(jPanelYweight, c);
c.gridy = 2;
p.add(jPanelUweight, c);
c.gridy = 3;
p.add(jPanelURweight, c);
c.gridy = 4;
c.weighty = 0.1;
p.add(jPanelDisplay, c);
c.gridy = 5;
p.add(jPanelButton, c);

%% Dialog Initialization
% initialize scenario textfield
L = java.lang.String(varargin{1});
awtinvoke(jScenarioName,'setText(Ljava.lang.String;)',L);
% initialize controller text field
L = java.lang.String(varargin{2});
awtinvoke(jControllerName,'setText(Ljava.lang.String;)',L);
% initialize controller node
this.Controller = varargin{3};
% performance function combo
if ~isempty(this.Scenario.PerformanceFunction)
    awtinvoke(jPerfFuncCombo,'setSelectedIndex(I)',this.Scenario.PerformanceFunction);
end
% tables
Controller = this.Controller.getController;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(this.Task);
OutIx = 1:NumOut;
if ~isempty(this.Task.iNO)
    OutIx(this.Task.iNO) = [];
end
InIx = sort(this.Task.iMV);
Ywts = Yweight.CellData;
Uwts = Uweight.CellData;
URwts = URweight.CellData;
for ct = 1:length(OutIx)
    Ywts{ct,1} = Controller.OutputVariables(ct).Name; 
    if ~isempty(this.Scenario.PerformanceYWeights)
        Ywts(ct,2) = this.Scenario.PerformanceYWeights(ct);
        Ywts{ct,5} = num2str(Controller.Weights.OutputVariables(1,OutIx(ct)));    
    else
        Ywts{ct,2} = num2str(Controller.Weights.OutputVariables(1,OutIx(ct)));    
        Ywts{ct,5} = Ywts{ct,2};
    end
end
for ct = 1:length(InIx)
    Uwts{ct,1} = Controller.ManipulatedVariables(ct).Name; 
    URwts{ct,1} = Controller.ManipulatedVariables(ct).Name; 
    if ~isempty(this.Scenario.PerformanceYWeights)
        Uwts(ct,2) = this.Scenario.PerformanceUWeights(ct);
        Uwts{ct,5} = num2str(Controller.Weights.ManipulatedVariables(1,ct));
    else
        Uwts{ct,2} = num2str(Controller.Weights.ManipulatedVariables(1,ct));
        Uwts{ct,5} = Uwts{ct,2};
    end
    if ~isempty(this.Scenario.PerformanceYWeights)
        URwts(ct,2) = this.Scenario.PerformanceURWeights(ct);
        URwts{ct,5} = num2str(Controller.Weights.ManipulatedVariablesRate(1,ct));
    else
        URwts{ct,2} = num2str(Controller.Weights.ManipulatedVariablesRate(1,ct));
        URwts{ct,5} = URwts{ct,2};        
    end
end
Yweight.setCellData(Ywts);
Uweight.setCellData(Uwts);
URweight.setCellData(URwts);

%% Define callbacks
set(handle(jPerfFuncCombo, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalPerfFuncCallbacks, this});
set(handle(jComputeButton, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalAdvisorCallbacks, 'Compute', this, true});
set(handle(jCompareButton, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalAdvisorCallbacks, 'Analyze', this, true});
set(handle(jModalCheckBox, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalModalCallbacks, this});
set(handle(jRestoreButton, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalRestoreCallbacks, this});
set(handle(jUpdateButton, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalUpdateCallbacks, this});
set(handle(jCloseButton, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalCloseCallbacks, this});
set(handle(jHelpButton, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCADVISOR', jDialog});
set(handle(jDialog, 'callbackproperties'),'WindowClosingCallback',...
    {@LocalCloseCallbacks, this});

this.Handles.Dialog = jDialog;
this.Handles.PerfFuncCombo = jPerfFuncCombo;
this.Handles.Yweight = Yweight;
this.Handles.Uweight = Uweight;
this.Handles.URweight = URweight;
this.Handles.OriginalPerformanceValue = jOriginalPerformanceValue;
this.Handles.NewPerformanceValue = jNewPerformanceValue;

% ------------------------------------------------------
function LocalAdvisorCallbacks(eventSource, eventData, Action, this, IsPlot) 
% Handle callbacks for constraint softening buttons

import javax.swing.*;
import java.awt.*;

%% get nodes ion design
[Scenario Controller] = LocalGetSC(this);
if isempty(Scenario) || isempty(Controller)
    return;
end

%% remove current plots if any
mpcCursor(this.Handles.Dialog, 'wait');
cacheHin = '';
cacheHout = '';
if ~isempty(Scenario.getRoot.Hin) && ishandle(Scenario.getRoot.Hin)
    cacheHin = get(Scenario.getRoot.Hin.AxesGrid.Parent,'CloseRequestFcn');
    set(Scenario.getRoot.Hin.AxesGrid.Parent,'CloseRequestFcn','');
end
if ~isempty(Scenario.getRoot.Hout) && ishandle(Scenario.getRoot.Hout)
    cacheHout = get(Scenario.getRoot.Hout.AxesGrid.Parent,'CloseRequestFcn');
    set(Scenario.getRoot.Hout.AxesGrid.Parent,'CloseRequestFcn','');
end

%% get baseline mpc
MPCobj = Controller.getController;
if isempty(MPCobj)
    mpcCursor(this.Handles.Dialog, 'default');
    return
end

%% get simulation signals (Tstop, r, d, v, etc)
Signals = Scenario.getSignalDefinitions;
if Signals.T < 2
    Message = ctrlMsgUtils.message('MPC:designtool:SimulationFailedShortDuration');
    uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    mpcCursor(this.Handles.Dialog, 'default');
    return
end

%% get performance penalties
PerformanceWeights = MPCobj.weights;
Ywts = this.Handles.Yweight.CellData;
PerformanceWeights.OutputVariables = str2double(Ywts(:,2))'; 
Uwts = this.Handles.Uweight.CellData;
PerformanceWeights.ManipulatedVariables = str2double(Uwts(:,2))'; 
URwts = this.Handles.URweight.CellData;
PerformanceWeights.ManipulatedVariablesRate = str2double(URwts(:,2))'; 

%% set simulation options
SimOpts = mpcsimopt(MPCobj);
% plant model for simalation
PlantName = Scenario.PlantName;
simModel.Plant = mpcStripNeglected(Scenario.getMPCModels.getLTImodel(PlantName), this.Task);
simModel.Nominal.U = MPCobj.Model.Nominal.U;
simModel.Nominal.Y = MPCobj.Model.Nominal.Y;
SimOpts.Model = simModel;
% Indices for model stored in the object
iMV = MPCobj.Model.Plant.InputGroup.Manipulated;
% Set simulation options
if Scenario.ConstraintsEnforced
    SimOpts.Constraints = 'on';
else
    SimOpts.Constraints = 'off';
end
% ALWAYS CLOSED LOOP
SimOpts.OpenLoop = 'off';
if Scenario.rLookAhead
    SimOpts.RefLookAhead = 'on';
else
    SimOpts.RefLookAhead = 'off';
end
if Scenario.vLookAhead
    SimOpts.MDLookAhead = 'on';
else
    SimOpts.MDLookAhead = 'off';
end
SimOpts.StatusBar = 'off';
SimOpts.UnmeasuredDisturbance = Signals.d;
SimOpts.InputNoise = Signals.Noise.U;
SimOpts.OutputNoise = Signals.Noise.Y;
if ~Scenario.ClosedLoop
    MVSignal = simModel.Nominal.U(iMV);
    SimOpts.MVSignal = MVSignal(:)';
end

%% compute sensitivity
try
    switch Action
        case 'Compute'
            % get criteria
            PerfFunc = awtinvoke(this.Handles.PerfFuncCombo,'getSelectedItem');
            % compute baseline J, sensitivity
            J = sensitivity(MPCobj, PerfFunc, PerformanceWeights, Signals.T, Signals.r, Signals.v, SimOpts);
            % populate baseline performance
            awtinvoke(this.Handles.OriginalPerformanceValue,'setText(Ljava.lang.String;',num2str(J,4));
            % plot
            if IsPlot
                [y1 t1 u1] = sim(MPCobj, Signals.T, Signals.r, Signals.v, SimOpts);
                LocalPlot('baseline', t1, y1, u1, MPCobj, [], [], [], [], this.Task.iMO, Scenario, Signals);
            end
        case 'Analyze'
            % get criteria
            PerfFunc = awtinvoke(this.Handles.PerfFuncCombo,'getSelectedItem');
            % produce baseline J if it is not computed
            if strcmp(awtinvoke(this.Handles.OriginalPerformanceValue,'getText()'),'Click "Baseline"')
                % compute baseline J, sensitivity
                J = sensitivity(MPCobj, PerfFunc, PerformanceWeights, Signals.T, Signals.r, Signals.v, SimOpts);
                % populate baseline performance
                awtinvoke(this.Handles.OriginalPerformanceValue,'setText(Ljava.lang.String;',num2str(J,4));
            end
            % get new MPC weights
            MPCobjNew = MPCobj;
            Weights = MPCobjNew.weights;
            Ywts = this.Handles.Yweight.CellData;
            Weights.OutputVariables = str2double(Ywts(:,5))'; 
            Uwts = this.Handles.Uweight.CellData;
            Weights.ManipulatedVariables = str2double(Uwts(:,5))'; 
            URwts = this.Handles.URweight.CellData;
            Weights.ManipulatedVariablesRate = str2double(URwts(:,5))'; 
            MPCobjNew.weights = Weights;
            % compute new J, sensitivity            
            [J, Sensitivity] = sensitivity(MPCobjNew, PerfFunc, PerformanceWeights, Signals.T, Signals.r, Signals.v, SimOpts);
            % populate new performance
            awtinvoke(this.Handles.NewPerformanceValue,'setText(Ljava.lang.String;',num2str(J,4));
            % plot
            if IsPlot
                [y1 t1 u1] = sim(MPCobj, Signals.T, Signals.r, Signals.v, SimOpts);
                [y2 t2 u2] = sim(MPCobjNew, Signals.T, Signals.r, Signals.v, SimOpts);
                LocalPlot('analyze', t1, y1, u1, MPCobj, t2, y2, u2, MPCobjNew, this.Task.iMO, Scenario, Signals);
            end
            %% normalization
            %         AbsValue = abs([Sensitivity.OutputVariables Sensitivity.ManipulatedVariables ...
            %             Sensitivity.ManipulatedVariablesRate Sensitivity.PredictionHorizon Sensitivity.ControlHorizon]);
            %         MaxValue = max(AbsValue);
            %         SensitivityRel.OutputVariables = sign(Sensitivity.OutputVariables).*abs(Sensitivity.OutputVariables/MaxValue);
            %         SensitivityRel.ManipulatedVariables = sign(Sensitivity.ManipulatedVariables).*abs(Sensitivity.ManipulatedVariables/MaxValue);
            %         SensitivityRel.ManipulatedVariablesRate = sign(Sensitivity.ManipulatedVariablesRate).*abs(Sensitivity.ManipulatedVariablesRate/MaxValue);
            %         SensitivityRel.PredictionHorizon = sign(Sensitivity.PredictionHorizon)*abs(Sensitivity.PredictionHorizon)/MaxValue;
            %         SensitivityRel.ControlHorizon = sign(Sensitivity.ControlHorizon)*abs(Sensitivity.ControlHorizon)/MaxValue;
            %         AbsValueRel = abs([SensitivityRel.OutputVariables SensitivityRel.ManipulatedVariables ...
            %             SensitivityRel.ManipulatedVariablesRate SensitivityRel.PredictionHorizon SensitivityRel.ControlHorizon]);
            %         AbsValueRel = sort(AbsValueRel,'descend');
            %% populate tables
            Ywts = this.Handles.Yweight.CellData;
            Uwts = this.Handles.Uweight.CellData;
            URwts = this.Handles.URweight.CellData;
            % Y
            for ct = 1:size(Ywts,1)
                Ywts{ct,3} = num2str(Sensitivity.OutputVariables(ct),4);
                Ywts{ct,4} = LocalGetTuningDirection(Sensitivity.OutputVariables(ct),str2double(Ywts(ct,5)));
                %[dummy Inx] = ismember(abs(SensitivityRel.OutputVariables(ct)),AbsValueRel);
                %Ywts{ct,4} = [LocalGetTuningDirection(SensitivityRel.OutputVariables(ct)) '(' num2str(Inx) ')'];
            end
            % U
            for ct = 1:size(Uwts,1)
                Uwts{ct,3} = num2str(Sensitivity.ManipulatedVariables(ct),4);
                Uwts{ct,4} = LocalGetTuningDirection(Sensitivity.ManipulatedVariables(ct),str2double(Uwts(ct,5)));
                %[dummy Inx] = ismember(abs(SensitivityRel.ManipulatedVariables(ct)),AbsValueRel);
                %Uwts{ct,4} = [LocalGetTuningDirection(SensitivityRel.ManipulatedVariables(ct)) '(' num2str(Inx) ')'];
            end
            % U Rate
            for ct = 1:size(URwts,1)
                URwts{ct,3} = num2str(Sensitivity.ManipulatedVariablesRate(ct),4);
                URwts{ct,4} = LocalGetTuningDirection(Sensitivity.ManipulatedVariablesRate(ct),str2double(URwts(ct,5)));
                %[dummy Inx] = ismember(abs(SensitivityRel.ManipulatedVariablesRate(ct)),AbsValueRel);
                %URwts{ct,4} = [LocalGetTuningDirection(SensitivityRel.ManipulatedVariablesRate(ct)) '(' num2str(Inx) ')'];
            end
            this.Handles.Yweight.setCellData(Ywts);
            this.Handles.Uweight.setCellData(Uwts);
            this.Handles.URweight.setCellData(URwts);
    end
catch ME
    if ~isempty(findstr(lower(ME.identifier), 'feedthrough'))
        Message = ctrlMsgUtils.message('MPC:designtool:SimulationFailedFeedThrough', Scenario.PlantName, Scenario.Label);        
    else
        Message = ctrlMsgUtils.message('MPC:designtool:SimulationFailedOther', Scenario.Label, ME.identifier, ME.message);        
    end
    uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    mpcCursor(this.Handles.Dialog, 'default');
    return
end

%% restore mouse
if ~isempty(cacheHin)
    set(Scenario.getRoot.Hin.AxesGrid.Parent,'CloseRequestFcn',cacheHin);
end
if ~isempty(cacheHout)
    set(Scenario.getRoot.Hout.AxesGrid.Parent,'CloseRequestFcn',cacheHout);
end
mpcCursor(this.Handles.Dialog, 'default');

function LocalPerfFuncCallbacks(eventSource, eventData, this) 
LocalAdvisorCallbacks([], [], 'Compute', this, false);
LocalAdvisorCallbacks([], [], 'Analyze', this, true);

function LocalModalCallbacks(eventSource, eventData, this) 
awtinvoke(this.Handles.Dialog,'setModal(Z);',eventSource.isSelected);

function LocalRestoreCallbacks(eventSource, eventData, this) 
%% get nodes ion design
[Scenario Controller] = LocalGetSC(this);
if isempty(Scenario) || isempty(Controller)
    return;
end
%% get baseline mpc
MPCobj = Controller.getController;
if isempty(MPCobj)
    return
end
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(this.Task);
OutIx = 1:NumOut;
if ~isempty(this.Task.iNO)
    OutIx(this.Task.iNO) = [];
end
Ywts = this.Handles.Yweight.CellData;
Uwts = this.Handles.Uweight.CellData;
URwts = this.Handles.URweight.CellData;
% Y
for ct = 1:size(Ywts,1)
    Ywts{ct,5} = num2str(MPCobj.Weights.OutputVariables(1,OutIx(ct)));
end
% U
for ct = 1:size(Uwts,1)
    Uwts{ct,5} = num2str(MPCobj.Weights.ManipulatedVariables(1,ct));
end
% U Rate
for ct = 1:size(URwts,1)
    URwts{ct,5} = num2str(MPCobj.Weights.ManipulatedVariablesRate(1,ct));
end
this.Handles.Yweight.setCellData(Ywts);
this.Handles.Uweight.setCellData(Uwts);
this.Handles.URweight.setCellData(URwts);
% reset new J text
L = java.lang.String('Click "Analyze"');
awtinvoke(this.Handles.NewPerformanceValue,'setText(Ljava.lang.String;)',L);

function LocalUpdateCallbacks(eventSource, eventData, this) 
%% get nodes ion design
[Scenario Controller] = LocalGetSC(this);
if isempty(Scenario) || isempty(Controller)
    return;
end
%% update the controller node
Ywts = this.Handles.Yweight.CellData;
Uwts = this.Handles.Uweight.CellData;
URwts = this.Handles.URweight.CellData;
% Y
tmp = Controller.Handles.Ywts.CellData;
for ct = 1:size(Ywts,1)
    tmp(ct,4) = Ywts(ct,5);
end
Controller.Handles.Ywts.setCellData(tmp);
% U
tmp = Controller.Handles.Uwts.CellData;
for ct = 1:size(Uwts,1)
    tmp(ct,4) = Uwts(ct,5);
    tmp(ct,5) = URwts(ct,5);
end
Controller.Handles.Uwts.setCellData(tmp);
% recompute baseline
LocalAdvisorCallbacks([], [], 'Compute', this, false);
% info
uiwait(msgbox(ctrlMsgUtils.message('MPC:designtool:AdvisorTuningUpdateSuccessfully'), ctrlMsgUtils.message('MPC:designtool:DialogTitleMessage'), 'modal'));


function LocalCloseCallbacks(eventSource, eventData, this) 
%% get selected scenario node
Scenario = this.Scenario;
if ishandle(Scenario)
    % Save window location for next time ...
    this.Scenario.AdvisorWindowLocation = this.Handles.Dialog.getLocation;
    % Save performance weights
    this.Scenario.PerformanceYWeights = this.Handles.Yweight.CellData(:,2);
    this.Scenario.PerformanceUWeights = this.Handles.Uweight.CellData(:,2);
    this.Scenario.PerformanceURWeights = this.Handles.URweight.CellData(:,2);
    this.Scenario.PerformanceFunction = this.Handles.PerfFuncCombo.getSelectedIndex;
    % close two plots
    this.task.closePlots;
end
% Close the dialog without changing the stored tables
awtinvoke(this.Handles.Dialog,'dispose');
% delete itself
delete(this.Handles.Yweight);
delete(this.Handles.Uweight);
delete(this.Handles.URweight);
delete(this)

function Direction = LocalGetTuningDirection(ValueS,ValueW)
if ValueS>0
    if ValueW==0
        Direction = 'OK';
    else
        Direction = 'Decrease';
    end
elseif ValueS<0
    Direction = 'Increase';
else
    Direction = 'OK';
end

function LocalPlot(type, t1, y1, u1, mpc1, t2, y2, u2, mpc2, iMO, Scenario, Signals)
Root = Scenario.getRoot;
if Scenario.ClosedLoop
    r = Signals.r;
else
    r = [];
end
y1(:,iMO) = y1(:,iMO) + Signals.Noise.Y;
[Root.Hout, Root.Hin] = plot(mpc1, t1, y1, r, u1, Signals.v, Signals.d, Root.Hout, Root.Hin, 'Baseline');
if strcmpi(type,'analyze')
    y2(:,iMO) = y2(:,iMO) + Signals.Noise.Y;
    [Root.Hout, Root.Hin] = plot(mpc2, t2, y2, r, u2, Signals.v, Signals.d, Root.Hout, Root.Hin, 'Current Tuning');
end
Figi = Root.Hin.AxesGrid.Parent;
Figo = Root.Hout.AxesGrid.Parent;
Axes = Root.Hin.AxesGrid.getaxes;
legend(Axes(1),'show');
Axes = Root.Hout.AxesGrid.getaxes;
legend(Axes(1),'show');
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
% make current
figure(double(Figi));
figure(double(Figo));

%% Utilities
function [Scenario Controller] = LocalGetSC(this)
%% get selected scenario node
Scenario = this.Scenario;
if ~ishandle(Scenario)
    uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:AdvisorTuningErrorScenario'), ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    Scenario = [];
    return
end
    
%% get selected controller node
Controller = this.Controller;
if ~ishandle(Controller)
    uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:AdvisorTuningErrorController'), ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    Controller = [];
    return
end
Controllers = Scenario.getMPCControllers;
ControllerInScenario = Controllers.find('Label', Scenario.Handles.ControllerCombo.getSelectedItem);
if Controller~=ControllerInScenario
    uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:AdvisorTuningErrorMismatch'), ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    Controller = [];
    return
end

function OK = weightCheckFcn(String, row, col, this) %#ok<*INUSL>
% Always accept a null string.
if isempty(String)
    OK = true;
    return
end
% Otherwise, must be non-negative
Number = LocalStr2Double(String);
if isempty(Number) || any(isnan(Number)) || any(Number<0) || length(Number)>1  || isinf(Number)
    awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
        'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
        this{1}.Handles.Yweight.Table.getRootPane, ...
        ctrlMsgUtils.message('MPC:designtool:InvalidScalarWeightValue'), ...
        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), ...
        com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
    OK = false;
else
    OK = true;
end

function Value = LocalStr2Double(String)
try
    Value = str2double(String);
    if ~isreal(Value) || length(Value) ~= 1 || ischar(Value)
        Value = NaN;
    end
catch %#ok<CTCH>
    Value = NaN;
end





