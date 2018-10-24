function DialogPanel = getDialogSchema(this,manager)
%  Construct the MPCModels dialog panel

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.14 $ $Date: 2007/11/09 20:44:15 $

import javax.swing.*;
import java.awt.*;

S = this.up;
mpcCursor(S.Frame, 'wait');

if isempty(this.Dialog)
    % Create the panel
	DialogPanel = LocalDialogPanel(this);
else
    % Display the existing panel.
     %disp('MPCModels:  displaying existing dialog panel');
     DialogPanel = this.Dialog;
end
% Make sure model list is current
this.RefreshModelList;
mpcCursor(S.Frame, 'default');

% --------------------------------------------------------------------------- %
function DialogPanel = LocalDialogPanel(this)

% Generate the MPCModels panel

import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Create the model list table
javaClass = true(1,4);
Header = {'Name','Type', htmlText('Sampling<BR>Period'), 'Imported on'};
Data = {'','','',''};
Enabled = [ true false false false ];
t=mpcobjects.TableObject(Header, Enabled, javaClass, Data, ...
    @LocalTableCheckFcn, this);
t.Table = com.mathworks.toolbox.mpc.MPCTable(t, Header, Enabled', ...
    Data', javaClass);

UTitle = ' Plant models imported for this project ';
LTitle = ' Model details ';
NTitle = ' Additional notes ';
SummaryText = MJLabel;
LContent = MJScrollPane(SummaryText);
LContent.setViewportBorder(BorderFactory.createLoweredBevelBorder);

Width = 500;
[DialogPanel, Buttons, NotesArea] = ComponentListPanel( Width, ...
    UTitle, LTitle, NTitle, t, {'Import ...', 'Delete', 'Help'}, ...
    {'Add','Delete','Help'}, LContent, 'MPCModels');

ViewportSize=[Width, 100];
ColumnSizes=[160, 30, 40, 170];
ResizePolicy = '';
t.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);

% Callbacks
set(handle(Buttons.Add,'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalAddButtonCB, this});
set(handle(Buttons.Delete, 'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalDeleteButtonCB, this});
set(handle(Buttons.Help, 'callbackproperties'), ...
    'ActionPerformedCallback', {@mpcCSHelp, 'MPCMODELSMAIN'});
set(handle(NotesArea,'callbackproperties'), ...
    'FocusLostCallback',{@LocalNotesCB, this});

% This listens for a model to be selected.
this.addListeners(handle.listener(t, t.findprop('selectedRow'), ...
    'PropertyPostSet', {@LocalModelSummaryCB, this}));

% Save the handles
Handles.Buttons = Buttons;
Handles.UDDtable = t;
Handles.SummaryText = SummaryText;
Handles.TextArea = LContent;
Handles.NotesArea = NotesArea;

Handles.PopupMenuItems = [];

this.Handles = Handles;

% --------------------------------------------------------------

function LocalModelSummaryCB(eventSrc, eventData, this)
this.RefreshModelSummary;

% --------------------------------------------------------------

function OK = LocalTableCheckFcn(String, row, col, Args)

OK = true;
if col == 1
    % User is renaming model.  String contains proposed
    % new name.  
    % Check for emptiness
    if isempty(String)
        OK = false;
        return
    end        
    % Check for uniqueness
    this = Args{1};
    if this.isNameUnique(String, row)
        this.renameModel(String, row);
    else
        Message = ctrlMsgUtils.message('MPC:designtool:ModelNameDuplicate',String);        
        uiwait(errordlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
        OK = false;
    end
end

% --------------------------------------------------------------

function LocalNotesCB(eventSrc, eventData, this)

UDDtable = this.Handles.UDDtable;
row = UDDtable.selectedRow;
Model = this.Models(row);
Model.Notes = char(this.Handles.NotesArea.getText);
LTIobj = Model.Model;
LTIobj.Notes = {Model.Notes};
Model.Model = LTIobj;

% --------------------------------------------------------------------------- %

function LocalAddButtonCB(eventSrc, eventData, this)

% React to user push of Add button on MPCModels panel.
% Find import dialog object (on parent node) and open it.

%disp('In AddButton')
mpc=this.up;
I = mpc.Handles.ImportLTI;
I.javasend('Show' ,'dummy');

% --------------------------------------------------------------------------- %

function LocalDeleteButtonCB(eventSrc, eventData, this)

UDDtable = this.Handles.UDDtable;
row = UDDtable.selectedRow;
Model = this.Models(row);
this.deleteSelectedModel(Model);


