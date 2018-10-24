function OK = renameController(this, OldName, NewName)

%   Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc. 
%	$Revision: 1.1.8.4 $  $Date: 2007/11/09 20:42:39 $

if strcmp(OldName, NewName)
    % Name hasn't changed
    OK = true;
elseif isempty(this.up.getChildren.find('Label', NewName));
    % Proposed NewName is unique, so rename
    this.Label = NewName;
    OK = true;
else
    % Not unique, so post error message
    msg = ctrlMsgUtils.message('MPC:designtool:DuplicatedControllerName',NewName, OldName);
    uiwait(errordlg(msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    OK = false;
end