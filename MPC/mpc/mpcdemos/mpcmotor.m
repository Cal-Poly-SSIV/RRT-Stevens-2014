%% MPC Control of a DC Servomotor

%%
% This demonstration shows how to design an MPC controller to control a
% DC servomechanism under voltage and shaft torque constraints [1].
%
% Reference
%
% [1] A. Bemporad and E. Mosca, ``Fulfilling hard constraints in uncertain
% linear systems by reference managing,'' Automatica, vol. 34, no. 4, 
% pp. 451-461, 1998. 
%
% Copyright 1990-2009 The MathWorks, Inc.  
% $Revision: 1.1.8.9 $  $Date: 2009/09/21 00:04:24 $   

%% Define the parameters of the DC-servo motor [1].
mpcmotormodel

%% MPC Controller Setup
clear ManipulatedVariables OutputVariables

%% 
% Define MPC object fields.
ManipulatedVariables=struct('Min',umin,'Max',umax,'Units','V');
OutputVariables(1)=struct('Min',-Inf,'Max',Inf,'Units','rad');
OutputVariables(2)=struct('Min',Vmin,'Max',Vmax,'Units','Nm');
Weights=struct('Input',uweight,'InputRate',duweight,'Output',yweight);

clear Model
Model.Plant=sys;
Model.Plant.OutputGroup={1 'Measured';2 'Unmeasured'};  

PredictionHorizon=10;
ControlHorizon=2;

%%
% Create MPC object in workspace.
ServoMPC=mpc(Model,Ts,PredictionHorizon,ControlHorizon);
ServoMPC.Weights=Weights;
ServoMPC.ManipulatedVariables=ManipulatedVariables;
ServoMPC.OutputVariables=OutputVariables;

%% Simulation Using SIM
disp('Now simulating nominal closed-loop behavior');

Tf=round(Tstop/Ts);
r=pi*ones(Tf,2);

[y1,t1,u1,xp1,xmpc1]=sim(ServoMPC,Tf,r);

%%
% Plot results.
subplot(311)
stairs(t1,y1(:,1));
hold on
stairs(t1,r(:,1));
hold off
title('Angular Position')
subplot(312)
stairs(t1,u1);
title('Voltage')
subplot(313)
stairs(t1,y1(:,2));
title('Torque')

%% Simulation Using Simulink(R)
if ~mpcchecktoolboxinstalled('simulink')
    disp('Simulink(R) is required to run this part of the demo.')
    return
end

%%
% Run simulation.
open_system('mpc_motor')
sim('mpc_motor',Tstop);

%%
bdclose('mpc_motor')
displayEndOfDemoMessage(mfilename)
