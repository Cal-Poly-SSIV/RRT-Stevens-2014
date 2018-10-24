function onoff = mpccheckverbose
%Check if Simulink is installed.

% Author(s): Rong Chen
% Copyright 1986-2007 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:47:23 $

verbose = warning('query','mpc:verbosity');
onoff = strcmp(verbose.state,'on');
