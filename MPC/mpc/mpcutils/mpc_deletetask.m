function mpc_deletetask(varargin)
% MPC_DELETETASK DeleteFcn callback for MPC block

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2007/11/09 20:46:55 $   

%% 1) Remove any related task from the GUI

% Get the workspace handle
[frame, h, Manager] = slctrlexplorer;

% Get block path
if nargin>0 
    blockpath = varargin{1};
else
    blockpath = gcb;
end

% Delete the task (listeners are still active, as they are stored in the
% mask's appdata and the mask is still alive)
if ~isempty(h),
    mpctask=h.find('-class','mpcnodes.MPCGUI','Block',blockpath);
    if ~isempty(mpctask),
        disconnect(mpctask);
        delete(mpctask);
    end
end

% Select an existing project, if any.
% Also make sure the window closing event points to a valid project.
Projects = h.getChildren;
if ~isempty(Projects)
    P = Projects(1);
else
    P = h;
end
Manager.Explorer.setSelected(P.getTreeNodeInterface);
if isa(P, 'mpcnodes.MPCGUI') && ~P.ModelImported
    P.TreeManager.Explorer.collapseNode(P.TreeNode);
end

blkh = gcbh;

%% 2) Destroy the mask
oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag','MPC_mask');
set(0,'ShowHiddenHandles',oldsh');
f = findobj(fig, 'flat', 'UserData',blkh);

if ~isempty(f)
    close(f);
end
