function [xopt,lambda,how] = qpdantz(H,f,A,b,xmin,maxiter)
%QPDANTZ solves a quadratic program using an active set method.
%
%   [x,lambda,status]=QPDANTZ(H,f,A,b,xmin,maxiter) solves the quadratic
%   programming problem:
%
%     min 0.5*x'Hx + f'x   subject to:  Ax <= b, x >= xmin
%      x
%
%   using MPC Toolbox QPSOLVER routine.
%
%   x = the optimal solution vector.
%   lambda = the dual variables (Lagrange multipliers) at the solution.
%   status = 'feasible' if x satisfies the constraints
%          = 'infeasible' if no feasible x could be found
%          = 'unreliable' if no solution could be found in QPSOLVER's
%            maximum number of iterations allowed.
%
%   See also QPSOLVER

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2007/11/09 20:39:00 $


error(nargchk(4,6,nargin));

if nargin<5,
    xmin=-1e3*ones(size(f(:)));
    warning('MPC:computation:AssumeXMin',ctrlMsgUtils.message('MPC:computation:AssumeXMin'));    
end

if nargin<6,
    maxiter=200;
end
if maxiter<1,
    ctrlMsgUtils.error('MPC:computation:InvalidMAXITER','qpdantz');
end

mnu=length(f);
nc=length(b);

if ~isequal(size(H),[mnu mnu])
    ctrlMsgUtils.error('MPC:computation:InvalidHessianOrLinCost','qpdantz');            
end

if size(A,2)~=mnu,
    ctrlMsgUtils.error('MPC:computation:InvalidConsMatrixOrLinCost','qpdantz');                
end

if size(A,1)~=nc,
    ctrlMsgUtils.error('MPC:computation:InvalidConsMatrixOrRHS','qpdantz');                
end

% H must be symmetric. Otherwise set H=(H+H')/2
if norm(H-H') > eps
    warning('MPC:computation:HessianNonsymmetric',ctrlMsgUtils.message('MPC:computation:HessianNonsymmetric'));    
    H = (H+H')*0.5;
end

% This is a constant term that adds to the initial basis
a=-H*xmin(:);    
% in each QP.
H=H\eye(mnu);

rhsc=b(:)-A*xmin(:);
rhsa=a-f(:);
TAB=[-H H*A';A*H -A*H*A'];
basisi=[H*rhsa;
    rhsc-A*H*rhsa];
ibi=-(1:mnu+nc)';
ili=-ibi;
[basis,ib,il,iter]=qpsolver(TAB,basisi,ibi,ili,maxiter);

if iter > maxiter,
    warning('MPC:computation:MAXITERExceeded',ctrlMsgUtils.message('MPC:computation:MAXITERExceeded'));        
    how='unreliable';
elseif iter < 0
    warning('MPC:computation:SolverInfeasible',ctrlMsgUtils.message('MPC:computation:SolverInfeasible'));
    how='infeasible';    
else
    % Extract the solution to the QP problem
    how='feasible';
end

xopt=zeros(mnu,1);

for j=1:mnu
    if il(j) <= 0
        xopt(j)=xmin(j);
    else
        xopt(j)=basis(il(j))+xmin(j);
    end
end

if nargout>=2,
    lambda=zeros(nc,1);
    for j=1:nc,
        if ib(mnu+j) <= 0
            lambda(j)=0;
        else
            lambda(j)=basis(ib(mnu+j));
        end
    end
end
