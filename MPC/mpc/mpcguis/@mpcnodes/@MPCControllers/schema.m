function schema
%  SCHEMA  Defines properties for MPCControllers class

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:43:07 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent class
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCControllers', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c, 'CurrentController', 'string');
schema.prop(c, 'Controllers', 'MATLAB array');
