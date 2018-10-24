function schema
% SCHEMA  Defines properties for @mpcExporter class

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:46:14 $

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'mpcExporter');

% Properties
   
schema.prop(c, 'Handles','MATLAB array');
schema.prop(c, 'Tasks', 'MATLAB array');
schema.prop(c, 'SelectedRoot','handle');
schema.prop(c, 'CurrentController', 'handle');

