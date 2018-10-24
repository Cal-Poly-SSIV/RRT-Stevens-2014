function [status, FRAME, WSHANDLE, MANAGER, hGUI, hProj, mpcNode] = ...
    mpc_openscm(fullblockname, option, proj)
% MPC_OPENSCM Open MPC Design Tool GUI.

%   Authors: James G. Owen
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.18 $  $Date: 2008/12/04 22:44:11 $

% Called by 'mpc_mask' for designing MPC/MMPC block from scratch

import com.mathworks.toolbox.mpc.*
status = false;
[FRAME,WSHANDLE,MANAGER,hGUI,hProj,mpcNode] = deal([]);

%% Check block name
n = max(strfind(fullblockname,'/'));
if ~isempty(n) && n>1 && n<length(fullblockname)
    model = bdroot(fullblockname);
else
    return % Invalid path
end

%% Build progress dialog
drawnow
actions = {ctrlMsgUtils.message('MPC:designtool:WizardStep1');
    ctrlMsgUtils.message('MPC:designtool:WizardStep2');
    ctrlMsgUtils.message('MPC:designtool:WizardStep3');
    ctrlMsgUtils.message('MPC:designtool:WizardStep4');
    ctrlMsgUtils.message('MPC:designtool:WizardStep5')};
progress = ProgressTable.getProgressTable(actions, ...
    ctrlMsgUtils.message('MPC:designtool:WizardTitle'),slctrlexplorer('initialize'));
progress.setHeader(ctrlMsgUtils.message('MPC:designtool:ProgressiveBarHeader'));
localsetprogress(progress,0,20,ctrlMsgUtils.message('MPC:designtool:ConfiguringSCD'),'')
awtinvoke(progress,'setVisible',true)

%% Build or get CETM GUI
% Specify the number of MVs in slmpctool call before compiling the model
% and initialize CETM
try
    if strcmp(option, 'open_by_mmpc')
        blkp = get_param(fullblockname,'Parent');
        [FRAME,WSHANDLE,MANAGER,hGUI, hProj] = slmpctool('initialize', ...
            model, proj, get_param(blkp,'Name'), fullblockname, [], progress);
    elseif mpc_nmvquest(fullblockname)
        [FRAME,WSHANDLE,MANAGER,hGUI, hProj] = slmpctool('initialize', ...
            model, proj, get_param(fullblockname,'Name'), fullblockname, [], progress);
    end
