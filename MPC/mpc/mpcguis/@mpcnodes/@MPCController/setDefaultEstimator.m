function setDefaultEstimator(this)
% Get an MPC object containing the default estimator and set the
% estimator gui displays accordingly.

%   Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.10 $  $Date: 2008/05/19 23:19:02 $

this.EstimRefreshOK = false;
S = this.getRoot;
Frame = S.Frame;
mpcCursor(Frame, 'wait'); 
ODsize = this.Handles.eHandles(1).UDD.CellData;
Nsize = this.Handles.eHandles(3).UDD.CellData;

[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
OutIx = 1:NumOut;
if ~isempty(S.iNO)
    OutIx(S.iNO) = [];
end
if ~ this.DefaultEstimator
    this.HasUpdated = true;
    this.DefaultEstimator = true;
end
Obj = this.getController;
Slider = this.Handles.GainUDD;
Slider.Value = 0.5;
Nsize(:,3) = {'White'}; 
Nsize(:,4) = {'1.0'};
if isempty(Obj)
    % Possible that no mpc object could be created for given plant model
    Channels = [];
else
    % try to define a default estimator
    try
        [dummy, Channels] = getoutdist(Obj);
    catch ME
        Channels = [];
    end
end

for i = 1:length(OutIx)
    j = OutIx(i);
    if any(j == S.iMO)
        % Output is measured
        if any(i == Channels)
            ODsize{i,3} = 'Steps';
            ODsize{i,4} = '1.0';
        else
            ODsize{i,3} = 'White';
            ODsize{i,4} = '0.0';
        end
    elseif any(j == S.iUO)
        % Output is unmeasured.  Don't allow an output disturbance.
        if any(i == Channels)
            msg = ctrlMsgUtils.message('MPC:designtool:UnexpectedIntegrator', i);
            uiwait(errordlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
            return
        else
            ODsize{i,3} = 'White';
            ODsize{i,4} = '0.0';
        end
    end
end

this.Handles.eHandles(1).UDD.setCellData(ODsize);
this.Handles.eHandles(3).UDD.setCellData(Nsize);

if NumUD > 0
    IDsize = this.Handles.eHandles(2).UDD.CellData;
    if isempty(Obj)
        % if object couldn't be created
        Den = cell(NumUD,NumUD);
    else
        InDist = getindist(Obj);
        Den = InDist.den;
    end
    for i = 1:NumUD
        if i<=NumMO && length(Den{i,i}) == 2
            IDsize{i,3} = 'Steps';
            IDsize{i,4} = '1.0';
        else
            IDsize{i,3} = 'White';
            IDsize{i,4} = '0.0';
        end
    end
    this.Handles.eHandles(2).UDD.setCellData(IDsize);
end

% Reset to signal-by-signal mode, and remove model references
for Index = 1:3
    %Handles = this.Handles.eHandles(Index);
    this.EstimData(Index).ModelUsed = false;
end
mpcCursor(Frame, 'default');
this.DefaultEstimator = true;
this.EstimRefreshOK = true;
this.RefreshEstimStates;

