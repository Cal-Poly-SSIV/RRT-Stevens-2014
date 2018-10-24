function DefineStructureTables(S, Model,InData,OutData)
% Fill in structure tables using defaults as needed.

%	Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.9 $  $Date: 2007/11/09 20:42:05 $

NumIn = length(Model.InputName);
NumOut = length(Model.OutputName);
S.Sizes(1, 6:7) = [NumIn, NumOut];

[InNames, InTypes] = setInputCharacteristics(S, Model);
[OutNames, OutTypes] = setOutputCharacteristics(S, Model);

if nargin < 3
    InData = cell(NumIn, 5);
    for i = 1:NumIn
        InData(i,:) = {InNames{i}, InTypes{i}, '', '', '0.0'};
    end
    OutData = cell(NumOut, 5);
    for i = 1:NumOut
        OutData(i,:) = {OutNames{i}, OutTypes{i}, '', '', '0.0'};
    end
end

% Need to hide, make change, then make visible in order for changes to
% appear.
awtinvoke(S.InUDD.Table, 'setVisible(Z)', false);
awtinvoke(S.OutUDD.Table, 'setVisible(Z)', false);
S.InUDD.setCellData(InData);
S.OutUDD.setCellData(OutData);
awtinvoke(S.InUDD.Table, 'setVisible(Z)', true);
awtinvoke(S.OutUDD.Table, 'setVisible(Z)', true);

% Initialize InData & OutData properties
S.InData = InData;
S.OutData = OutData;

% --------------------------------------------------------------------

function [InNames, InTypes] = setInputCharacteristics(S, Model)

% Set input characteristics based on information in Model.  If not set
% there, use default setting.

iMD = [];
iUD = [];
iNI = [];
NumIn = S.Sizes(6);
InTypes = cell(1,NumIn);
InTypes(1,:) = {'Manipulated'};
if iscell(Model.InputGroup)
    InputGroup = Model.InputGroup;
    ngrp = size(Model.InputGroup, 1);
else
    [InputGroup, ngrp] = localStruct2Cell(Model.InputGroup);
