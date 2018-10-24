function setIOdata(this, Root)
%  SETIODATA  Saves input/output properties needed to construct the MPC
%  object.  This makes the MPCControllers node independent of the root
%  MPCGUI node.

%  Author:   Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:42:47 $

if isa(Root, 'mpcnodes.MPCGUI')
    this.IOdata = struct(...
        'InData', {Root.InData}, 'OutData', {Root.OutData}, ...
        'iMV', {Root.iMV}, 'iMD', {Root.iMD}, 'iUD', {Root.iUD}, ...
        'iNI', {Root.iNI}, 'iMO', {Root.iMO}, 'iUO', {Root.iUO}, ...
        'iNO', {Root.iNO});
    this.Frame = Root.Frame;
end
