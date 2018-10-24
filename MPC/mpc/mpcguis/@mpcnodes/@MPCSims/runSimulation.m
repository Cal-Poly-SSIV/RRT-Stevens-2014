function runSimulation(this)
% Runs the current simulation scenario

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc. 
%  $Revision: 1.1.8.4 $ $Date: 2007/11/09 20:45:04 $

% "this" is the MPCSims node
if length(char(this.CurrentScenario)) <= 0
    % If empty, scenario not ready to run
    msg = ctrlMsgUtils.message('MPC:designtool:NoScenario');
    warndlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleWarning'), 'modal');
    return
end
Scenario = this.getChildren.find('Label', this.CurrentScenario);
if isempty(Scenario)
    msg = ctrlMsgUtils.message('MPC:designtool:NoSuchScenario',this.CurrentScenario);
    uiwait(errordlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
else
    Scenario.runSimulation;
end