end
[MVList, MDList, UDList, NIList] = LocalGetLists(InputGroup, ngrp);
iDup = zeros(1, NumIn);
iChk = zeros(1, NumIn);
for i = 1:ngrp
    Type = InputGroup{i,2};
    iSig = InputGroup{i,1};
    [iDup, iChk] = LocalMultipleAssignments(iSig, iDup, iChk);
    switch lower(Type)
        case MVList
        case MDList
            iMD = [iMD, iSig];
        case UDList
            iUD = [iUD, iSig];
        case NIList
            iNI = [iNI, iSig];
        otherwise
            Msg = ctrlMsgUtils.message('MPC:designtool:UnrecognizedInputGroup', Type, Type);        
            uiwait(warndlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal'));
    end
end
if ~isempty(iMD)
    InTypes(1,iMD) = {'Meas. disturb.'};
end
if ~isempty(iUD)
    InTypes(1,iUD) = {'Unmeas. disturb.'};
end
if ~isempty(iNI)
    InTypes(1,iNI) = {'Neglected'};
end

S.iMV = [];
S.iMD = [];
S.iUD = [];
S.iNI = [];
for i = 1:NumIn
    % Input signal names
    if ~isempty(Model.InputName{i})
        InNames{i} = Model.InputName{i};
    else 
        InNames{i} = sprintf('In%i',i); 
    end
    % Assign types again.  This approach avoids assigning a
    % signal to more than one type.
    Type = InTypes{i};
    switch Type
        case 'Unmeas. disturb.'
            S.iUD = [S.iUD, i];
        case 'Meas. disturb.'
            S.iMD = [S.iMD, i];
        case 'Neglected'
            S.iNI = [S.iNI, i];
        otherwise
            S.iMV = [S.iMV, i];
    end
end
ix = find(iDup);
if ~isempty(ix)
    Msg = ctrlMsgUtils.message('MPC:designtool:MultipleSignal',InNames{ix});        
    uiwait(warndlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal'));
end
if length(S.iMV) <= 0
    S.iMV = 1:NumIn;
    InTypes(1,:) = {'Manipulated'};
    S.iMD = [];
    S.iUD = [];
    S.iNI = [];
    Msg = ctrlMsgUtils.message('MPC:designtool:NoMVinPlantModel');        
    uiwait(warndlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal'));
end

S.Sizes(1,1:3) = [length(S.iMV), length(S.iMD), length(S.iUD)];

% --------------------------------------------------------------------

function [OutNames, OutTypes] = setOutputCharacteristics(S, Model)

% Set output characteristics based on information in Model.  If not set
% there, use default setting.

iUO = [];
iNO = [];
NumOut = S.Sizes(7);
OutTypes = cell(1,NumOut);
OutTypes(1,:) = {'Measured'};
if iscell(Model.OutputGroup)
    OutputGroup = Model.OutputGroup;
    ngrp = size(Model.OutputGroup,1);
else
    [OutputGroup, ngrp] = localStruct2Cell(Model.OutputGroup);
end
MOlist = lower({'MeasuredOutputs', 'MO', 'Measured', 'Output'});
UOlist = lower({'UnmeasuredOutputs', 'UO', 'Unmeasured'});
NOlist = lower({'NeglectedOutputs', 'IgnoredOutputs', 'NO', 'Neglected', ...
    'Ignored', 'IO'});
iDup = zeros(1, NumOut);
iChk = zeros(1, NumOut);
for i = 1:ngrp
    Type = OutputGroup{i,2};
    iSig = OutputGroup{i,1};
    [iDup, iChk] = LocalMultipleAssignments(iSig, iDup, iChk);
    switch lower(Type)
        case MOlist
        case UOlist
            iUO = [iUO, iSig];
        case NOlist
            iNO = [iNO, iSig];
        otherwise
            Msg = ctrlMsgUtils.message('MPC:designtool:UnrecognizedOutputGroup',Type, Type);        
            uiwait(warndlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal'));
    end
end
if ~isempty(iUO)
    OutTypes(1,iUO) = {'Unmeasured'};
end
if ~isempty(iNO)
    OutTypes(1,iNO) = {'Neglected'};
end

S.iMO = [];
S.iUO = [];
S.iNO = [];
for i = 1:NumOut
    % Output signal names
    if ~isempty(Model.OutputName{i})
        OutNames{i} = Model.OutputName{i};
    else 
        OutNames{i} = sprintf('Out%i',i); 
    end
    % Reassign signals.  This approach avoids assigning a
    % signal to more than one type.
    Type = OutTypes{i};
    switch Type
        case 'Unmeasured'
            S.iUO = [S.iUO, i];
        case 'Neglected'
            S.iNO = [S.iNO, i];
        otherwise
            S.iMO = [S.iMO, i];
    end
end
ix = find(iDup);
if ~isempty(ix)
    Msg = ctrlMsgUtils.message('MPC:designtool:MultipleSignal',OutNames{ix});        
    uiwait(warndlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal'));
end
if length(S.iMO) <= 0
    S.iMO = 1:NumOut;
    OutTypes(1,:) = {'Measured'};
    S.iUO = [];
    S.iNO = [];
    Msg = ctrlMsgUtils.message('MPC:designtool:NoMOinPlantModel');        
    uiwait(warndlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal'));
end
S.Sizes(1,4:5) = [length(S.iMO), length(S.iUO)];

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

function [iDup, iChk] = LocalMultipleAssignments(iSig, iDup0, iChk0)
iDup = iDup0;
iChk = iChk0;
for i = 1:length(iSig)
    j = iSig(i);
    if iChk(j)
        iDup(j) = 1;
    end
    iChk(j) = 1;
end
