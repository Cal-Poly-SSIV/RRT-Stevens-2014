function setSelectedRow(this, Row)
% Called by the java table when a row has been selected.  Update
% the UDD property.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:46:00 $

this.ListenerEnabled = false;
this.selectedRow = Row;
this.ListenerEnabled = true;