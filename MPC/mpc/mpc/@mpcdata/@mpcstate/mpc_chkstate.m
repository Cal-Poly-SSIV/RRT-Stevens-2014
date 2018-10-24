function x = mpc_chkstate(state,type,n,off)
%MPC_CHKSTATE Check extended state vector, and possibly remove offsets
%
% state: extended state vector (MPCSTATE object)
% type:  either 'Plant' or 'Dist' or 'Noise' or 'LastMove'
% n:     number of components

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2007/11/09 20:40:38 $   

x = get(state,type);
if isempty(x),
    x = zeros(n,1); % Default: Nominal.X(type) or Nominal.U(mvindex)
else
    if ~isa(x,'double') || ~all(isfinite(x(:)))
        ctrlMsgUtils.error('MPC:computation:InvalidStateValue');
    else
        [nx,mx] = size(x);
        if nx*mx~=n, 
            ctrlMsgUtils.error('MPC:computation:InvalidDim',['State.' type],n);                
        end
        x = x(:)-off;
    end
end
