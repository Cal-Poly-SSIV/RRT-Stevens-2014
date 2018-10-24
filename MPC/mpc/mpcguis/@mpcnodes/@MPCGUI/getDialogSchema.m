function DialogPanel = getDialogSchema(this, manager)
%  GETDIALOGSCHEMA  Construct the dialog panel

%  Author:  Larry Ricker
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.21 $ $Date: 2008/10/31 06:21:28 $

persistent Importer mpcImporter mpcExporter
%persistent Importer mpcImporter

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Define common dialogs if they haven't been created already.  
% In any case, save handles in this object for later reference

if ~isa(Importer, 'mpcobjects.importlti')
    Importer = mpcobjects.importlti({'ss', 'tf', 'zpk', 'idpoly', ...
        'idss', 'idarx', 'idgrey', 'idproc'});
end
this.Handles.ImportLTI = Importer;

if ~isa(mpcImporter, 'mpcobjects.importlti')
    mpcImporter = mpcobjects.importlti({'mpc'});
end
this.Handles.ImportMPC = mpcImporter;

if ~isa(mpcExporter, 'mpcobjects.mpcExporter')
    mpcExporter = mpcobjects.mpcExporter;
end
this.Handles.mpcExporter = mpcExporter;
%this.Handles.mpcExporter = mpcobjects.mpcExporter;

