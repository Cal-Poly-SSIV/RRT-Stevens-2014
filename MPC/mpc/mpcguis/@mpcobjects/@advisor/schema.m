function schema
% SCHEMA  Defines properties for @advisor class

%  Author:  Rong Chen
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:21:44 $

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'advisor');

% Properties
schema.prop(c, 'Handles','MATLAB array');
schema.prop(c, 'Task','MATLAB array');
schema.prop(c, 'Scenario','MATLAB array');
schema.prop(c, 'Controller','MATLAB array');
