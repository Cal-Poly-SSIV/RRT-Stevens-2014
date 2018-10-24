function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE  Define pointer to dialog panel
 
%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.8 $ $Date: 2008/01/29 15:35:11 $


Root = this.getRoot;

% Inform dialogs of current selection
Root.setDialogHandles;

if ~Root.ModelImported
    Msg = ctrlMsgUtils.message('MPC:designtool:ModelImportFirst',this.Label);        
    helpdlg(Msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleHelp'));
    panel = LocalAbnormalCompletion(this, manager);
    return
end

% Verify that structure signal
% specifications have not been altered after controller design has
% begun.
if Root.SpecsChanged
    % Specs have been changed.  Perform checks.
    [ErrMsg, TypesChanged, ControllerDesigned, Resetting] = LocalCheckSignals(this);
    if isempty(ErrMsg)
        % No error
        MPCModels = this.getMPCModels;
        for i = 1:length(MPCModels.Models)
            MPCModels.setModelSignalTypes(MPCModels.Models(i));
        end
        Root.SpecsChanged = false;   % Toggle flag
        if TypesChanged && ControllerDesigned
            if Resetting
                % User has requested overwrite of current settings
                Root.Reset = true;
                panel = LocalAbnormalCompletion(this, manager);
            else
                % Continue with existing settings
                panel = LocalNormalCompletion(this, manager);
            end
        else
            % Either types not changed or controller not designed yet
            panel = LocalNormalCompletion(this, manager);
        end
    else
        % Error in specs.  Return to root and display error message.
        panel = LocalAbnormalCompletion(this, manager);
        % Displays an error message
        set(0,'ShowHiddenHandles','on');
        H = findobj('Name','MPC Error');
        set(0,'ShowHiddenHandles','off');
        if ~isempty(H)
            delete(H)
        end
        errordlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal');
    end
else
    % Specs have not been changed, so no need to check them
    panel = LocalNormalCompletion(this, manager);
end

% ------------------------------------------------------------------------

function panel = LocalNormalCompletion(this, manager)
% Call the node's getDialogSchema method
Root = this.getRoot;
Root.InData = Root.InUDD.CellData;
Root.OutData = Root.OutUDD.CellData;
this.Dialog = this.getDialogSchema(manager);
panel = this.Dialog;
EnabledState = ~isempty(Root.getMPCSims.CurrentScenario);
if isfield(Root.Handles,'SimulateMenu')  % Might not be created yet
    awtinvoke(Root.Handles.SimulateMenu.getAction, 'setEnabled(Z)', EnabledState);
end

% ------------------------------------------------------------------------

function panel = LocalAbnormalCompletion(this, manager)

% Force a return to the root node.

Root = this.getRoot;
Root.TreeManager.Explorer.setSelected(Root.getTreeNodeInterface);
if ~Root.ModelImported
    Root.TreeManager.Explorer.collapseNode(Root.TreeNode);
end
panel = Root.Dialog;

% ------------------------------------------------------------------------

function [ErrorMsg, TypesChanged, ControllerDesigned, Resetting] = ...
    LocalCheckSignals(this)

% User has selected a node below the root.  Make sure that current MPC
% structure (signal type choices) are OK.

MPCControllers = this.getMPCControllers;
Root = this.getRoot;
Model = Root.getMPCModels.Models(1).Model;

% Load latest structure data from tables on root panel
NewIn = Root.InUDD.CellData;
NewOut = Root.OutUDD.CellData;

% Has a controller or scenario panel been initialized?
ControllerDesigned = LocalCheckPanels(MPCControllers);
if ~ControllerDesigned
    ControllerDesigned = LocalCheckPanels(this.getMPCSims);
end

ErrorMsg = '';
TypesChanged = false;
Resetting = false;

% Check the structure.
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(Root);
InIDs = {[], [], [], []};
InType = cell(1,3);
InType{1} = char(Root.Handles.InTypeCombo.getItemAt(0));
InType{2} = char(Root.Handles.InTypeCombo.getItemAt(1));
InType{3} = char(Root.Handles.InTypeCombo.getItemAt(2));
for i = 1:NumIn
    NewType = NewIn{i,2};
    if ~strcmp(Root.InData{i,2},NewType)
        TypesChanged = true;
    end
    if strcmp(NewType, InType{1})
        InIDs{1} = [InIDs{1}, i];
    elseif strcmp(NewType, InType{2})
        InIDs{2} = [InIDs{2}, i];
    elseif strcmp(NewType, InType{3})
        InIDs{3} = [InIDs{3}, i];
    else
        InIDs{4} = [InIDs{4}, i];
    end
end
OutIDs = {[], [], []};
OutType = cell(1,2);
OutType{1} = char(Root.Handles.OutTypeCombo.getItemAt(0));
OutType{2} = char(Root.Handles.OutTypeCombo.getItemAt(1));
for i = 1:NumOut
    NewType = NewOut{i,2};
    if ~strcmp(Root.OutData{i,2}, NewType)
        TypesChanged = true;
    end
    if strcmp(NewType, OutType{1})
        OutIDs{1} = [OutIDs{1}, i];
    elseif strcmp(NewType, OutType{2})
        OutIDs{2} = [OutIDs{2}, i];
    else
        OutIDs{3} = [OutIDs{3}, i];
    end
end

% Make sure there's at least one MV in proposed structure
Message = ctrlMsgUtils.message('MPC:designtool:ModelOneMVOneMO');        
if length(InIDs{1}) <= 0
    ErrorMsg = Message;
else
    InputGroup = struct('MV',InIDs{1});
end
if ~isempty(InIDs{2})
    InputGroup.MD = InIDs{2};
end
if ~isempty(InIDs{3})
    InputGroup.UD = InIDs{3};
end
if ~isempty(InIDs{4})
    InputGroup.NI = InIDs{4};
end
% Make sure there's at least one MO
if length(OutIDs{1}) <= 0
    ErrorMsg = Message;
else
    OutputGroup = struct('MO',OutIDs{1});
end
if ~isempty(OutIDs{2})
    OutputGroup.UO = OutIDs{2};
end
if ~isempty(OutIDs{3})
    OutputGroup.NO = OutIDs{3};
end
% Make sure signal names aren't duplicated.
Duplicates = LocalFindDuplicates(NewIn(:,1));
if ~isempty(Duplicates)
    ErrorMsg = ctrlMsgUtils.message('MPC:designtool:ModelDuplicateMV',Duplicates);        
end
Duplicates = LocalFindDuplicates(NewOut(:,1));
if ~isempty(Duplicates)
    ErrorMsg = ctrlMsgUtils.message('MPC:designtool:ModelDuplicateMO',Duplicates);            
end

if isempty(ErrorMsg)
    set(Model,'InputGroup',InputGroup,'OutputGroup',OutputGroup);
    if ControllerDesigned
        % A controller has been designed.  If structure has been changed,  
        % we must resolve the conflict.
        if TypesChanged
            Message1 = ctrlMsgUtils.message('MPC:designtool:SignalTypeOverwrite1');            
            Message2 = ctrlMsgUtils.message('MPC:designtool:SignalTypeOverwrite2');            
            Message3 = ctrlMsgUtils.message('MPC:designtool:SignalTypeOverwrite3');            
            Message = sprintf('%s\n\n%s\n\n%s',Message1,Message2,Message3);
            Answer = questdlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), ...
                'Overwrite', 'Cancel changes', 'Cancel changes');
            if strcmp(Answer, 'Overwrite')
                % Accept the new definitions and flag that previous must
                % be erased.
                Resetting = true;
                DefineStructureTables(Root, Model, NewIn, NewOut);
            else
                % Restore previous values
                Root.InUDD.setCellData(Root.InData);
                Root.OutUDD.setCellData(Root.OutData);
            end
        end
    else
        % A controller hasn't been designed.  OK to save the modified
        % structure and return.
        if TypesChanged
            DefineStructureTables(Root, Model, NewIn, NewOut);
        end
    end
end

% ========================================================================

function Duplicates = LocalFindDuplicates(List)
% Find duplicate entries in a cell array of strings
N = length(List);
if N == 1
    Duplicates = [];
    return
end
Dupes = {};
for i = 1:N
    if ~isempty(List{i})
        ix = find(strcmp({List{i}},List));
        if length(ix) > 1 && i == ix(1)
            Dupes{end+1} = List{i};
        end
    end
end
N = length(Dupes);
if N > 0
    Duplicates = [];
    for i = 1:N
        Duplicates = [Duplicates, sprintf('"%s"  ',Dupes{i})];
    end
else
    Duplicates = [];
end

% ------------------------------------------------------------------------

function PanelInitialized = LocalCheckPanels(Parent)

% Check to see whether dialog panels have been initialized.
PanelInitialized = false;
List = Parent.getChildren;
for i = 1:length(List)
    if ~isempty(List(i).Dialog)
        PanelInitialized = true;
    end
end
