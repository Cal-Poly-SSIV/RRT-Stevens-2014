function deleteScenario(this, Item)
% DELETESCENARIO Delete the scenario specified by Label == Item

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.8 $ $Date: 2007/11/09 20:44:55 $

% "this" is the MPCSims node
UDDtable = this.Handles.UDDtable;
[rows, cols]=size(UDDtable.CellData);
if rows == 1
    msg1 = ctrlMsgUtils.message('MPC:designtool:DeleteOnlyScenario1');
    msg2 = ctrlMsgUtils.message('MPC:designtool:DeleteOnlyScenario2');
    msg = sprintf('%s\n\n%s',msg1,msg2);
    uiwait(errordlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    return
end

Question = ctrlMsgUtils.message('MPC:designtool:DeleteScenarioQuestion',Item);
ButtonName=questdlg(Question,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'),'Yes', 'No', 'No');
if strcmp(ButtonName,'Yes')
    % Delete the selected scenario
    MPCSimNode = this.getChildren.find('Label',Item);
    this.removeNode(MPCSimNode);
    this.RefreshSimList;
    % Select "Scenarios" node to prevent user from interacting with
    % panel of deleted scenario.
    this.getRoot.TreeManager.Explorer.setSelected(this.getTreeNodeInterface);
end
