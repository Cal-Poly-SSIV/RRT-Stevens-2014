function setname(MPCobj,type,index,name)
%SETNAME Set I/O signal names in MPC prediction model
%
%   SETNAME(MPCobj,'input',I,NAME) change the name of I-th input signal
%   to NAME.
%
%   SETNAME(MPCobj,'output',I,NAME) change the name of I-th output signal
%   to NAME.
%
%   See also GETNAME, MPC.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2007/11/09 20:39:48 $

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','setname');
end

if nargin<2 || ~ischar(type) || ~(strcmpi(type,'input') || strcmpi(type,'output'))
    ctrlMsgUtils.error('MPC:object:Invalid2ndIOType','setname');    
end

if nargin<3 || ~isnumeric(index) || ~isscalar(index)
    ctrlMsgUtils.error('MPC:object:Invalid3rdIndex','setname');
end

if strcmpi(type,'input'),
    nutot=MPCobj.MPCData.nutot;
    nn=nutot;
else
    ny=MPCobj.MPCData.ny;
    nn=ny;
end

if index>nn || index<1 || ~index==round(index),
    ctrlMsgUtils.error('MPC:object:IndexOutOfBoundary','setname',type,nn);    
end

if nargin<4 || isempty(name),
    name='';
end
if ~ischar(name)
    ctrlMsgUtils.error('MPC:object:Invalid4thName','setname');    
end

if strcmpi(type,'input'),
    MPCobj.Model.Plant.InputName{index}=name;
else
    MPCobj.Model.Plant.OutputName{index}=name;
end

mvindex=MPCobj.MPCData.mvindex;
mdindex=MPCobj.MPCData.mdindex;
unindex=MPCobj.MPCData.unindex;
myindex=MPCobj.MPCData.myindex;
uyindex=setdiff((1:MPCobj.MPCData.ny)',myindex(:));

% Update MD/UD/OV properties
if strcmpi(type,'input'),
    for i=1:length(mvindex),
        j=mvindex(i);
        name=MPCobj.Model.Plant.InputName{j};
        MPCobj.ManipulatedVariables(i).Name=name;
    end
    nv=length(mdindex);
    for i=1:nv,
        j=mdindex(i);
        name=MPCobj.Model.Plant.InputName{j};
        MPCobj.DisturbanceVariables(i).Name=name;
    end
    for i=1:length(unindex),
        j=unindex(i);
        name=MPCobj.Model.Plant.InputName{j};
        MPCobj.DisturbanceVariables(nv+i).Name=name;
    end
end
if strcmpi(type,'output'),
    for i=1:length(myindex),
        j=myindex(i);
        name=MPCobj.Model.Plant.OutputName{j};
        MPCobj.OutputVariables(j).Name=name;
    end
    for i=1:length(uyindex),
        j=uyindex(i);
        name=MPCobj.Model.Plant.OutputName{j};
        MPCobj.OutputVariables(j).Name=name;
    end
end

if ~isempty(inputname(1))
    assignin('caller',inputname(1),MPCobj);
end
