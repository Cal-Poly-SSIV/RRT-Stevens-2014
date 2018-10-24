function [op, msg] = mpc_linoppoints(blockname, modelname, MV, MO, MD)
% MPC_LINOPPOINTS

% Author(s): James G. Owen
% Revised:
%   Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.8 $  $Date: 2008/05/31 23:21:59 $

% Create an operating spec object for an MPC block based on the o/i
% constraints defnined by the third and forth arguments

blkp = get_param(blockname,'Parent');
try
    get_param(blkp,'Nmpc');
    is_multiple = true;
catch ME
    is_multiple = false;
end

%% Check that MV and MO ports are connected
op = [];
msg = '';
if is_multiple
    defaultMVportNumber = 4;
    defaultTotalLimitNumber = 4;
    % 1: switch, 2: mo, 3: sp, 4: md_inport (optional), 5: mv_inport (optional), 6 7 8 9:
    % umin, umax, ymin, ymax (optional) 
    portcon = get_param(blkp, 'PortConnectivity');
    % check if optional inports are connected
    mdportactive = double(strcmp(get_param(blkp,'md_inport_multiple'),'on'));
    mvportactive = double(strcmp(get_param(blkp,'mv_inport_multiple'),'on'));
    limitportactive = double(strcmp(get_param(blkp,'lims_inport_multiple'),'on'));
    % check if 'mo' inport and 'mv' outport are connected
    if isequal(portcon(2).SrcBlock,-1) 
        msg = ctrlMsgUtils.message('MPC:designtool:InvalidMVMOConnection');
    elseif isempty(portcon(defaultMVportNumber + mdportactive + mvportactive + limitportactive * defaultTotalLimitNumber).DstBlock)
        msg = ctrlMsgUtils.message('MPC:designtool:InvalidMVMOConnection');
    elseif ~isempty(MD) && isequal(portcon(4).SrcBlock,-1) 
        msg = ctrlMsgUtils.message('MPC:designtool:InvalidMVMOConnection');
    else
        %% create a new operating point
        op = operspec(modelname);

        %% Get the operating conditions and identify the ports feeding the MOs
        mosrc = getfullname(portcon(2).SrcBlock);
        if ~isempty(MD)
            mdsrc = getfullname(portcon(4).SrcBlock);    
        end

        %% Remove any existing constraints already attached to the MO or MV
        op.Outputs(strcmp(blkp,get(op.Outputs,{'Block'}))) = [];
        op.Outputs(strcmp(mosrc,get(op.Outputs,{'Block'}))) = [];
        if ~isempty(MD)
            op.Outputs(strcmp(mdsrc,get(op.Outputs,{'Block'}))) = [];
        end

        %% Add output constraints for MO and MV
        op = addoutputspec(op,blkp,1);
        op = addoutputspec(op,mosrc,portcon(2).SrcPort+1); %SrcPort C->M conversion
        if ~isempty(MD)
            op = addoutputspec(op,mdsrc,portcon(4).SrcPort+1); %SrcPort C->M conversion
        end

        %% Assign constaint values to newly created constraint objects
        for k=1:length(op.Outputs)
            if strcmp(op.Outputs(k).Block, blkp)
                set(op.Outputs(k),'Known',true*ones(size(MV)),'y',MV,'Description','MV');
            end
            if  strcmp(op.Outputs(k).Block, mosrc)
                set(op.Outputs(k),'Known',true*ones(size(MO)),'y',MO,'Description','MO');
            end
            if  ~isempty(MD) && strcmp(op.Outputs(k).Block, mdsrc)
                set(op.Outputs(k),'Known',true*ones(size(MD)),'y',MD,'Description','MD');
            end
        end
    end
else
    defaultMVportNumber = 3;
    defaultTotalLimitNumber = 4;
    % 1: mo, 2: sp, 3: md_inport (optional), 4: mv_inport (optional), 5 6 7 8:
    % umin, umax, ymin, ymax (optional), 9: switch
    portcon = get_param(blockname, 'PortConnectivity');
    % check if optional inports are connected
    mdportactive = double(strcmp(get_param(blockname,'md_inport'),'on'));
    mvportactive = double(strcmp(get_param(blockname,'mv_inport'),'on'));
    limitportactive = double(strcmp(get_param(blockname,'lims_inport'),'on'));
    switchportactive = double(strcmp(get_param(blockname,'switch_inport'),'on'));
    % check if 'mo' inport and 'mv' outport are connected
    if isequal(portcon(1).SrcBlock,-1) 
        msg = ctrlMsgUtils.message('MPC:designtool:InvalidMVMOConnection');
    elseif isempty(portcon(defaultMVportNumber + mdportactive + mvportactive + limitportactive * defaultTotalLimitNumber + switchportactive).DstBlock)
        msg = ctrlMsgUtils.message('MPC:designtool:InvalidMVMOConnection');
    elseif ~isempty(MD) && isequal(portcon(3).SrcBlock,-1) 
        msg = ctrlMsgUtils.message('MPC:designtool:InvalidMVMOConnection');
    else
        %% create a new operating point
        op = operspec(modelname);

        %% Get the operating conditions and identify the ports feeding the MOs
        mosrc = getfullname(portcon(1).SrcBlock);
        if ~isempty(MD)
            mdsrc = getfullname(portcon(3).SrcBlock);    
        end

        %% Remove any existing constraints already attached to the MO or MV
        op.Outputs(strcmp(blockname,get(op.Outputs,{'Block'}))) = [];
        op.Outputs(strcmp(mosrc,get(op.Outputs,{'Block'}))) = [];
        if ~isempty(MD)
            op.Outputs(strcmp(mdsrc,get(op.Outputs,{'Block'}))) = [];
        end

        %% Add output constraints for MO and MV
        op = addoutputspec(op,blockname,1);
        op = addoutputspec(op,mosrc,portcon(1).SrcPort+1); %SrcPort C->M conversion
        if ~isempty(MD)
            op = addoutputspec(op,mdsrc,portcon(3).SrcPort+1); %SrcPort C->M conversion
        end

        %% Assign constaint values to newly created constraint objects
        for k=1:length(op.Outputs)
            if strcmp(op.Outputs(k).Block, blockname)
                set(op.Outputs(k),'Known',true*ones(size(MV)),'y',MV,'Description','MV');
            end
            if  strcmp(op.Outputs(k).Block, mosrc)
                set(op.Outputs(k),'Known',true*ones(size(MO)),'y',MO,'Description','MO');
            end
            if  ~isempty(MD) && strcmp(op.Outputs(k).Block, mdsrc)
                set(op.Outputs(k),'Known',true*ones(size(MD)),'y',MD,'Description','MD');
            end
        end
    end
end