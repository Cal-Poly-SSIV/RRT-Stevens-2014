function schema
%  SCHEMA  Defines properties for MPCSims class

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc. 
%  $Revision: 1.1.8.6 $ $Date: 2007/11/09 20:45:06 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent classes
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCSims', supclass);

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c,'isEnabled', 'int32');
schema.prop(c,'CurrentScenario', 'string');

