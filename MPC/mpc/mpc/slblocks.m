function blkStruct = slblocks
%SLBLOCKS Defines the MPC Simulink library.

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.10.9 $ $Date: 2008/06/13 15:25:45 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem, e.g. open_system('simulink').
% Example:  blkStruct.Name = 'DSP Blockset';
blkStruct.Name = ['MPC' sprintf('\n') 'Toolbox'];

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
blkStruct.OpenFcn = 'mpclib';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'mpclib';
Browser(1).Name    = 'Model Predictive Control Toolbox';
Browser(1).IsFlat  = 1;

blkStruct.Browser = Browser;

% End of blocks