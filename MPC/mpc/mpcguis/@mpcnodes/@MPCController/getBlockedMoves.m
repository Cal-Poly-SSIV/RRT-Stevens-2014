function M = getBlockedMoves(this)
% Blocking strategy depends on move allocation specification

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2007 The MathWorks, Inc. 
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:42:31 $

Moves = evalin('base', this.BlockMoves);
P = evalin('base', this.P);
if Moves > P
    Moves = P;
end            
switch this.BlockAllocation
    case 'Beginning'
        M = [ones(1,Moves-1), P-Moves];
    case 'End'
        M = [P-Moves, ones(1,Moves-1)];
    case 'Uniform'
        M = (fix(P/Moves)*ones(1,Moves-1));
        M = [M, P-sum(M)];
    case 'Custom'
        M = evalin('base',this.CustomAllocation);
end
