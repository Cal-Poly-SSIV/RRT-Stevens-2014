function newNodeName = linearize(mpcnode, opcondtask, M, constrSrcNode, varargin)
% Callback for the "OK" button in the linearization import dialog
% Also used by the MPC mask to build a linearized plant model from scratch
% If constrSrcNode is empty the mpcnode i/o table is used to supply i/o
% constrained values. 

% Author: A. Bemporad
% Copyright 1990-2007 The MathWorks, Inc.
% $Revision: 1.1.6.19 $  $Date: 2008/05/31 23:21:46 $

%% Set verbosity off
verbose = warning('query','mpc:verbosity');
mpcverbosity('off')

%% Initialization
thisExplorer = M.Explorer;
if nargin<=4
    progress = [];
else
    progress = varargin{1};
end
newNodeName = '';

%% Set the optimization method to nonlinear least squares which seems to be
%% more robust when the trim problem is overdetermined
opt = linoptions;
if mpcchecktoolboxinstalled('optim')
    opt.OptimizerType = 'lsqnonlin';
    opt.OptimizationOptions.LargeScale='on';    
end
opt.DisplayReport = 'off'; % None verbose mode
localsetprogress(thisExplorer,progress, 1, 40, ctrlMsgUtils.message('MPC:designtool:WizardInfoLinearPoint'),'')

%% Obtain linearization i/o points from MPC block MV/MD/MO ports
try
    if strcmp(get_param(mpcnode.Block,'MaskType'),'MPC')
        mpcblockiotable(mpcnode.Block,opcondtask.Model,mpcnode.Linearization);
    else
        mpcblockiotable_multiple(mpcnode.Block,opcondtask.Model,mpcnode.Linearization);
    end
catch ME
    msg = sprintf('%s %s',ctrlMsgUtils.message('MPC:designtool:WizardInfoLinearFailed'),ME.message);
    errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
    mpcverbosity(verbose.state)
    return
end

%% Grab new name string
newname = char(mpcnode.linearization.LinearizationDialog.nameTxt.getText);
localsetprogress(thisExplorer,progress,2,60,ctrlMsgUtils.message('MPC:designtool:WizardInfoTrim'),'');

%% Create new operating point and report using nominal values in the MPCGUI
%% table and linearize the model on top of it (if) or linearize the model
%% with an existing operating condition node (else)  
if isempty(constrSrcNode)

    %% Assign output constraints to nominal table values
    newOpSpecData = mpcnode.getNominal;

    %%  If no opspec object was created the getNominal failed
    if isempty(newOpSpecData)
        msg = sprintf('%s',ctrlMsgUtils.message('MPC:designtool:FailedOPFromNominal'));
        errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
        mpcverbosity(verbose.state)
        return
    end
   
    %% Trim the model. In cases where there is sufficient integral action in
    %% the controller, the resulting op cond will also be valid for the closed
    %% loop system but there will be one less non-linearity in the loop and
    %% better optimization performance. 
    newOpSpecData.update;
    [mpcnode.Linearization.OPPoint,mpcnode.Linearization.OPReport] = ...
        findop(opcondtask.Model,newOpSpecData,opt);    
    
    %% Create a new operating condition node at the level of the op cond task
    newopcondnode = OperatingConditions.OperConditionResultPanel(newname);
    set(newopcondnode,'OpPoint', copy(mpcnode.Linearization.OPPoint),...
        'OpReport',mpcnode.Linearization.OPReport);
    opcondtask.addNode(newopcondnode);
    
    %% Linearize model and create linearized model node
    node = LinearizeModel(mpcnode.Linearization,opcondtask.Options);
    
