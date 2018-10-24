function schema
%  SCHEMA  Defines properties for LinearAnalysisResultNode class

%  Author(s): 
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:42:24 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');
% Find parent class (superclass)
supclass = findclass(pkg, 'LinearAnalysisResultNode');
% Find package
inpkg = findpackage('mpcnodes');
% Register class (subclass) in package
schema.class(inpkg, 'LinearAnalysisResultNode', supclass);

