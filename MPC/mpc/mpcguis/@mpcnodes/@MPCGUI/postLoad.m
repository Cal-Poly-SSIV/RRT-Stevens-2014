function postLoad(this, manager)
%  POSTLOAD Restore gui state after load

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.7 $ $Date: 2008/05/31 23:21:47 $

%% If the task belongs to a Simulink project open the Simulink model
if ~isempty(this.Block)
    I = strfind(this.Block,'/');
    try
        if ~isempty(I)
            thismodel = this.Block(1:I(1)-1);
        else
            thismodel = this.Block;      
        end
        open_system(thismodel);
    catch ME
        localAbort(this, manager)
        return
    end
end

% Force creation of the MPCGUI dialog panel
this.getDialogInterface(manager);
manager.Explorer.setSelected(this.getTreeNodeInterface);
this.TreeManager = manager;
this.Frame = manager.Explorer;
% Also wake up the MPCModels, MPCControllers, and MPCSims nodes
if this.ModelImported
    MPCModels = this.getMPCModels;
    MPCModels.getDialogInterface(manager);
    MPCControllers = this.getMPCControllers;
    MPCControllers.getDialogInterface(manager);
    MPCSims = this.getMPCSims;
    MPCSims.getDialogInterface(manager);
end

% If this is a Simulink task build the connection between the right block
% and the newly loaded task
if ~isempty(this.Block)
%     mpcobj = MPCControllers.getController(MPCControllers.CurrentController);
%     % MPC GUI needs to have the mpc object used by the block in the
%     % workspace. If a var of that name is there already check that its ok
%     % to overwrite
%     if any(strcmp(MPCControllers.CurrentController,evalin('base','who'))) 
%         msg = ctrlMsgUtils.message('MPC:designtool:LoadingOverwriteMPC',MPCControllers.CurrentController);
%         ButtonOverWrite = questdlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'),'Yes','No','Yes');
%         if strcmp(ButtonOverWrite,'No')
%              localAbort(this, manager)
%              return
%         end
%     end
%     % Overwrite
%     assignin('base',MPCControllers.CurrentController,mpcobj);
    if strcmp(get_param(this.Block,'MaskType'),'MPC')    
        % Update mask info
        try
            mpc_mask('load',thismodel,'',this.Block,this.Label);  
        catch ME
            msg = ctrlMsgUtils.message('MPC:designtool:LoadingMismatchMPC');
            errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
            return
        end
    else
        % Update mask info
        try
            mpc_mask_multiple('load',thismodel,'',this.Block,this.Label);
        catch ME
            msg = ctrlMsgUtils.message('MPC:designtool:LoadingMismatchMPC');
            errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
            return
        end
    end
end

% Set Dirty flag to false (in case it hasn't been done automatically).
this.Dirty = false;


function localAbort(this,manager)
msg = ctrlMsgUtils.message('MPC:designtool:LoadingSLNotOpen',this.Block);
awtinvoke(manager.Explorer,'postText(Ljava.lang.String;)',msg);
this.up.removeNode(this);
