function setindist(MPCobj,method,extra)
%SETINDIST modifies the model used for representing unmeasured input disturbances
%
%   SETINDIST(MPCobj,'integrators') imposes the default disturbance
%   model for unmeasured inputs, that is for each unmeasured input disturbance
%   channel, an integrator is added unless there is a violation of
%   observability, otherwise the input is treated as white noise with unit
%   variance (this is equivalent to MPCobj.Model.Disturbance=[]).
%   Type "getindist(MPCobj)" to obtain the default model.
%
%   SETINDIST(MPCobj,'model',model) sets the input disturbance model to
%   MODEL (this is equivalent to MPCobj.Model.Disturbance=model);
%
%   See also GETINDIST, SET.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2007/11/09 20:39:45 $

verbose = mpccheckverbose;

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','setindist');
end

if nargin<2,
    method='default';
else
    if ~ischar(method) || (~strcmpi(method,'integrators') && ~strcmpi(method,'model')),
        ctrlMsgUtils.error('MPC:estimation:InvalidIndistOption','setindist');
    end
end

% Transform 'model' with no model to 'integrators'
if strcmpi(method,'model') && nargin<3,
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:NoUMDSpecified'));
    end
    method='integrators';
end

try
    Model=MPCobj.Model;            
    switch lower(method)
        case 'model'
            Model.Disturbance=extra;
        case 'integrators'
            % Default method
            Model.Disturbance=[];
    end
    set(MPCobj,'Model',Model);            
catch ME
    throw(ME);
end

% Update MPC object in the workspace
if ~isempty(inputname(1))
    assignin('caller',inputname(1),MPCobj);
end
