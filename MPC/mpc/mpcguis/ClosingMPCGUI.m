function ClosingMPCGUI(EventSrc, EventData, this)
% CLOSINGMPCGUI React to user attempt to close the main GUI window.
% If no projects remain, just return.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc. 
%  $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:42:02 $

if isa(this, 'mpcnodes.MPCGUI')
    this.Frame.setVisible(true);
    this.closeTool;
end