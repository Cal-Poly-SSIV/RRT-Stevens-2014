function LTImodel = getSelectedLTImodel(this)
% Returns the LTI model selected in the MPCController model combo box.

%	Copyright 1986-2007 The MathWorks, Inc. 
%	$Revision: 1.1.8.3 $  $Date: 2007/11/09 20:42:38 $
%   Author:  Larry Ricker

ModelName = this.ModelName;
if isempty(ModelName)
    LTImodel = [];
    disp(sprintf('Unexpected problem: no model name stored in controller "%s".',this.Label));
else
    LTImodel = this.getMPCModels.getLTImodel(ModelName);
end