else
 
    %% First, assume the oppt agrees with the current model
    try 
        mpcnode.Linearization.OPPoint = constrSrcNode.OpPoint.update(1);
        if isa(constrSrcNode,'OperatingConditions.OperConditionResultPanel')        
            thisoprep = constrSrcNode.OpReport;
        end
    %% If this fails tell the user to rebuild the op pt
    catch ME 
        msg = ctrlMsgUtils.message('MPC:designtool:WizardInfoSLStateUpdated');
        if isempty(progress)
            msgbox(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleMessage'),'modal')
        end
        localsetprogress(thisExplorer,progress,3,80,ctrlMsgUtils.message('MPC:designtool:WizardInfoLinearizeFailed'),msg);
        mpcverbosity(verbose.state)
        return
    end

    %% Cannot use an OperCondValuePanel node to export nominal conditions since
    %% there is no available opreport.  
    if isa(constrSrcNode,'OperatingConditions.OperConditionResultPanel')
        mpcnode.Linearization.OPReport = thisoprep; %constrSrcNode.OpReport;
    elseif ~mpcnode.linearization.LinearizationDialog.overwriteNominalChk.isSelected
        mpcnode.Linearization.OPReport = [];
    else
        msg = ctrlMsgUtils.message('MPC:designtool:WizardInfoBadOp');        
        errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
        mpcverbosity(verbose.state)
        return
    end
     
    %% Linearize model and create linearized model node
    node = LinearizeModel(mpcnode.Linearization,opcondtask.Options);
end
localsetprogress(thisExplorer,progress,3,80,ctrlMsgUtils.message('MPC:designtool:WizardInfoLinearizing'),'');

%% Check linearized model and create linearized model node
node.Label = newname;
obs = obsv(node.LinearizedModel);
if rank(obs)<size(node.LinearizedModel,'order')
    node.LinearizedModel = sminreal(node.LinearizedModel);
end

%% Set MD signal
if ~isempty(mpcnode.Linearization.MDIndex)
    node.LinearizedModel = setmpcsignals(node.LinearizedModel, ...
        'MV', 1:mpcnode.Linearization.MDIndex(1)-1,...
        'MD', mpcnode.Linearization.MDIndex);
end
localsetprogress(thisExplorer,progress,4,100,ctrlMsgUtils.message('MPC:designtool:WizardInfoAddingModel'),'');

%% Add linearization result to MPC project
mpcnodes = mpcnode.getChildren;  
mpcnodes(1).addModelToList(struct('name',node.Label),node.LinearizedModel);
mpcnodes(1).addNode(node);
newNodeName = node.Label;

%% Add a listeners which keep the @MPCControllers summary table
%% synchronized with the model table if a node is deleted/renamed
node.addListeners(handle.listener(node,'ObjectParentChanged',...
    {@localDeleteModel mpcnode.getMPCModels}));
node.addListeners(handle.listener(node,node.findprop('Label'),'PropertyPreSet',...
    {@localRenameModel mpcnode.getMPCModels}));

%% Turn off the selector panel
thisExplorer.setSelected(node.getTreeNodeInterface) 
% Linearization node must be selected for getSelectorPanel to work 
node.getDialogInterface.getSelectorPanel.setVisible(false);
node.customizeView(M);

%% Update the default linearization name text field
nodenames = get(mpcnodes(1).getChildren,{'Label'});
k = 1;
while any(strcmp(['MPC open loop plant ' sprintf('%d',k)],nodenames))
    k=k+1;
end
mpcnode.linearization.LinearizationDialog.nameTxt.setText( ...
    ['MPC open loop plant ' sprintf('%d',k)]);

%% Make sure we are in the right state
if ~strcmp(get_param(opcondtask.Model, 'SimulationStatus'),'stopped')
    feval(opcondtask.Model,[],[],[],'term')
end
    
%% Reset verbosity 
mpcverbosity(verbose.state)


function localsetprogress(explorer, progress, position, completion, status, details)

if ~isempty(progress) && ishandle(progress)
    progress.setDetails(details); % Clear details
    progress.setStatus(status);
    progress.setValue(completion);
    progress.setDone(position,1);
    drawnow % Let the repaint show the check marks
end
if nargin>=6 && ~isempty(details) && ishandle(explorer)
   awtinvoke(explorer,'postText(Ljava.lang.String;)',details);
end

function localDeleteModel(eventSrc, eventData, modelsnode)

% Listener callback when a linearized result node is deleted

I = find(strcmp(eventSrc.Label,get(modelsnode.Models,{'Name'})));
if ~isempty(I)
    modelsnode.deleteSelectedModel(modelsnode.Models(I(1)));
end

function localRenameModel(eventSrc, eventData, modelsnode)

% Listener callback which updates the model list when a model
% node name is changed
thisModel = modelsnode.getModel(eventData.AffectedObject.Label);
I = find(ismember(modelsnode.Models,thisModel));
if ~isempty(I)
    modelsnode.renameModel(eventData.NewValue,I(1));
end
if ~isempty(thisModel)
    thisModel.Name = eventData.NewValue;
    thisModel.Label = eventData.NewValue;
end

