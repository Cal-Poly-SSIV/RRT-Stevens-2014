function MPCModel = getModel(this, Name)
% Return Name (an MPCModel) from the MPCModels list.  Returns []
% if the model isn't in the list

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2007/11/09 20:44:18 $

if isempty(this.Models)
    MPCModel = [];
else
    MPCModel = this.Models.find('Label',Name);
end
