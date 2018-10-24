function J=mpc_costcomputation(weights, MPCobj, nu, user_defined, varargin)

% MPC_COSTCOMPUTATION Compute cumulative cost J as a function of I/O
% weights
%
%   See also SENSITIVITY

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/10/31 06:21:12 $



weights=weights(:)'; % make it a row vector
set(MPCobj,'Weights',struct('ManipulatedVariablesRate',weights(end-nu+1:end),...
    'ManipulatedVariables',weights(end-2*nu+1:end-nu),...
    'OutputVariables',weights(1:end-2*nu)));

if ~user_defined,
    % Use default performance index
    
    Tstop=varargin{2};
    r=varargin{3};
    v=varargin{4};
    simopt=varargin{5};
    utarget=varargin{6};
    origWy=varargin{7};
    origWu=varargin{8};
    origWdu=varargin{9};
    

    [y,t,u]=sim(MPCobj,Tstop,r,v,simopt);
    du=[u(1,:);diff(u)];

    switch varargin{1}
        case 'ISE'
            J=0;
            aux=(y-r)*origWy;
            J=J+aux'*aux;
            aux=(u-ones(Tstop,1)*utarget')*origWu;
            J=J+aux'*aux;
            aux=du*origWdu;
            J=J+aux'*aux;
        case 'IAE'
            J=0;
            J=J+sum(sum(abs((y-r)*origWy)));
            J=J+sum(sum(abs((u-ones(Tstop,1)*utarget')*origWu)));
            J=J+sum(sum(abs(du*origWdu)));
        case 'ITSE'
            J=0;
            aux=(y-r)*origWy.*t;
            J=J+aux'*aux;
            aux=(u-ones(Tstop,1)*utarget')*origWu.*t;
            J=J+aux'*aux;
            aux=du*origWdu.*t;
            J=J+aux'*aux;
        case 'ITAE'
            J=0;
            J=J+sum(sum(abs((y-r)*origWy.*t)));
            J=J+sum(sum(abs((u-ones(Tstop,1)*utarget')*origWu.*t)));
            J=J+sum(sum(abs(du*origWdu.*t)));
    end
else
    perf_fun=varargin{1};
    
    % Evaluate performance function at MPCobj's weights
    eval(['J=' perf_fun '(MPCobj,varargin{2:end});']);
end