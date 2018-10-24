function RefreshModelSummary(this)
% Refresh the summary text in the MPCModels view

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.13 $ $Date: 2007/11/09 20:44:09 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

%disp('In RefreshModelSummary')

TextArea = this.Handles.TextArea;
iModel = this.Handles.UDDtable.selectedRow;
if iModel < 1 || iModel > length(this.Models)
    Text = '';
    Notes = '';
else
    Model = this.Models(iModel);
    Text = newModel( Model.Model, Model.Name);
    Notes = Model.Notes;
end
awtinvoke(TextArea,'setVisible(Z)',false);
% R.C. set the field 'treatAmpersandAsMnemonic' in MJLabel to false in
% order to display html text correctly
this.Handles.SummaryText.setText(Text,false);
this.Handles.NotesArea.setText(Notes);
awtinvoke(this.Handles.NotesArea, 'setCaretPosition(I)',0);
awtinvoke(TextArea,'setVisible(Z)',true);
% ------------------------------------------------------------------------

function Text = newModel(S,Name)

% Update the LTI model summary view based on the model, S, and the
% Struc containing its description.

% Author(s):   Larry Ricker

if isempty(S)
    Text = '';
else
    Order = [];
    switch class(S)
        case 'ss'
            Type = 'State space (ss)';
            Order = length(S.a);
        case 'tf'
            Type = 'Transfer function (tf)';
        case 'zpk'
            Type = 'Zero/Pole/Gain (zpk)';
        otherwise
            Type = 'Unknown';
    end
    if S.Ts == 0
        Sampling = ':  Continuous';
    else
        Sampling = [':  Discrete with period = ',num2str(S.Ts)];
    end
    Text = sprintf(['Model name = %s<BR>', ...
            'Type = %s<BR>','Number of inputs = %i<BR>', ...
            'Number of outputs = %i<BR>'],...
            Name,Type,length(S.InputName),...
            length(S.OutputName));
    if ~isempty(Order)
        Text = [Text, sprintf('Order = %i<BR>',Order)];
    end
    Text = [Text, sprintf('Sampling%s<BR>', Sampling)];
    if ~isempty(S.Notes)
        if iscell(S.Notes)
            for k=1:length(S.Notes)
                Text = [Text, sprintf('%s<BR>',S.Notes{k})];
            end
        elseif ischar(S.Notes)
            Text = [Text, sprintf('%s<BR>',S.Notes)];
        end  
    end
    Text = [Text, localDisplayNames(S.InputName, 'Input')];
    if isstruct(S.InputGroup)
         Text = [Text, localDisplayGroups(S.InputGroup, 'Input')];
    else
        if ~ isempty(S.InputGroup)
            m=size(S.InputGroup,1);
            Text = [Text, sprintf('Input group(s):<BR>')];
            for k=1:m
                Text = [Text, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;%s:  [%i', ...
                    S.InputGroup{k,2}, S.InputGroup{k,1}(1))];
                for j=2:length(S.InputGroup{k,1})
                    Text = [Text, sprintf(' %i',S.InputGroup{k,1}(j))];
                end
                Text = [Text, sprintf(']<BR>')];
            end
        end
    end
    Text = [Text, localDisplayNames(S.OutputName, 'Output')];
    if isstruct(S.OutputGroup)
        Text = [Text, localDisplayGroups(S.OutputGroup, 'Output')];
    else
        if ~ isempty(S.OutputGroup)
            m = size(S.OutputGroup,1);
            Text = [Text, sprintf('Output group(s):<BR>')];
            for k=1:m
                Text = [Text, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;%s:  [%i', ...
                    S.OutputGroup{k,2}, S.OutputGroup{k,1}(1))];
                for j=2:length(S.OutputGroup{k,1})
                    Text = [Text, sprintf(' %i',S.OutputGroup{k,1}(j))];
                end
                Text = [Text, sprintf(']<BR>')];
            end
        end
    end
    Text = [Text, sprintf('Maximum input delay:&nbsp;&nbsp;%i<BR>', ...
        max(S.InputDelay))];
    Text = [Text, sprintf('Maximum output delay:&nbsp;&nbsp;%i<BR>', ...
        max(S.OutputDelay))];
    Text = [Text, sprintf('Maximum i/o delay:&nbsp;&nbsp;%i<BR>', ...
        max(max(S.ioDelay)))];
end
Text = htmlText(Text);

% -------------------------------------------------------

function Text = localDisplayGroups(Group, Name)

Text = sprintf('%s group(s):<BR>', Name);
Fields = fieldnames(Group);
if isempty(Fields)
    Text = [Text, sprintf(' (none)  <BR>')];
else
    for k = 1:length(Fields)
        Channels = Group.(Fields{k});
        Text = [Text, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;%s:  [%i', ...
            Fields{k}, Channels(1))];
        for j = 2:length(Channels)
            Text = [Text, sprintf(' %i',Channels(j))];
        end
        Text = [Text, sprintf(']<BR>')];
    end
end

% -------------------------------------------------------

function txt = localDisplayNames(Names, Type)

txt = sprintf('%s name(s):<BR>', Type);
isNone = true;
for i = 1:length(Names)
    if ~isempty(Names{i})
        isNone = false;
        break
    end
end
if isNone
    txt = [txt, sprintf('&nbsp;&nbsp;(none) <BR>')];
else
    txt = [txt, sprintf('&nbsp;&nbsp;&nbsp;&nbsp;{''%s''', Names{1})];
    for i = 2:length(Names)
        txt = [txt, sprintf(', %s', Names{i})];
    end
    txt = [txt, sprintf('}<BR>')];
end
