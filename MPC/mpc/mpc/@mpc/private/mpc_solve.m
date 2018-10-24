function [zopt,epsslack,how,iter]=mpc_solve(MuKduINV,KduINV,Kx,Ku1,Kut,Kr,zmin,rhsc0,Mlim,Mx,Mu1,Mvv,...
    rhsa0,TAB,Jm,DUFree,xk,uk1,utarget,r,vKv,nu,p,degrees,optimalseq,isunconstr,useslack,maxiter)
%MPC_SOLVE Compute the optimal input sequence by solving a QP problem or analytically
%
%   input flags: isunconstr=1 if problem is unconstrained
%                useslack=1 if problem has output constraints and needs a slack var (otherwise, useslack=0)

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2007/11/09 20:40:29 $

% Unconstrained MPC
if isunconstr,
    zopt=-KduINV*(Kx'*xk + Ku1'*uk1 + Kut'*utarget + Kr'*r + vKv');
    epsslack=0;
    how='feasible';
    iter=0;
    return
end

% Constrained MPC
% Form matrices for QPSOLVER routine (tableau)
rhsc = rhsc0 + Mlim + Mx*xk + Mu1*uk1 + Mvv;
rhsa = rhsa0 - [(xk'*Kx + r'*Kr + uk1'*Ku1 + vKv + utarget'*Kut), zeros(1,useslack)]';

basisi = [KduINV*rhsa; rhsc-MuKduINV*rhsa];

nc = size(rhsc,1);

ibi=-(1:degrees+useslack+nc)';
ili=-ibi;

% Solves QP
[basis,ib,il,iter] = qpsolver(TAB,basisi,ibi,ili,maxiter);

% TEST: compute max number of iterations
if iter > maxiter,
    warning('MPC:computation:MAXITERExceeded',ctrlMsgUtils.message('MPC:computation:MAXITERExceeded'));
elseif iter < 0
    % This should never happen, because there's a slack variable !!!
    % It's just for robustness of the code...
    how='infeasible';
    warning('MPC:computation:SolverInfeasible',ctrlMsgUtils.message('MPC:computation:SolverInfeasible'));    
    duold=Jm*optimalseq;
    zopt=[duold(1+nu:nu*p);zeros(nu,1)]; % shifts
    % Rebuilds optimalseq from zopt
    %free=find(kron(DUFree(:),ones(nu,1))); % Indices of free moves
    epsslack=Inf; % Slack variable for soft output constraints
    zopt=zopt(DUFree(:));
    return
end

% Extract the solution to the QP problem
how='feasible';
zopt=zeros(degrees+useslack,1);
for j=1:degrees+useslack
    if il(j) <= 0
        zopt(j)=zmin(j);
    else
        zopt(j)=basis(il(j))+zmin(j);
    end
end
if useslack,
    epsslack=zopt(degrees+1); % Slack variable for soft output constraints
else
    epsslack=0;
end

zopt=zopt(1:degrees);

% end MPC_SOLVE.M
