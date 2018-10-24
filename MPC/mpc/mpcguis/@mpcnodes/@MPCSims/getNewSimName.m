function Name = getNewSimName(this, DefaultName)
% Ask the user for a new scenario name.  Name must be unique.
% 'this' is MPCSims node.

%  Author:  Rong Chen
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2008/12/04 22:44:06 $

while true
    msg = ctrlMsgUtils.message('MPC:designtool:NewScenarioName');
    DefaultName = inputdlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'),1,DefaultName);
    pause(0.1); % a fraction of a second pause is added to avoid thread deadlock
    if isempty(DefaultName) || length(DefaultName) <= 0
        % User cancelled, so return
        Name = '';
        return
    end
    % Check for uniqueness.
    MPCSimNode = this.getChildren.find('Label',DefaultName{1});
    if isempty(MPCSimNode)
        % If none was found, desired label is unique.
        Name = DefaultName{1};
        return
    end
end
