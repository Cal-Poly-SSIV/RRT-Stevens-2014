function RefreshControllerSummary(this)
% REFRESHCONTROLLERSUMMARY Refreshes the summary text in the MPCModels view

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.12 $ $Date: 2007/11/09 20:42:53 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
iController = this.Handles.UDDtable.selectedRow;
Rows = size(this.Handles.UDDtable.CellData,1); 
Controllers = this.getChildren;
if iController < 1 || iController > length(Controllers) ...
        || iController > Rows
    Text = '';
    Notes = '';
else
    ControllerNode = Controllers(iController);
    Controller = ControllerNode.Label;
    this.CurrentController = Controller;
    mpcExporter = this.getRoot.Handles.mpcExporter;
    mpcExporter.CurrentController = ControllerNode;
    Text = getControllerText(ControllerNode);
    try
        Notes = ControllerNode.Notes;
    catch ME
        Notes = '';
    end
end
awtinvoke(this.Handles.SummaryText,'setText(Ljava.lang.String;)',Text);
awtinvoke(this.Handles.NotesArea,'setText(Ljava.lang.String;)',Notes);
awtinvoke(this.Handles.SummaryText,'setCaretPosition(I)',0);
awtinvoke(this.Handles.NotesArea,'setCaretPosition(I)',0);

% =============================================== %

function Text = getControllerText(this)
% Gets text for display of controller details

if isempty(this)
    % No controller node yet
    Text = '';
else
    % Controller node exists.  Avoid calculating a new MPC object.
    if this.HasUpdated || isempty(this.MPCobject)
        % An up-to-date MPC object doesn't exist yet, so return a simple
        % text message, avoiding creation of a new MPC object.
        msg1 = ctrlMsgUtils.message('MPC:designtool:ControllerText1');
        msg2 = ctrlMsgUtils.message('MPC:designtool:ControllerText2');
        Text = sprintf('%s\n\n%s',msg1,msg2);
    else
        % A "good" object exists, so display its properties in detail
        Text = evalc('display(this.MPCobject)');
    end
end
