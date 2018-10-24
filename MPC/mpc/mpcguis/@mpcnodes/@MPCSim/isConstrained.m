function Answer = isConstrained(this)
% Determines whether the user has turned on the constraints for the
% simulation represented by "this" (an MPCSim object)

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:44:40 $

Option = this.Handles.ConstraintUDD.getSelectedItem;
Answer = strcmp(Option,'Constrained');
