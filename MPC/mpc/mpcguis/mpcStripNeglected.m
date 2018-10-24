function [Plant, InIx, OutIx] = mpcStripNeglected(LTI, S)
% MPCSTRIPNEGLECTED(LTI, S)
% Remove neglected inputs and outputs from a plant model (LTI).
% S contains the mpc structural information.

%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.3 $  $Date: 2007/11/09 20:42:13 $
%   Author:  Larry Ricker


Plant = LTI;
[NumOut, NumIn] = size(Plant.d);
InIx = 1:NumIn;
if ~isempty(S.iNI)
    InIx(S.iNI) = [];
    InputGroup = struct('MV', {LocalNewIndex(S.iMV, InIx)});
    if ~isempty(S.iMD)
        InputGroup.MD = LocalNewIndex(S.iMD, InIx);
    end
    if ~isempty(S.iUD)
        InputGroup.UD = LocalNewIndex(S.iUD, InIx);
    end
    set(Plant, 'InputGroup', InputGroup, ...
        'InputName', Plant.InputName(InIx), ...
        'InputDelay', Plant.InputDelay(InIx), ...
        'b', Plant.b(:,InIx), ...
        'd', Plant.d(:,InIx));
end
OutIx = 1:NumOut;
if ~isempty(S.iNO)
    OutIx(S.iNO) = [];
    OutputGroup = struct('MO', {LocalNewIndex(S.iMO, OutIx)});
    if ~isempty(S.iUO)
        OutputGroup.UO = LocalNewIndex(S.iUO, OutIx);
    end
    set(Plant, 'OutputGroup', OutputGroup, ...
        'OutputName', Plant.OutputName(OutIx), ...
        'OutputDelay', Plant.OutputDelay(OutIx), ...
        'c', Plant.c(OutIx,:), ...
        'd', Plant.d(OutIx,:));
end

% -----------------------------------------------------------------

function ix = LocalNewIndex(ix0, List)
ix = ix0;
for i = 1:length(ix0)
    ix(i) = find(ix0(i) == List);
end
