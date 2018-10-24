function closePlots(this)
% CLOSEPLOTS Closes any open simulation response plots associated the task.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:43:15 $

if ~isempty(this.Hin) && ishandle(this.Hin)
    delete(this.Hin.AxesGrid.Parent);
end
if ~isempty(this.Hout) && ishandle(this.Hout)
    delete(this.Hout.AxesGrid.Parent);
end
