function this = mpcstate(varargin)
%MPCSTATE Constructor for @mpcstate class. 
%
%   x=mpcstate(MPCobj,xp,xd,xn,u) creates an MPC state object compatible with the mpc object
%   MPCobj with the following fields:
%            Plant  Nxp dimensional array of plant states (including 
%                   possible offsets)
%      Disturbance  Nxd dimensional array of disturbance model states. This 
%                   contains the states of the model for unmeasured disturbance 
%                   input and (appended below) the states of unmeasured 
%                   disturbances added on outputs.
%            Noise  Nxn dimensional array of noise model states
%         LastMove  Nu dimensional array of previous manipulated variables 
%                   (including possible offsets)
% 
%   given the plant state xp, the disturbance model state xd, the noise model state nx,
%   and the previous input u
%
%  x=mpcstate(MPCobj) returns a zero extended initial state compatible with the 
%  mpc object MPCobj, with x.Plant and x.LastMove initialized at MPCobj.Model.Nominal.X and
%  MPCobj.Model.Nominal.U, respectively.
%
%  x=mpcstate (no input arguments) returns an empty mpcstate object.
%
%  See also SETESTIM, MPCMOVE, GETOUTDIST, GETINDIST, GETESTIM

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.5 $  $Date: 2008/04/28 03:24:01 $   

if nargin>0
    MPCobj = varargin{1};
    % MPCobj updated
    this = mpcdata.mpcstate(MPCobj,varargin{2:end});
    if ~isempty(inputname(1))
        assignin('caller',inputname(1),MPCobj);
    end
else
    this = mpcdata.mpcstate(varargin{:});
end

