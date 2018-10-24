function  [sys,x0,xstr,TS]=mpc_pmmodel(t,x,u,flag,xp0)
% [sys,x0,xstr,TS]=mpc_pmmodel(t,x,u,flag,xp0)
%
% SIMULINK representation of the paper machine process described
% by Ying, Rao, and Sun, Chem. Eng. Communications, 1992.  (See
% also, Proceedings of American Control Conference, San Diego,
% pp 1917, 1990).  The model is bilinear.  Using nomenclature in
% the paper, process variables are:
%
% Manipulated variables:   Gp, Gw
% Measured disturbance:    Np
% Unmeasured disturbance:  Nw
% Measured outputs:        H2, N1, N2
% Unmeasured outputs:      H1
% States:                  H1, H2, N1, N2
%
% Accepts standard Simulink inputs for a system model.
% The model expects the input vector (u)
% to contain [Gp, Gw, Np, Nw] (in that order).
% The outputs will be H2, N1, N2 (in that order).
% Use optional parameter xp0 to initialize the state.
% The default initial condition is zero.

% Copyright 1994-2007 The MathWorks, Inc.
% $Revision: 1.1.4.3 $  $Date: 2007/11/09 20:41:24 $

% Initialization

if nargin == 0
    flag=0;
end
if nargin < 5
    xp0=[];
end

if flag == 0

    if nargin == 4
        x0=zeros(4,1);
    elseif isempty(xp0)
        x0=zeros(4,1);
    else
        x0=xp0(:);
        if length(x0) ~= 4
            ctrlMsgUtils.error('MPC:utility:DemoPMModelInvalidXp0');            
        end
    end
    sys=[4 0 3 4 0 0 1];
    xstr=['H1';'H2';'N1';'N2'];
    TS=[0 0];

    % state update if ABS(FLAG) == 1

elseif abs(flag) == 1

    A0=[-1.93 0 0 0; .394 -.426 0 0; 0 0 -.63 0; .82 -.784 .413 -.426];
    B0=[1.274 1.274;0 0;1.34 -.65;0 0];
    U=u(1:2,1);   % Manipulated variables
    W=u(3:4,1);   % Measured and unmeasured disturbance inputs.

    sys=A0*x+B0*U;
    sys(3)=sys(3)-.327*x(3)*sum(U)+[.203 .406]*W;

    % Output update if FLAG == 3.

elseif flag == 3

    iy=[2,3,4];  % Picks out correct states to use as output variables.
    sys=x(iy,1);

    % For all other FLAG values, return an empty matrix.

else
    sys=[];
end

