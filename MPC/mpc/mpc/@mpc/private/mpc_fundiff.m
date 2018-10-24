function diff=mpc_fundiff(x,funfcn,f,DiffMinChange,DiffMaxChange,TypicalX,varargin)
% MPC_FUNDIFF Compute finite difference of scalar multivariable function.
%
% diff=MPC_FUNDIFF(x,funfcn,f,DiffMinChange,DiffMaxChange,TypicalX)
%
% x               point where finite difference is computed
% funfcn          function to be differenciated
% f               funfcn(x)
% DiffMinChange, 
% DiffMaxChange   minimum and maximum values of perturbation of x
% TypicalX        typical value for x
%
% Based on SHARED/OPTIMLIB/FINITEDIFFERENCES.M

%   Author: A. Bemporad
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/10/31 06:21:14 $   
                    
% Value of stepsize suggested in Trust Region Methods, Conn-Gould-Toint, section 8.4.3
sgn=sign(x)+(sign(x)==0);
CHG = sqrt(eps)*sgn.*max(abs(x),abs(TypicalX));
% Make sure step size lies within DiffminChange and DiffMaxChange
CHG = sgn.*min(max(abs(CHG),DiffMinChange),DiffMaxChange);
% Partial derivative w.r.t. x(i)
n=length(x);
diff=zeros(1,n);
for i=1:n,
    dx=CHG(i);
    evalc(sprintf('fpert=%s(x+dx*[zeros(i-1,1);1;zeros(n-i,1)],varargin{2:end});',funfcn));
    diff(i)=(fpert-f)/dx; 
end