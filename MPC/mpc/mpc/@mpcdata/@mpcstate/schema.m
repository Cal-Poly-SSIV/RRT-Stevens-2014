function schema
% Defines properties for @mpcstate class

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2007/11/09 20:40:40 $   

c = schema.class(findpackage('mpcdata'),'mpcstate');

% Public properties
schema.prop(c,'Plant','MATLAB array'); 
schema.prop(c,'Disturbance','MATLAB array'); 
schema.prop(c,'Noise','MATLAB array'); 
schema.prop(c,'LastMove','MATLAB array'); 