catch ME
end
if isempty(hGUI) || isempty(hProj)
    errordlg(ctrlMsgUtils.message('MPC:designtool:CreateMPCTaskFailed'),...
        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal');
    return
end

%% Assign the linearization I/O and get port widths
drawnow
[nmo, nmv, nr, nmd] = mpcportsizes(fullblockname);
[thisopspec, msg] = mpc_linoppoints(fullblockname,model,zeros(nmv,1),zeros(nmo,1),zeros(nmd,1));
if isempty(thisopspec)
    localsetprogress(progress, [], [], ctrlMsgUtils.message('MPC:designtool:CannotTrim'), msg);
    return
end

%% Search for MPC task with the model
mpcnode = hGUI;

%% Find the operating condition node and define the output constraint for
%% trim
opcondnode = mpcnode.up.find('-class', 'OperatingConditions.OperatingConditionTask');
if isempty(opcondnode)
    msg = ctrlMsgUtils.message('MPC:designtool:CannotTrimDetail1');
    localsetprogress(progress, [], [], ctrlMsgUtils.message('MPC:designtool:CannotTrim'), msg);
    hProj.removeNode(mpcnode);
    return
end

%% Set the optimization method to nonlinear least squares which seems to be
%% more robust when the trim problem is overdetermined
opt = linoptions;
if mpcchecktoolboxinstalled('optim')
    opt.OptimizerType = 'lsqnonlin';
    opt.OptimizationOptions.LargeScale='on';
end
opt.DisplayReport = 'off'; % None verbose mode

%% Trim the operating condition constraint object
try
    localsetprogress(progress,0,30,ctrlMsgUtils.message('MPC:designtool:FindingOP'),'')
    drawnow
    [thisOPPoint, thisOPReport] = findop(model,thisopspec,opt);
    mpcnode.Linearization.OPPoint = thisOPPoint;
    mpcnode.Linearization.OPReport = thisOPReport;   
catch ME
    msg = ctrlMsgUtils.message('MPC:designtool:CannotTrimDetail2');
    localsetprogress(progress, [], [], ctrlMsgUtils.message('MPC:designtool:CannotTrim'), msg);
    hProj.removeNode(mpcnode);
    return
end

%% Create a new operating condition node at the level of the op cond task
mpcnodes = mpcnode.getChildren;  
nodenames = get(mpcnodes(1).getChildren,{'Label'});
k = 1;
while any(strcmp(['MPC open loop plant ' sprintf('%d',k)],nodenames))
    k=k+1;
end
mpcopcond = OperatingConditions.OperConditionResultPanel(['MPC open loop plant ' sprintf('%d',k)]);
set(mpcopcond,'OpPoint', copy(mpcnode.Linearization.OPPoint), 'OpReport',copy(mpcnode.Linearization.OPReport));
newopptnode = opcondnode.addNode(mpcopcond);

%% Store the controller node list
MPCControlList = hGUI.getMPCControllers.find('-class','mpcnodes.MPCController');

%% Programmatically hit the "OK" button in the linearization dialog
%% based on selection of the newly added operating pt node
try
    newModelName = mpcnode.linearize(opcondnode,MANAGER,newopptnode,progress);
catch ME
    msg = ctrlMsgUtils.message('MPC:designtool:CannotLinearizeDetail');
    localsetprogress(progress,[],[], ctrlMsgUtils.message('MPC:designtool:CannotLinearize'), msg);
    hProj.removeNode(mpcnode);
    return
end

%% Report unsuccessful completion
if isempty(newModelName)
    msg = ctrlMsgUtils.message('MPC:designtool:CannotLinearizeDetail');
    localsetprogress(progress,[],[], ctrlMsgUtils.message('MPC:designtool:CannotLinearize'),msg);
    hProj.removeNode(mpcnode);
    return
end


%% Has a new MPC controller been added?
mpcNode = setdiff(hGUI.getMPCControllers.find('-class', 'mpcnodes.MPCController'), MPCControlList);
if isempty(mpcNode)
    theseNames = get(hGUI.getMPCControllers.find('-class', 'mpcnodes.MPCController'),{'Label'});
    k = 1;
    while any(strcmp(sprintf('%s%d','MPC',k),theseNames))
        k = k+1;
    end
    hGUI.getMPCControllers.addController(sprintf('%s%d','MPC',k));
    mpcNode = hGUI.getMPCControllers.find('Label',sprintf('%s%d','MPC',k));
end

%% The new (linearized) model node becomes the internal model for the new ctrl
set(mpcNode,'Model',hGUI.getMPCModels.getModel(newModelName), 'ModelName',newModelName);
mpcNode.getDialogInterface(MANAGER); % Refresh internal model

%% Rebuild MPC object which may have changed since the model may have chnaged
mpcNode.MPCObject = {};
mpcNode.getController;

localsetprogress(progress,0,100,ctrlMsgUtils.message('MPC:designtool:SuccessfulWizard'),'')
status = true;   
   
%%
function localsetprogress(progress,position,completion,status,details)

if ~isempty(progress)
    progress.setDetails(details);
    progress.setStatus(status);
    if ~isempty(completion)
        progress.setValue(completion);
    end
    if ~isempty(position)
        progress.setDone(position,1);
        progress.repaint; % Let the repaint show the ckeck marks
    end
    drawnow
end
