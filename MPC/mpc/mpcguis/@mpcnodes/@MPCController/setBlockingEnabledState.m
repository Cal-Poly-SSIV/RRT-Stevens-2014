function setBlockingEnabledState(this)
%  setBlockingEnabledState(this)
%
% Set certain MPCController dialog elements to enabled/disabled state, depending
% on whether or not blocking is on.

%   Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.6 $  $Date: 2007/11/09 20:42:44 $


import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

BlockingOn = this.Handles.Buttons.blockingCB.isSelected;
yesBlocks = this.Handles.Buttons.yesBlocks;
noBlocks = this.Handles.Buttons.noBlocks;
for i=1:length(noBlocks)
    awtinvoke(noBlocks(i),'setEnabled(Z)',~BlockingOn);
end

% Dialog state also depends on whether or not custom allocation is selected
if BlockingOn
    if this.Handles.Buttons.blkCombo.getSelectedIndex == 3
        % Custom allocation.
        j_no = [1 2];
        j_yes = [3 4 5 6];
    else
        % Not custom
        j_no = [5 6];
        j_yes = [1 2 3 4];
    end
    for i=j_no
        awtinvoke(yesBlocks(i),'setEnabled(Z)',~BlockingOn);
    end
    for i=j_yes
        awtinvoke(yesBlocks(i),'setEnabled(Z)',BlockingOn);
    end
else
    % Turn off all the blocking entries
    for i=1:length(yesBlocks)
        awtinvoke(yesBlocks(i),'setEnabled(Z)',BlockingOn);
    end
end
this.Blocking = BlockingOn;
