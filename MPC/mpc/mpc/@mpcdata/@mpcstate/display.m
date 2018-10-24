function display(state)
%DISPLAY Display an MPCSTATE object

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2007/11/09 20:40:36 $   

% Transpose, so that display(struct) shows numbers
stateOut.Plant = state.Plant(:)'; 
stateOut.Disturbance = state.Disturbance(:)';
stateOut.Noise = state.Noise(:)';
stateOut.LastMove = state.LastMove(:)';

disp('MPCSTATE object with fields');
disp(stateOut)