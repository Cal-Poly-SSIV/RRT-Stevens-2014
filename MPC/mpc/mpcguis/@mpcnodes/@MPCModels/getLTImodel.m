function LTImodel = getLTImodel(this, Name)
% Operate on the MPCModels node ("this") to extract the LTI model having
% the designated name.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:44:17 $

if isempty(Name)
%     warning('"Model" was empty in call to getLTImodel');
    LTImodel = [];
else
    LTImodel = this.getModel(Name).Model;
%     if isempty(LTImodel)
%         warning(sprintf('Could not find requested LTI model:  "%s"', Name));
%     end
end

