function OK = renameScenario(this, OldName, NewName)
%RENAMESCENARIO

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:44:42 $

if strcmp(OldName, NewName)
    % Name hasn't changed
    OK = true;
    return
end
if isempty(this.up.getChildren.find('Label', NewName));
    % Proposed NewName is unique, so rename
    this.Label = NewName;
    OK = true;
else
    % Not unique, so post error message
    msg = ctrlMsgUtils.message('MPC:designtool:DuplicatedScenarioName',NewName, OldName);
    errordlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal');
    OK = false;
end
