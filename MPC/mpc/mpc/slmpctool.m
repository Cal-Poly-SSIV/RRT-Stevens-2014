function [hJava, hUDD, M, h, project] = slmpctool(varargin)
% SLMPCTOOL starts mpctool from Simulink

% Author(s): James G. Owen
% Revised: Rong Chen
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.10.21 $ $Date: 2008/12/04 22:43:54 $

% varargin{1} is action: 'initialize' is the only choice
% varargin{2} is the name of an open Simulink model
% varargin{3} is an existing project handle
% varargin{4} is the name of the mpc/mmpc block, which becomes the default label for the mpc task node
% varargin{5} is the full path/name of the mpc/mmpc mpc block
% varargin{6} is a cell array of MPC objects and names to load and design existing @mpc objects or MPC/MMPC block
% varargin{7} is a handle to a waitbar or the java progress dialog

% Known calling syntaxes
%
% mpctool (design MPC from MATLAB)
% -------
%   [Frame, MPC_WSh, MPC_MANh, h, Project] = ...
%   slmpctool('initialize', '', [], TaskName, '', MPCobjects, wb);
%
% mpc_mask (design with existing @mpc object for MPC/MMPC)
% --------
% for GUI not open
%   [hRoot, hWS, hTree, hGUI, hProj] = ...
%   slmpctool('initialize', blksystem, [], task_name, fullblockname, {mpcobj, mpcobjname}, wb);
%   
% for GUI open
%   slmpctool('initialize', blksystem, [], task_name, fullblockname, {mpcobj, mpcobjname}, wb);
%
% mpc_openscm (design from scratch for MPC/MMPC)
% ------------
% for mpc block
%   [FRAME,WSHANDLE,MANAGER,hGUI, hProj] = ...
%   slmpctool('initialize', model, proj, get_param(fullblockname,'Name'), fullblockname, [], progress);
%
% for multiple mpc block
%   [FRAME,WSHANDLE,MANAGER,hGUI, hProj] = 
%   slmpctool('initialize', model, proj, get_param(blkp,'Name'), fullblockname, [], progress);
%

error(nargchk(7,7,nargin))
project = [];
wb = varargin{7};

%% Get the simulink model name if any
% Open with a SL model    
if ~isempty(varargin{2})
    % model name
    if isa(varargin{2}, 'char')
        model = varargin{2};
    % SL model handle
    elseif ishandle(varargin{2})
        try
            model = get_param(varargin{2}, 'Name');
        catch ME
            ctrlMsgUtils.error('MPC:designtool:InvalidSLModel');            
        end
    else
        ctrlMsgUtils.error('MPC:designtool:InvalidSLModel');            
    end
else
    if isa(varargin{3}, 'explorer.projectnode')
        model = varargin{3}.Model;
    else
        model = '';            
    end
end

% Get the mpc block name for task name
taskname = varargin{4};

% Get the mpc or multiple mpc block's full path/name
fullblockname = varargin{5};

%% Get the tree manager handle
[hJava,hUDD,M] = slctrlexplorer('initialize');
h = [];

%% Get the handle to the project and the frame
if isa(varargin{3}, 'explorer.projectnode')
    project = varargin{3};
    FRAME   = hJava;
    if ~isempty(model) % Add op cond task
        if strcmp(get_param(model, 'SimulationStatus'),'stopped')
            feval(model,[],[],[],'compile');
        end
        OperatingConditions.addoptask(model,project);
        if ~strcmp(get_param(model, 'SimulationStatus'),'stopped')
            feval(model,[],[],[],'term');
        end
    end
elseif ~isempty(model)
    % Select the root for getvalidproject to work
    drawnow
    M.ExplorerPanel.setSelected(hUDD.getTreeNodeInterface)
    [project, FRAME] = getvalidproject(model,true);
else
    project = hUDD; % Opened from MATLAB
    FRAME   = hJava;
end

if isempty(project)
    return
end

% Set the correct initial size. If the GUI is being initialized the
% FRAME must be invisible
if ~FRAME.isVisible
    WindowSize = java.awt.Dimension(880,770);
    FRAME.setSize(WindowSize);
    %FRAME.setMinimumSize(WindowSize.width,WindowSize.height);
    M.ExplorerPanel.getVerticalSplit.setDividerLocation(int32(550));
end

