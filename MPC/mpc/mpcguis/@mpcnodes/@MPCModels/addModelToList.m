function Done = addModelToList(this, Struc, LTImodel)
% ADDMODELTOLIST Adds a model to the list of imported models

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.14 $ $Date: 2007/11/09 20:44:12 $

% "this" is the MPCModels node
S = this.up;
Done = false;

% Extract the imported model's name and LTI object.
Name=Struc.name;
Model=LTImodel;
% Make sure model meets minimum standards ...
Nin = length(Model.InputName);
Nout = length(Model.OutputName);
% Don't allow import of model containing duplicate signal names
InDupes = LocalFindDuplicates(Model.InputName, Name, 'input', this);
OutDupes = LocalFindDuplicates(Model.OutputName, Name, 'output', this);
if InDupes || OutDupes
    return
end

if Nin < 1 || Nout < 1
    Message = ctrlMsgUtils.message('MPC:designtool:ModelImportFailedSize',Name, Nin, Nout);        
    uiwait(errordlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
    return
end
if ~isreal(LTImodel)
    Message = ctrlMsgUtils.message('MPC:designtool:ModelImportFailedComplex',Name);        
    uiwait(errordlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
    return
end
if length(size(LTImodel)) > 2
    Message = ctrlMsgUtils.message('MPC:designtool:ModelImportFailedArray',Name);        
    uiwait(errordlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
    return
end
try
    % Convert to state space if possible
    Model = ss(Model);
catch ME
    Message = ctrlMsgUtils.message('MPC:designtool:ModelImportFailedSS',Name);        
    uiwait(errordlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
    return
end

% If this is the second model to be loaded, check for compatibility
% with the defined model structure.
if length(this.Models) >= 1
    % Check number of inputs and outputs
    if any([Nin Nout] ~= S.Sizes(6:7))
        Msg1 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionOverload1',Name,Nin,Nout,S.Sizes(6:7));                
        Msg2 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionOverload2',Name);                
        Msg3 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionOverload3',S.Label);                
        Msg = sprintf('%s\n\n%s\n\n%s',Msg1,Msg2,Msg3);
        ButtonName = questdlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'Yes', 'No', 'No');
        if strcmp(ButtonName,'Yes')
            S.clearTool;
            Done = LocalAddModel(this, Name, Model, S);
            if Done
                % Warn if D is non-zero for MVs
                LocalCheckD(S, Model, Name);
            end
        end
        return
    end
    % Check whether or not signal names match.
    Conflict = false; 
    for i = 1:Nin
        if ~isempty(Model.InputName{i})
            if ~strcmp(Model.InputName{i}, S.InData{i,1})
                Conflict = true;
            end
        end
    end
    for i = 1:Nout
        if ~isempty(Model.OutputName{i})
            if ~strcmp(Model.OutputName{i}, S.OutData{i,1})
                Conflict = true;
            end
        end
    end
    if Conflict
        Msg1 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionName1',Name);                        
        Msg2 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionName2',Name);                        
        Msg = sprintf('%s\n\n%s',Msg1,Msg2);
        uiwait(warndlg(Msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'),'modal'));        
    end
    % Check whether or not I/O groups match
    if iscell(Model.InputGroup)
        InputGroup = Model.InputGroup;
        ngrp = size(Model.InputGroup, 1);
    else
        [InputGroup, ngrp] = localStruct2Cell(Model.InputGroup);
    end
    [MVList, MDList, UDList, NIList] = LocalGetLists(InputGroup, ngrp);
    for i = 1:ngrp
        Type = lower(InputGroup{i,2});
        switch Type
            case MVList
                Conflict = LocalChkGrp(InputGroup{i,1}, S.iMV);
            case MDList
                Conflict = LocalChkGrp(InputGroup{i,1}, S.iMD);
            case UDList
                Conflict = LocalChkGrp(InputGroup{i,1}, S.iUD);
            case NIList
                Conflict = LocalChkGrp(InputGroup{i,1}, S.iNI);
            otherwise
                Conflict = true;
        end
        if Conflict
            Msg1 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionGroup1',Name,'Input');                        
            Msg2 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionGroup2',Name);                        
            Msg = sprintf('%s\n\n%s',Msg1,Msg2);
            uiwait(warndlg(Msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'),'modal'));        
            break
        end
    end
    if iscell(Model.OutputGroup)
        OutputGroup = Model.OutputGroup;
        ngrp = size(Model.OutputGroup,1);
    else
        [OutputGroup, ngrp] = localStruct2Cell(Model.OutputGroup);
    end
    MOlist = lower({'MeasuredOutputs', 'MO', 'Measured', 'Output'});
    UOlist = lower({'UnmeasuredOutputs', 'UO', 'Unmeasured'});
    NOlist = lower({'NeglectedOutputs', 'IgnoredOutputs', 'NO', ...
        'Neglected', 'Ignored', 'IO'});
    for i = 1:ngrp
        Type = lower(OutputGroup{i,2});
        switch Type
            case MOlist
                Conflict = LocalChkGrp(OutputGroup{i,1}, S.iMO);
            case UOlist
                Conflict = LocalChkGrp(OutputGroup{i,1}, S.iUO);
            case NOlist
                Conflict = LocalChkGrp(OutputGroup{i,1}, S.iNO);
            otherwise
                Conflict = true;
        end
        if Conflict
            Msg1 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionGroup1',Name,'Output');                        
            Msg2 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionGroup2',Name);                        
            Msg = sprintf('%s\n\n%s',Msg1,Msg2);
            uiwait(warndlg(Msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'),'modal'));        
            break
        end
    end
end
Done = LocalAddModel(this, Name, Model, S);
if Done
    % Warn if D is non-zero for MVs
    LocalCheckD(S, Model, Name);
end

% ========================================================================

function LocalCheckD(S, Model, Name)

% focus on mv and mo only
D = Model.D(S.iMO,S.iMV);
% check if there is direct feed-through from any mv to any measured output
List = '';
for i = 1:size(D,1)
    for j = 1:size(D,2)
        if D(i,j) && Model.OutputDelay(S.iMO(i))==0 && ...
                Model.InputDelay(S.iMV(j))==0 && Model.IODelay(S.iMO(i),S.iMV(j))==0
            % if D(i,j) conains non-zero element and no i/o delay is
            % present, add i-j pair to the list.
            if isempty(List)
                List = [S.InData{j,1} ' and ', S.OutData{i,1}];                
            else
                List = [List, ', ', S.InData{j,1} ' and ', S.OutData{i,1}];
            end
        end
    end
end
% display warning message
if ~isempty(List)
    Msg1 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionFeedtrought1',Name);                        
    Msg2 = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionFeedtrought2');                        
    Msg = sprintf('%s\n\n%s\n\n%s',Msg1,List,Msg2);
    uiwait(warndlg(Msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'),'modal'));        
end


% ========================================================================

function Done = LocalAddModel(this, Name, Model, S)
Replacing = false;
Done = this.addModel(Name, Model, 0);
if ~Done
    % A model with this name already exists.  Ask if the user
    % wants to replace it.
    Msg = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionModelExist',Name);                            
    ButtonName=questdlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'No');
    if strcmp(ButtonName, 'Yes')
        Done = this.addModel(Name, Model, 1);
        Replacing = true;
    else
        Done = false;
    end
end
if Done
    S.ModelImported = 1;
    if isempty(this.Dialog)
        % Force creation of MPCModels dialog panel
        this.getDialogInterface(S.TreeManager);
    end
    if length(this.Models) == 1 && ~Replacing
        DefineStructureTables(S, Model);
    end
    this.setModelSignalTypes(this.getModel(Name));
    this.RefreshModelList;
end

% ========================================================================

function [CellGroup, ngrp] = localStruct2Cell(StructGroup)

Fields = fieldnames(StructGroup);
ngrp = length(Fields);
CellGroup = cell(ngrp,2);
for i = 1:ngrp
    CellGroup{i,2} = Fields{i};
    CellGroup{i,1} = StructGroup.(Fields{i});
end

% ========================================================================

function Conflict = LocalChkGrp(Grp1, Grp2)

Grp1 = Grp1(:);
Grp2 = Grp2(:);
Conflict = false;
if length(Grp1) ~= length(Grp2)
    Conflict = true;
elseif ~isempty(Grp1)
    if any(Grp1 ~= Grp2)
        Conflict = true;
    end
end

% ========================================================================

function [MVList, MDList, UDList, NIList] = LocalGetLists(InputGroup, ngrp)
% Sets lists depending on whether or not the LTI model follows SysID
% InputGroup convention.
if ngrp == 2 && strcmp(InputGroup{2,2}, 'Noise')
    % This is the SysID convention
    MVList = lower({'Measured'});
    MDList = lower({'MeasuredDisturbances', 'MD'});
    UDList = lower({'Noise'});
else
    % This is the mpctools convention
    MVList = lower({'ManipulatedVariables', 'MV', 'Manipulated', 'Input'});
    MDList = lower({'MeasuredDisturbances', 'MD', 'Measured'});
    UDList = lower({'UnmeasuredDisturbances', 'UD', 'Unmeasured', ...
        'UnmeasuredInput'});
end
NIList = lower({'Neglected', 'NI', 'Ignored', 'II', 'NeglectedInput', ...
    'IgnoredInput'});

% ========================================================================

function IsDupe = LocalFindDuplicates(List, Name, Type, this)
% Find duplicate entries in a cell array of strings
N = length(List);
if N == 1
    IsDupe = false;
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
    IsDupe = true;
    strList = [];
    for i = 1:N
        strList = [strList, sprintf('"%s" ',Dupes{i})];
    end
    mpcupdatecetmtext(this.getRoot, ctrlMsgUtils.message('MPC:designtool:DuplicatedEntry', Type, strList));
    Message = ctrlMsgUtils.message('MPC:designtool:ModelImportQuestionModelDuplicate',Name,Type);                            
    uiwait(errordlg(sprintf('%s\n%s',Message,strList), ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'modal'));
else
    IsDupe = false;
end

