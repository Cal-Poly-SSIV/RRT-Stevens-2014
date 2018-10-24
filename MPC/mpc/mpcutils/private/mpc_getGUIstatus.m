function [GUIopen, hGUI] = mpc_getGUIstatus(blkh)
% GETGUISTATUS Get status and handle to a GUI task opened by an MPC block mask

%   Authors: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/28 03:24:20 $

% Finds the (current) MPC task node for a given block.

GUIopen = false;
hGUI=[];

%% Find the mask
oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag', 'MPC_mask');
set(0,'ShowHiddenHandles',oldsh');

% If no mask has been created no GUI exists for this block
if isempty(fig)
    return
end

%% Find the MPC task for this blcikm
f = findobj(fig, 'flat', 'UserData', blkh);
if isempty(f)
    return
end
hGUI = getappdata(f(1),'hGUI');
GUIopen = ~isempty(hGUI) && ishandle(hGUI);

