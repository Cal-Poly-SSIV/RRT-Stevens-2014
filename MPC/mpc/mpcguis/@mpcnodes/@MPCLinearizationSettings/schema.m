function schema
%  SCHEMA  Defines properties for MPCLinearizationSettings class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/05/19 23:19:11 $

% Find parent package
% pkg = findpackage('GenericLinearizationNodes');

% % Find parent class (superclass)
% supclass = findclass(pkg, 'AbstractLinearizationSettings');

% Register class (subclass) in package
inpkg = findpackage('mpcnodes');
c = schema.class(inpkg, 'MPCLinearizationSettings');

% Properties
schema.prop(c, 'Listeners', 'MATLAB array');
schema.prop(c, 'Model', 'string');
schema.prop(c, 'IOData', 'MATLAB array');
schema.prop(c, 'MDIndex', 'MATLAB array');
schema.prop(c, 'OPPoint', 'MATLAB array');
schema.prop(c, 'OPReport', 'MATLAB array');
p = schema.prop(c, 'LinearizationDialog', 'com.mathworks.toolbox.mpc.MPCLinearizationPanel');
p.AccessFlags.Serialize = 'off';
