function schema
%  SCHEMA  Defines properties for MPCGUI class
%  MPCGUI represents the MPC task node on the tree in CETM

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.9 $ $Date: 2008/05/31 23:21:48 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent classes
supclass = findclass(findpackage('explorer'), 'projectnode');

% Register subclass in package
c = schema.class(pkg, 'MPCGUI', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% MPC Properties
schema.prop(c,'MPCObject','MATLAB array');  % MPC/MMPC: cell array {@mpc1, name1; @mpc2, name2; ...}
schema.prop(c,'Block','string');            % MPC/MMPC: full path/name of the block (if needed)
schema.prop(c, 'Sizes', 'MATLAB array');    % plant model i/o size
% Sizes mapping (vector of integers):
% 1 NumMV
% 2 NumMD
% 3 NumUD
% 4 NumNeglectedInput
% 5 NumMO
% 6 NumUO
% 7 NumNeglectedOutput
% 8 NumIn = NumMV + NumMD + NumUD + NumNI
% 9 NumOut = NumMO + NumUO + NumNI
% Note:  NumNI and NumNO are for neglected input & output signals
schema.prop(c,'iMV','MATLAB array');
schema.prop(c,'iMD','MATLAB array');
schema.prop(c,'iUD','MATLAB array');
schema.prop(c,'iNI','MATLAB array');
schema.prop(c,'iMO','MATLAB array');
schema.prop(c,'iUO','MATLAB array');
schema.prop(c,'iNO','MATLAB array');
p = schema.prop(c,'InUDD','handle');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'OutUDD','handle');
p.AccessFlags.Serialize = 'off';
% I/O definition data for the plant i/o tables
schema.prop(c,'InData', 'MATLAB array');
schema.prop(c,'OutData','MATLAB array');

% auxiliary properties
schema.prop(c,'ModelImported','int32');
p = schema.prop(c,'Frame','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'TreeManager','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'Linearization','handle');  % Linearization dialog udd handle
p.AccessFlags.Serialize = 'off';
schema.prop(c,'Reset','MATLAB array');
schema.prop(c,'SpecsChanged','MATLAB array');
schema.prop(c,'SimulinkProject', 'int32');
schema.prop(c,'Created','MATLAB array');
schema.prop(c,'Version','MATLAB array');
schema.prop(c,'Updated','MATLAB array');
schema.prop(c, 'SaveFields', 'MATLAB array');
schema.prop(c, 'SaveData', 'MATLAB array');
schema.event(c,'ControllerListUpdated');
% Hin and Hout will be handles to the graphical display windows for this
% project.
p = schema.prop(c,'Hin','MATLAB array');  % Don't save these figure handles!
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'Hout','MATLAB array');
p.AccessFlags.Serialize = 'off';
