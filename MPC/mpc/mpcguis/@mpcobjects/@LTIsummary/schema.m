function schema
% SCHEMA  Defines properties for @LTIsummary class

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:45:37 $

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'LTIsummary');

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
   
% Pointer to Java JTextArea component
schema.prop(c, 'jText','javax.swing.JLabel');
% Pointer to container (JScrollPane)
schema.prop(c, 'jScroll','javax.swing.JScrollPane');

