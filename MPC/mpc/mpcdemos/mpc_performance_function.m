function J = mpc_performance_function(MPCobj, Tsteps, r, PerformanceWeights)
% This is an example of how to write a user defined performance function
% used by the "sensitivity" method.  In this example, the code illustrate
% how we use performance weights to compute the cumulative performance index.

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $  $Date: 2008/10/31 06:21:20 $   

% Carry out simulation 
[y,t,u] = sim(MPCobj, Tsteps, r);
du = [u(1,:);diff(u)];
% Get Weights in MPCobj
data=getmpcdata(MPCobj);
Wy = PerformanceWeights.OutputVariables(:);Wy=Wy(1:data.ny);
Wu = PerformanceWeights.ManipulatedVariables(:);Wu=Wu(1:data.nu);
Wdu = PerformanceWeights.ManipulatedVariablesRate(:);Wdu=Wdu(1:data.nu);
% Set mv target to 0
utarget=zeros(data.nu,1);
% Compute J in ISE form
J=0;
aux=(y-r)*Wy;
J=J+aux'*aux;
aux=(u-ones(Tsteps,1)*utarget')*Wu;
J=J+aux'*aux;
aux=du*Wdu;
J=J+aux'*aux;

