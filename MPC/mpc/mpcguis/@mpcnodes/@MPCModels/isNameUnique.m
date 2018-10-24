function OK = isNameUnique(this, Name, iModel)
% Check existing models to see whether or not proposed name is unique.

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:44:23 $

for i = 1:length(this.Models)
    if i ~= iModel
        % Note:  don't check the model being renamed
        if strcmp(Name, this.Models(i).Name)
            OK = false;
            return
        end
    end
end
OK = true;
