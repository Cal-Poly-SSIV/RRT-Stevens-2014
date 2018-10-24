function RefreshSimSummary(this)
% Refresh the summary text in the MPCSims view

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:44:50 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

%disp('In RefreshSimSummary')
Item = this.Handles.UDDtable.selectedRow;
Rows = size(this.Handles.UDDtable.CellData,1);
Sims = this.getChildren;
if Item < 1 || Item > length(Sims) ...
        || Item > Rows
    Text = '';
    Notes = '';
else
    SimNode = Sims(Item);
    Sim = SimNode.Label;
    this.CurrentScenario = Sim;
    Text = ListScenario(SimNode);
    try
        Notes = SimNode.Notes;
    catch ME
        Notes = '';
    end
end
this.Handles.SummaryText.setText(Text);
this.Handles.NotesArea.setText(Notes);
awtinvoke(this.Handles.NotesArea, 'setCaretPosition(I)',0);

%disp('Exiting RefreshSimSummary')

% ------------------------------------------------------------------------

function Text = ListScenario(this)

% Update the scenario summary view.

% Author(s):   Larry Ricker
Text = '';
if isempty(this)
    return
else
    Text = '';
end
Text = htmlText(Text);
