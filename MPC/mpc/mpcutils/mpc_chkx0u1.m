function [newx]=mpc_chkx0u1(x,nx,xdefault,name)
%MPC_CHKX0U1 Check if x0 or u1 is ok.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2007/11/09 20:46:52 $   

if ~isa(x,'double'),
    ctrlMsgUtils.error('MPC:utility:Invalidx0u1Data',name);
end
if isempty(x),
    newx=xdefault;
    return
end

x=x(:);
l=length(x);
if l~=nx,
    ctrlMsgUtils.error('MPC:utility:Invalidx0u1Length',name,nx);
end
newx=x;

%end mpc_chkx0u1
