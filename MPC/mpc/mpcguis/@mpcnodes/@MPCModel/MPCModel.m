function this = MPCModel(Name,LTIobj)
%  Constructor for @MPCModel class

%  Author(s): Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2007/11/09 20:44:01 $

% Create class instance
this = mpcnodes.MPCModel;
% If nargin == 0 we are initializing from a saved state
if nargin > 0
    this.Name = Name;
    this.Label = Name;
    this.Model = LTIobj;
    this.Notes = char(LTIobj.Notes);
end
