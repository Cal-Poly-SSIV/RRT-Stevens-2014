function deleteSelectedModel(this, Model)
% Delete the selected model

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2008/12/04 22:44:02 $

Num = length(this.Models);
if Num > 1
    this.Models = this.Models(~ismember(this.Models,Model));

    % Repair any controllers or scenarios that referred to this model
    NewName = this.Models(1).Name;
    Controllers = this.getMPCControllers.getChildren;
    UsedInC = Controllers.find('ModelName', Model.Name);
    Scenarios = this.getMPCSims.getChildren;
    UsedInS = Scenarios.find('PlantName', Model.Name);
    NameChanged = false;
    if ~isempty(UsedInC)
        for i = 1:length(UsedInC)
            UsedInC(i).ModelName = NewName;
            UsedInC(i).Model = this.Models(1);
        end
        NameChanged = true;
    end
    if ~isempty(UsedInS)
        for i = 1:length(UsedInS)
            UsedInS(i).PlantName = NewName;
        end
        NameChanged = true;
    end
    if NameChanged
        Message1 = ctrlMsgUtils.message('MPC:designtool:ModelNameChanged1',Model.Name);        
        Message2 = ctrlMsgUtils.message('MPC:designtool:ModelNameChanged2',Model.Name,NewName);        
        Message = sprintf('%s\n\n%s',Message1,Message2);        
        warndlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'),'modal');
    end

else
    Root = this.up;
    Message1 = ctrlMsgUtils.message('MPC:designtool:ModelDeleteQuestion1',Model.Name,Root.Label);        
    Message2 = ctrlMsgUtils.message('MPC:designtool:ModelDeleteQuestion2');        
    Message3 = ctrlMsgUtils.message('MPC:designtool:ModelDeleteQuestion3',Model.Name);        
    Question = sprintf('%s\n\n%s\n\n%s',Message1,Message2,Message3);
    ButtonName=questdlg(Question, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'Yes', 'No', 'No');
    if strcmp(ButtonName,'No')
        return
    end
    Root.clearTool;
end
    
%% Update the list
this.RefreshModelList;

% If this model is the result of linearization, delete the corresponding
% node. Don't worry abound the node deletion listener ping-ponging because
% the model will be gone from the table when the node deletion listener
% fires
ModelNodes = this.getChildren;
I = find(strcmp(Model.Name,get(ModelNodes,{'Label'})));
if ~isempty(I)
    this.removeNode(ModelNodes(I(1)));
end
