function Answer = isClosedLoop(this)
% Determines whether the user has turned on the constraints for the
% simulation represented by "this" (an MPCSim object)

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:44:39 $

Option = this.Handles.LoopUDD.getSelectedItem;
Answer = strcmp(Option,'Closed');