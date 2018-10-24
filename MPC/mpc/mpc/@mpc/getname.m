function name=getname(MPCobj,type,index)
%GETNAME Get I/O signal names in MPC prediction model
%
%   NAME=GETNAME(MPCobj,'input',I) get the name of I-th input signal
%   NAME=GETNAME(MPCobj,'output',I) get the name of I-th output signal
%
%   See also SETNAME, MPC.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2007/11/09 20:39:20 $

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','getname');
end

if nargin<2 || ~ischar(type) || ~(strcmpi(type,'input') || strcmpi(type,'output'))
    ctrlMsgUtils.error('MPC:object:Invalid2ndIOType','getname');    
end

if nargin<3 || ~isnumeric(index) || ~isscalar(index)
    ctrlMsgUtils.error('MPC:object:Invalid3rdIndex','getname');
end

if strcmpi(type,'input')
    nutot=MPCobj.MPCData.nutot;
    nn=nutot;
else
    ny=MPCobj.MPCData.ny;
    nn=ny;
end

if index>nn || index<1 || ~index==round(index),
    ctrlMsgUtils.error('MPC:object:IndexOutOfBoundary','getname',type,nn);    
end

if strcmpi(type,'input')
    name=MPCobj.Model.Plant.InputName{index};
else
    name=MPCobj.Model.Plant.OutputName{index};
end