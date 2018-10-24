function cleanup(this) 
% CLEANUP  Enter a description here!
%
 
% Author(s): Rong Chen 14-Oct-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:21:33 $

% remove all the child nodes
if ~isempty(this.Dialog)
    javaMethodEDT('removeAll',this.Dialog);
end
if ishandle(this.Advisor)
    % Close the dialog without changing the stored tables
    if ~isempty(this.Advisor.Handles)
        awtinvoke(this.Advisor.Handles.Dialog,'dispose');
        % delete itself
        delete(this.Advisor.Handles.Yweight);
        delete(this.Advisor.Handles.Uweight);
        delete(this.Advisor.Handles.URweight);
    end
    delete(this.Advisor);
end
if isfield(this.Handles,'Setpoints') && ~isempty(this.Handles.Setpoints)
    delete(this.Handles.Setpoints)
end
if isfield(this.Handles,'MeasDist') && ~isempty(this.Handles.MeasDist)
    delete(this.Handles.MeasDist)
end
if isfield(this.Handles,'UnMeasDist') && ~isempty(this.Handles.UnMeasDist)
    delete(this.Handles.UnMeasDist)
end
