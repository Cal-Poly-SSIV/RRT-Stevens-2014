function setModelSignalTypes(this, Obj)
% Force specified plant model to agree with the signal type assignments given
% in the MPCStructure node
%
% "this" is the MPCModels node
% "Obj" is an mpcnodes.MPCModel object.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2007/11/09 20:44:27 $

S = this.up;
if isempty(S.iMV) || isempty(S.iMO) || ~isa(Obj, 'mpcnodes.MPCModel')
    % Return if structure data haven't been set yet.
    return
end
InGrp.MV = S.iMV;
if ~isempty(S.iMD)
    InGrp.MD = S.iMD;
end
if ~isempty(S.iUD)
    InGrp.UD = S.iUD;
end
if ~isempty(S.iNI)
    InGrp.NI = S.iNI;
end
OutGrp.MO = S.iMO;
if ~isempty(S.iUO)
    OutGrp.UO = S.iUO;
end
if ~isempty(S.iNO)
    OutGrp.NO = S.iNO;
end

Plant = Obj.Model;
set(Plant, 'InputGroup', InGrp, 'OutputGroup', OutGrp, ...
    'InputName', S.InUDD.CellData(:,1), 'OutputName', ...
    S.OutUDD.CellData(:,1));
Obj.Model = Plant;

