function RefreshEstimStates(this)
% Update the displays on the estimation panels based on the info
% stored in the MPCController properties

%   Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.9 $  $Date: 2007/11/09 20:42:27 $

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import java.awt.*;
if ~this.EstimRefreshOK
    % Prevents refresh when flag is set by setDefaultEstimator or
    % addController method
    return
end

if this.DefaultEstimator
    Status = 'Estimation parameters:  MPC defaults  ';
else
    Status = 'Estimation parameters:  user-specified';
end
awtinvoke(this.Handles.StatusMessage,'setText(Ljava.lang.String;)',Status);

for Index = 1:3
    Handles = this.Handles.eHandles(Index);
    ModelUsed = this.EstimData(Index).ModelUsed;
    ModelName = this.EstimData(Index).ModelName;
    awtinvoke(Handles.TextField,'setText(Ljava.lang.String;)',ModelName);
    if ModelUsed
        CurrentView = java.lang.String('Model');        
    else
        CurrentView = java.lang.String('Signal');
    end
    awtinvoke(Handles.GraphLayout,'show',Handles.GraphLayers,CurrentView);
    if ModelUsed
        awtinvoke(Handles.rbModel,'setSelected(Z)',true);
        awtinvoke(Handles.rbSignal,'setSelected(Z)', false);        
        awtinvoke(Handles.UDD.Table,'setVisible(Z)', false);
        awtinvoke(Handles.TextField,'setEnabled(Z)', true);
        awtinvoke(Handles.Button,'setEnabled(Z)', true);
    else
        awtinvoke(Handles.rbModel,'setSelected(Z)', false);
        awtinvoke(Handles.rbSignal,'setSelected(Z)', true);        
        awtinvoke(Handles.UDD.Table,'setVisible(Z)', true);
        awtinvoke(Handles.TextField,'setEnabled(Z)', false);
        awtinvoke(Handles.Button,'setEnabled(Z)', false);
    end
end
