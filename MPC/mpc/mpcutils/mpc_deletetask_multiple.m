function mpc_deletetask_multiple
% MPC_DELETETASK_MULTIPLE DeleteFcn callback for multiple MPC block

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/04/28 03:24:13 $   

blkh = gcbh;

oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag','MPC_mask_multiple');
set(0,'ShowHiddenHandles',oldsh');
f = findobj(fig, 'flat', 'UserData',blkh);

if ~isempty(f)
    close(f);
end
