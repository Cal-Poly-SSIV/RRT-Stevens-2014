function schema
%  SCHEMA  Defines properties for MPCmodels class

%  Author(s):  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:44:26 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent classes
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCModels', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c,'Models','handle vector');  
schema.prop(c,'Labels','MATLAB array');
