function deleteController(this, Controller)
% DELETECONTROLLER Delete controller having Label as Controller

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.9 $ $Date: 2007/11/09 20:42:58 $

UDDtable = this.Handles.UDDtable;
[rows, cols]=size(UDDtable.CellData);
if rows == 1
    msg1 = ctrlMsgUtils.message('MPC:designtool:DeleteOnlyController1');
    msg2 = ctrlMsgUtils.message('MPC:designtool:DeleteOnlyController2');
    msg = sprintf('%s\n\n%s',msg1,msg2);
    uiwait(errordlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    return
end

Question = ctrlMsgUtils.message('MPC:designtool:DeleteControllerQuestion',Controller);
ButtonName=questdlg(Question,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'),'Yes', 'No', 'No');
if strcmp(ButtonName,'Yes')
    % Delete the selected controller
    MPCControllerNode = this.getChildren.find('Label', Controller);
    this.removeNode(MPCControllerNode);
    this.RefreshControllerList;
    % Modify any scenarios that were referencing this controller
    Scenarios = this.getMPCSims.getChildren;
    UsedIn = Scenarios.find('ControllerName',Controller);
    NewName = this.Controllers{1};
    if ~isempty(UsedIn)
        for i = 1:length(UsedIn)
            UsedIn(i).ControllerName = NewName;
        end
        msg1 = ctrlMsgUtils.message('MPC:designtool:DeleteControllerWarning1',Controller);
        msg2 = ctrlMsgUtils.message('MPC:designtool:DeleteControllerWarning2',Controller,NewName);
        msg = sprintf('%s\n\n%s',msg1,msg2);
        uiwait(warndlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal'));
    end
    % Select "Controllers" node to prevent user from interacting with
    % panel of deleted controller.
    this.getRoot.TreeManager.Explorer.setSelected(this.getTreeNodeInterface);
end