%% Switchyard for GUI interaction with Simulink
% Currently only 'initialize' is available
switch varargin{1}

    case 'initialize'
        
        %% Command line - always start a new task
        if isempty(model)
            %% Manage wait/status bar
            localWaitbar(0.2, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar1'));
            pause(0.5)
            localWaitbar(0.5, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar2'))
            pause(0.5)
            localWaitbar(0.6, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar3'))

            % Define a new project if necessary
            if ~isempty(taskname)
                h = newMPCproject(taskname);
            else
                h = newMPCproject;
            end
            localWaitbar(1.0, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar5'));
        %% Simulink case
        else
            %% detect whether MMPC block is the parent block
            blkp = get_param(fullblockname,'parent');
            try
                IsPartOfMMPC = strcmp(get_param(blkp,'MaskType'),'Multiple MPC');
            catch ME
                IsPartOfMMPC = false;
            end
            if IsPartOfMMPC
                TaskBlockName = fullblockname(1:max(findstr('/',fullblockname))-1);
            else
                TaskBlockName = fullblockname;
            end
            %% Simulink - new task required            
            if isempty(project.find('-class','mpcnodes.MPCGUI','Block',TaskBlockName))
                %% Manage wait/status bar
                localWaitbar(0.2, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar1'));
                pause(0.5)
                localWaitbar(0.5, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar2'))
                pause(0.5)
                localWaitbar(0.6, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar3'))
                %% Create MPC task
                % Prepend "MPC Task" to the project name for consistency
                h = mpcnodes.MPCGUI(sprintf('MPC Task - %s',taskname));
                %% Update the new MPCGUI with the treemanager handle
                h.getDialogInterface(M);
                %% Put the block name in the MPCGUI node
                if isempty(fullblockname)
                    ctrlMsgUtils.error('Controllib:general:UnexpectedError','wrong syntax when using "slmpctool" command');                        
                else
                    h.Block = TaskBlockName;
                end
                %% Add listeners to the Operating condition node to update the linearization dialog operating condition combo
                tasks = project.getChildren;
                opCondNode = [];
                for k=1:length(tasks)
                    if isa(tasks(k),'OperatingConditions.OperatingConditionTask')
                        opCondNode = tasks(k);
                        break
                    end
                end
                if ~isempty(opCondNode)
                    L = [handle.listener(opCondNode,'ObjectChildAdded', ...
                        {@localOpCondAdded h opCondNode});
                        handle.listener(opCondNode,'ObjectChildRemoved', ...
                        {@localOpCondAdded h opCondNode})];
                    h.addListeners(L);
                end
                %% Add it to the project node
                localWaitbar(0.7, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar4'));
                project.addNode(h);
                addLinearizationDialog(h,M)
                %% Wait bar update
                localWaitbar(1.0, wb, ctrlMsgUtils.message('MPC:designtool:ToolWaitbar5'));
                %% Reset project save flag
                h.Dirty = false;
            %% Simulink - task already exists somewhere under the project node so find it
            elseif ~isempty(project.up.find('-class','mpcnodes.MPCGUI','Block',TaskBlockName))
                h = project.up.find('-class','mpcnodes.MPCGUI','Block',TaskBlockName);
            else
                ctrlMsgUtils.error('Controllib:general:UnexpectedError','wrong syntax when using "slmpctool" command');                        
            end
            
            %% If an MPC block has been defined check to see if it contains an MPC object in base workspace
            if ~isempty(fullblockname) && ~isempty(get_param(fullblockname,'mpcobj')) && isempty(varargin{6})
                thisobjname = get_param(fullblockname,'mpcobj');
                if evalin('base',sprintf('exist(''%s'', ''var'')',thisobjname)) == 1
                    mpcobj = evalin('base',thisobjname);
                    if isa(mpcobj,'mpc')
                        varargin{6} = {mpcobj, thisobjname};
                    end
                end
            end
        end

        %% Set the Settings node to be the current selected
        FRAME.setSelected(h.getTreeNodeInterface);
        h.Frame = FRAME;

        %% If there is a MPC object create a controller node
        if ~isempty(varargin{6}) && ~isempty(varargin{6}{2})
            existMPC = h.getMPCControllers.find('-class','mpcnodes.MPCController','Label',varargin{6}{2});
            if isempty(existMPC)
                h.MPCObject = varargin{6};
                h.loadMPCobjects;
            end
        end

        %% Get focus on the GUI
        awtinvoke(FRAME,'setVisible',true);
        awtinvoke(FRAME,'toFront');
        drawnow
        
    otherwise
        ctrlMsgUtils.error('Controllib:general:UnexpectedError','the first input argument of the "slmpctool" command only accepts string "initialize"');        
end

%% If the project node is removed (e.g., when the Explorer is closing) the
%% @MPCGUI node must also be removed to close all the dialogs
%h.addListeners(handle.listener(project,'ObjectParentChanged', @(es,ed) removeNode(project,h)));
h.addListeners(handle.listener(project,'ObjectParentChanged', {@localRemoveSelf project h}));

function localOpCondAdded(es,ed,mpcnode,opCondNode)

%% Callback to operating condition node childadded/childremoved listener
%% which updates the combo box in the linearization dialog
mpcnode.opCondAdded(opCondNode)

function localWaitbar(val,wb,txt)

if isjava(wb)
    wb.setStatus(txt)
elseif ishghandle(wb)
    waitbar(val,wb,txt);
end

function localRemoveSelf(es,ed,project,MPCSIM)
project.removeNode(MPCSIM);