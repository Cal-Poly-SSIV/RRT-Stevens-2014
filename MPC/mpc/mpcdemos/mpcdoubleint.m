%% MPC Control of a Double Integrator

%%
% This very simple demonstration shows how to use MPC to control a double
% integrator under input saturation in Simulink(R).
%
% Copyright 1990-2009 The MathWorks, Inc.
% $Revision: 1.1.4.8 $  $Date: 2009/09/21 00:04:22 $   

%% MPC Controller Setup 
if ~mpcchecktoolboxinstalled('simulink')
    disp('Simulink(R) is required to run this demo.')
    return
end

%%
Ts = .1;                                    % Sampling time
p = 20;                                     % Prediction horizon
m = 3;                                      % Control horizon
mpc_controller = mpc(tf(1,[1 0 0]),Ts,p,m); % MPC object
mpc_controller.MV=struct('Min',-1,'Max',1); % Input saturation constraints

%% MPC Simulation Using Simulink(R)
x01=0;                                      % Initial state: First integrator
x02=0;                                      % Initial state: Second integrator
Tstop=5;                                    % Simulation time
r=1;                                        % Set point

%% 
open_system('mpc_doubleint');               % Open Simulink(R) Model
sim('mpc_doubleint',Tstop);                 % Start Simulation
    
%%
bdclose('mpc_doubleint');                   
displayEndOfDemoMessage(mfilename)