if isempty(this.Dialog)
    
    % Main graphic
    PanelSize = Dimension(560, 160);
    GraphPanel = MJLayeredPane;
    GraphPanel.setPreferredSize(PanelSize);
    GraphPanel.setBorder(BorderFactory.createLoweredBevelBorder);

    StructureImage = ImageIcon(which('MPC_structure.gif'));
    StructureLabel = MJLabel(StructureImage);
    StructureLabel.setSize(PanelSize);

    NumberX = [148 152 148, 440*[1 1], 300 515];
    NumberY = [ 56 17 100   115 20  75 74];
    NumberPanel = MJPanel;
    NumberPanel.setSize(PanelSize);
    NumberPanel.setOpaque(false);
    NumberPanel.setLayout([]);
    NumFont = Font('Dialog', Font.PLAIN, 18);
    Numbers = [];
    for i = 1:7
        Num = java.lang.String(int2str(this.Sizes(i)));
        Numbers = [Numbers; MJLabel(Num)]; %#ok<AGROW>
        NumberPanel.add(Numbers(i));
        Numbers(i).setBounds(NumberX(i), NumberY(i), 35, 25);
        Numbers(i).setFont(NumFont);
    end

    GraphPanel.add(StructureLabel);
    GraphPanel.add(NumberPanel);
    GraphPanel.moveToFront(NumberPanel);
    
    % Signal tables.
    javaClass = true(1,5);
    ColNames = {'Name','Type','Description','Units','Nominal'};
    isEditable = [true true true true true];
    Tin=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
        this.InData, @InOutCheckFcn);
    Tout=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
        this.OutData, @InOutCheckFcn);
    Tin.Table = MPCTable(Tin, ColNames, isEditable', ...
        this.InData', javaClass);
    Tin.Table.setName('MPCGUI_Tin');
    Tout.Table = MPCTable(Tout, ColNames, isEditable', ...
        this.OutData', javaClass);
    Tout.Table.setName('MPCGUI_Tout');
    InTypeCombo = MJComboBox;
    InTypeCombo.setEditable(0);
    InTypeCombo.addItem('Manipulated');
    InTypeCombo.addItem('Meas. disturb.');
    InTypeCombo.addItem('Unmeas. disturb.');
    InTypeCombo.addItem('Neglected');
    OutTypeCombo = MJComboBox;
    OutTypeCombo.setEditable(0);
    OutTypeCombo.addItem('Measured');
    OutTypeCombo.addItem('Unmeasured');
    OutTypeCombo.addItem('Neglected');

    ViewportSize = [550 100];
    ColumnSizes = [80 100 150 100 70];
    ResizePolicy = '';
    Tin.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
    Col3 = Tin.Table.getColumnModel.getColumn(1);
    Col3.setCellEditor(DefaultCellEditor(InTypeCombo));
    Tout.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
    Col3 = Tout.Table.getColumnModel.getColumn(1);
    Col3.setCellEditor(DefaultCellEditor(OutTypeCombo));
    
    % Buttons
    HelpButton = MJButton('Help');
    HelpButton.setName('MPCGUI_Help');
    ImportButton = MJButton('Import Plant ...');
    ImportButton.setName('MPCGUI_ImportPlant');
    MPCButton = MJButton('Import Controller ...');
    MPCButton.setName('MPCGUI_ImportController');
  
    % Diagram panel
    Pimage = MJPanel(GridBagLayout);
    c = GridBagConstraints;
    c.gridx = 0;
    c.gridy = GridBagConstraints.RELATIVE;
    c.weightx = 1;
    c.weighty = 1;
    
    % Wrap the GraphPanel in a ScrollPane so that if the treeview panel is 
    % resized the graphic will still display (within scroll bars)
    GraphScrollPanel = MJScrollPane(GraphPanel);
    GraphScrollPanel.setBorder(EmptyBorder(0,0,0,0));
    %GraphScrollPanel.setPreferredSize(Dimension(560, 170));
    GraphScrollPanel.setMinimumSize(Dimension(560, 170));
    Pimage.add(GraphScrollPanel, c);
    ImportPanel=MJPanel;
    ImportPanel.add(ImportButton);
    ImportPanel.add(MPCButton);
    ImportPanel.add(HelpButton);
    Pimage.add(ImportPanel, c);
    TitleImage = TitledBorder(' MPC structure overview ');
    TitleImage.setTitleFont(Font('Dialog',Font.PLAIN,12));
    Pimage.setBorder(TitleImage);
    Pimage.setMinimumSize(Dimension(585, 225));
    
    % Input panel
    Pin = MJPanel(GridBagLayout);
    TitleIn = TitledBorder(' Input signal properties ');
    TitleIn.setTitleFont(Font('Dialog',Font.PLAIN,12));
    Pin.setBorder(TitleIn);
    c.gridy = 0;
    c.weighty = 1;
    c.fill = GridBagConstraints.BOTH;
    Pin.add(MJScrollPane(Tin.Table), c);
    
    % Output panel
    Pout = MJPanel(GridBagLayout);
    TitleOut = TitledBorder(' Output signal properties ');
    TitleOut.setTitleFont(Font('Dialog',Font.PLAIN,12));
    Pout.setBorder(TitleOut);
    Pout.add(MJScrollPane(Tout.Table), c);
        
    % Dialog panel assembly
    DialogPanel = MJPanel(GridBagLayout);
    c.gridy = GridBagConstraints.RELATIVE;
    c.weighty = 0;
    c.fill = GridBagConstraints.HORIZONTAL;
    c.insets = Insets(5, 0, 5, 0);
    DialogPanel.add(Pimage, c);
    c.weighty = 0.5;
    c.fill = GridBagConstraints.BOTH;
    DialogPanel.add(Pin, c);
    DialogPanel.add(Pout, c);

    % Create linearization dialog for current Simulink model
    % TO DO: Disable this if the parent node is not a Simulink 
    % project node
    %addLinearizationDialog(this)
    h=this.Handles;
    
    % Save the dialog panel handles
    this.InUDD = Tin;
    this.OutUDD = Tout;
    h.HelpButton = HelpButton;
    h.ImportButton = ImportButton;
    h.MPCButton = MPCButton;
    h.Numbers = Numbers;
    h.GraphPanel = GraphPanel;
    h.Pimage = Pimage;
    h.InTypeCombo = InTypeCombo;
    h.OutTypeCombo = OutTypeCombo;
    
    % Save handles
    this.Handles=h;
    this.TreeManager = manager;
    
    % Define callbacks
    set(handle(ImportButton,'callbackproperties'), ...    
        'ActionPerformedCallback',{@LocalImportCB, this});
    set(handle(MPCButton,'callbackproperties'), ...    
        'ActionPerformedCallback',{@LocalImportMPCCB, this});
    set(handle(HelpButton,'callbackproperties'), ...
        'ActionPerformedCallback', {@mpcCSHelp, 'MPCGUIMAIN'});

    % Listen for changes in the tabular data
    this.addListeners(handle.listener(this.InUDD, ...
        this.InUDD.findprop('CellData'), ...
        'PropertyPostSet',{@LocalDataListener, this}));
    this.addListeners(handle.listener(this.OutUDD, ...
        this.OutUDD.findprop('CellData'), ...
        'PropertyPostSet',{@LocalDataListener, this}));
    this.addListeners(handle.listener(this, this.findprop('InData'), ...
        'PropertyPostSet',{@LocalIOdataListener, this}));
    this.addListeners(handle.listener(this, this.findprop('OutData'), ...
        'PropertyPostSet',{@LocalIOdataListener, this}));

    % Add listener to update explorer.Project 'Dirty" property if
    % this.Dirty changes
    if isa(this.up,'explorer.Project')
        this.addListeners(handle.listener(this,this.findprop('Dirty'),...
            'PropertyPostSet', {@localUpdateProjectNode, this}));
    end
            
    %Listen for model to be imported
    MPCModels = this.getMPCModels;
    this.addListeners(handle.listener(MPCModels, ...
        MPCModels.findprop('Models'), 'PropertyPostSet', ...
        {@ControllerActivationListener, this}));
    
     %Listen for root node being destroyed
%     this.addListeners(handle.listener(this, this, ...
%         'ObjectParentChanged', {@LocalRootClosing, this}));
       
    % If necessary add linearization panel
    if isempty(this.Linearization) && ~isempty(this.Block)
        this.addLinearizationDialog(manager) 
    end
else
    % Restore the existing dialog panel
    DialogPanel = this.Dialog;
end

%-------------------------------------------------------

function LocalIOdataListener(EventSrc, EventData, this) %#ok<*INUSL>

% When the input/output tabular data change we need to make
% sure all controller nodes contain the most recent stuff.
% Their listeners might not be activated (because the user
% hasn't clicked on them yet), so we need to do it here.

Controllers = this.getMPCControllers.getChildren;
for i = 1:length(Controllers)
    Controllers(i).setIOdata(this);
    Controllers(i).HasUpdated = true;
end

%-------------------------------------------------------

function LocalDataListener(EventSrc, EventData, this)

% Comes here when tabular data has been edited.
import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

% Set update flag to force signal checking.
this.SpecsChanged = true;
this.Dirty = 1;

% Update signal count on display
Sizes = zeros(1,7);
InData = this.InUDD.CellData;
Rows = size(InData,1);
Sizes(6) = Rows;
for i=1:Rows
    switch InData{i,2}
        case 'Manipulated'
            Sizes(1) = Sizes(1) + 1;
        case 'Meas. disturb.'
            Sizes(2) = Sizes(2) + 1;
        case 'Unmeas. disturb.'
            Sizes(3) = Sizes(3) + 1;
            Value = LocalEvalIn(InData{i,5});
            if isnan(Value) || Value~=0
                this.InUDD.Table.setValueAt(java.lang.String('0.0'), i-1, 4);
            end            
        case 'Neglected'
            Sizes(6) = Sizes(6) - 1;
    end
end
OutData = this.OutUDD.CellData;
Rows = size(OutData,1);
Sizes(7) = Rows;
for i=1:Rows
    switch OutData{i,2}
        case 'Measured'
            Sizes(4) = Sizes(4) + 1;
        case 'Unmeasured'
            Sizes(5) = Sizes(5) + 1;
        case 'Neglected'
            Sizes(7) = Sizes(7) - 1;
    end
end

Numbers = this.Handles.Numbers;
for i = 1:7
    Num = java.lang.String(int2str(Sizes(i)));
    awtinvoke(Numbers(i),'setText(Ljava.lang.String;)',Num);
end

% Make sure nominal input and output field is current is .InData and
% .OutData
if ~isempty(this.InUDD.CellData) && ...
        size(this.InUDD.CellData,1) == size(this.InData,1)
    this.InData(:,5) = this.InUDD.CellData(:,5);
end
if ~isempty(this.OutUDD.CellData) && ...
        size(this.OutUDD.CellData,1) == size(this.OutData,1)
    this.OutData(:,5) = this.OutUDD.CellData(:,5);
end

%-------------------------------------------------------

function LocalImportCB(EventSrc, EventData, this)

% Open the model import dialog
I = this.Handles.ImportLTI;
I.javasend('Show' ,'dummy');

%-------------------------------------------------------

function LocalImportMPCCB(EventSrc, EventData, this)

% Open the controller import dialog

I = this.Handles.ImportMPC;
I.javasend('Show','dummy');

%-------------------------------------------------------

function [OK Value] = InOutCheckFcn(String, row, col)

Value = String;
if col == 5
    % Any finite number is OK
    Value = LocalEvalIn(String);
    if isempty(Value) || any(isnan(Value))
        OK = 0;
    elseif length(Value) > 1 || abs(Value) == Inf || ~isreal(Value)
        OK = 0;
    else
        OK = 1;
    end
    if OK
        Value = num2str(Value);
    end
else
    OK = 1;
end
if ~OK
    Message = ctrlMsgUtils.message('MPC:designtool:InvalidNominalValue');
    uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
end


% -------------------------------------------------------------

function Value = LocalEvalIn(String)

try
    Value = evalin('base', String);
catch %#ok<*CTCH>
    Value = NaN;
end
% -------------------------------------------------------------

function ControllerActivationListener(Src, Event, this)

% Listener to enable/disable the MPCControllers and MPCSims
% nodes.  It is activated by a change in the number of imported models,
% i.e., when a model has been added or deleted.

% If this is the first model imported, activate the MPCControllers
% and MPCSims nodes.  This creates "empty" nodes -- they must be
% initialized later by user action.  This allows user to change
% structure data (signal types) prior to committing to a particular
% structure.

MPCModels = this.getMPCModels;
MPCControllers = this.getMPCControllers;
MPCSims = this.getMPCSims;
if ~isempty(MPCModels.Models)

    Name = MPCModels.Models(1).Name;
    % Define default nodes if not already present
    Controllers = MPCControllers.getChildren;
    if length(MPCControllers.getChildren) <= 0
        % Possible that an empty mpc object has been loaded.
        % If so, use its name as the controller name.
        if isempty(this.MPCObject)
            ControllerName = 'MPC1';
        else
            ControllerName = this.MPCObject{1,2};
        end
        MPCControllers.addNode(mpcnodes.MPCController(ControllerName));
        MPCControllers.Controllers = {ControllerName};
        Controller = MPCControllers.getChildren;
        Controller.ModelName = Name;
        Controller.Model = MPCModels.Models(1);
        Controller.setIOdata(this);
    else
        ControllerName = Controllers(1).Label;
    end
    if length(MPCSims.getChildren) <= 0
        MPCSims.addNode(mpcnodes.MPCSim('Scenario1'));
        Sim = MPCSims.getChildren;
        Sim.PlantName = Name;
        Sim.ControllerName = ControllerName;
    end
    this.TreeManager.Explorer.expandNode(this.TreeNode);
end

% ------------------------------------------------------------------------

function localUpdateProjectNode(es,ed,this)

% Listener callback to update explorer.Node 'Dirty' property if this.Dirty
% changes. This must work unidirectionally so as not to overwrite
% explorer.Project changes made by other tasks
if this.Dirty
   this.up.Dirty = true;
end

% ------------------------------------------------------------------------

% function LocalRootClosing(EventSource, EventData, this)
% % Clean up when the gui is closing or a project/task is being deleted.
% if ishandle(this.Handles.ImportLTI)
%     this.Handles.ImportLTI.javasend('Hide','');
% end
% if ishandle(this.Handles.ImportMPC)
%     this.Handles.ImportMPC.javasend('Hide','');
% end
% if ishandle(this.Handles.mpcExporter)
%     this.Handles.mpcExporter.hide;
% end
% this.closePlots;
% if isempty(EventData.NewParent)
%     if ishandle(this.Handles.ImportLTI)
%         delete(this.Handles.ImportLTI);
%     end
%     if ishandle(this.Handles.ImportMPC)
%         delete(this.Handles.ImportMPC);
%     end
%     if ishandle(this.Handles.mpcExporter)
%         delete(this.Handles.mpcExporter);
%     end
% end
