function cleanup(this) 
% CLEANUP  Enter a description here!
%
 
% Author(s): Rong Chen 14-Oct-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:21:23 $

% remove all the child nodes
if ~isempty(this.Dialog)
    javaMethodEDT('removeAll',this.Dialog);
end
delete(this.Handles.GainUDD)
delete(this.Handles.TrackingUDD)
delete(this.Handles.HardnessUDD)
delete(this.Handles.eHandles(1).UDD)
delete(this.Handles.eHandles(2).UDD)
delete(this.Handles.eHandles(3).UDD)
delete(this.Handles.ULimits)
delete(this.Handles.YLimits)
delete(this.Handles.Uwts)
delete(this.Handles.Ywts)
delete(this.Handles.Usoft)
delete(this.Handles.Ysoft)
