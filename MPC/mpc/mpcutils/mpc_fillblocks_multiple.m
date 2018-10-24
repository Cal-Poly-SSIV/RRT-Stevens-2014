function mpc_fillblocks_multiple(blk,N)
% MPC_FILLBLOCKS_MULTIPLE Fill in parameters in MPC blocks underlying a
% multi-MPC block and related to ref and MD signals
%
%   Authors: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/07/18 15:53:02 $

fields={'ref_from_ws','ref_signal_name','ref_preview',...
    'md_from_ws','md_signal_name','md_preview'};

for i=1:length(fields),
    field=fields{i};
    evalc(['value=get_param(blk,''' field '_multiple'');']);
    for ct = 1:N
        set_param([blk '/MPC' num2str(ct)],field,value);
    end
end
