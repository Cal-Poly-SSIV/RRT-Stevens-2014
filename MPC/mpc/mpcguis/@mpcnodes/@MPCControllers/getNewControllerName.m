function Name = getNewControllerName(this, DefaultName)
% GETNEWCONTROLLERNAME Ask the user for a new controller name.  Name must
% be unique. 

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2008/12/04 22:43:58 $

while true
    msg = ctrlMsgUtils.message('MPC:designtool:NewControllerName');
    DefaultName = inputdlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'),1,DefaultName);
    pause(0.1); % a fraction of a second pause is added to avoid thread deadlock
    if isempty(DefaultName) || length(DefaultName) <= 0
        % User cancelled, so return
        Name = '';
        return
    end
    % Check for uniqueness.
    MPCControllerNode = this.getChildren.find('Label',DefaultName{1});
    if isempty(MPCControllerNode)
        % If none was found, desired label is unique.
        Name = DefaultName{1};
        return
    end
end
