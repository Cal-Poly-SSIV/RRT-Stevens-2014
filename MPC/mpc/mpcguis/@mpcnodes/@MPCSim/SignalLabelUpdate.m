function SignalLabelUpdate(this)
% Copies appropriate properties from the MPCStructure node tables
% to the MPCSim tables.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:44:32 $

% Find the MPCStructure data
S = this.getRoot;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
OutIx = 1:NumOut;
if ~isempty(S.iNO)
    OutIx(S.iNO) = [];
end

% Initialize local cell arrays
Setpoints = this.Handles.Setpoints.CellData;
if NumMD > 0
    MeasDist = this.Handles.MeasDist.CellData;
end
UnMeasDist = this.Handles.UnMeasDist.CellData;

% Update the local cell arrays
ix = [1 2 4];
jx = [1 4 5];
Setpoints(:,ix) = S.OutData(OutIx,jx);
this.Handles.Setpoints.CellData = Setpoints;

if NumMD > 0
    MeasDist(:,ix) = S.InData(S.iMD,jx);
    this.Handles.MeasDist.CellData = MeasDist;
end

ix = [1 2];
jx = [1 4];

if NumUD > 0
    UnMeasDist(1:NumUD,ix) = S.InData(S.iUD,jx);
end
UnMeasDist(NumUD+1:NumUD+NumMO,ix) = S.OutData(S.iMO,jx);
UnMeasDist(NumUD+NumMO+1:end,ix) = S.InData(S.iMV,jx);
this.Handles.UnMeasDist.CellData = UnMeasDist;

this.setNewDate;
this.updateTables = 0;
