%% MPC Bumpless Transfer

%%
% This demonstration shows how to obtain bumpless transfer when switching
% MPC from manual to automatic operation or vice versa. In particular, it
% shows how the EXT.MV input signal to the MPC block can be used to keep
% the internal MPC state up to date while the operator is in control of the
% MV. 
%
% Copyright 1990-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $  $Date: 2009/09/21 00:04:20 $

%% MPC Controller Setup
if ~mpcchecktoolboxinstalled('simulink')
    disp('Simulink(R) is required to run this demo.')
    return
end

%%
% Let us define the plant to be controlled.
num=[1 1];
den=[1 3 2 0.5];
sys=tf(num,den);

%%
% Now, we define an MPC controller object.
Ts=0.5;     % sampling time
p=15;       % prediction horizon
m=2;        % control horizon 

%% 
% Let us assume default values for weights and build the MPC object.
MPC1=mpc(sys,Ts,p,m);

%% 
% Change the output weight.
MPC1.Weights.Output=0.01;
    
%%
% Define constraints on the manipulated variable.
MPC1.MV=struct('Min',-1,'Max',1,'RateMin',-1e5);

%% Closed-Loop Simulation Using Simulink(R)
% Set total simulation time.
Tstop=250;  

% Open the simulink diagram 'MPC_BUMPLESS.MDL'
open_system('mpc_bumpless');
sim('mpc_bumpless',Tstop);
bdclose('mpc_bumpless')

%% For Comparison, Disconnect the External MV Signal and Simulate
% Now the transition from manual to automatic control is much less smooth.
% Note the large "bump" between time = 180 and 200.
open_system('mpc_bumpless');
delete_line('mpc_bumpless','Switch/1','MPC Controller/3');
delete_line('mpc_bumpless','Switching/1','MPC Controller/4');
set_param('mpc_bumpless/MPC Controller','mv_inport','off');
set_param('mpc_bumpless/MPC Controller','switch_inport','off');
set_param('mpc_bumpless/Yplots','Ymin','-1.1~-0.1')
set_param('mpc_bumpless/Yplots','Ymax','1.8~1.1')
set_param('mpc_bumpless/MVplots','Ymin','-0.6~-0.5')
set_param('mpc_bumpless/MVplots','Ymax','1.1~1.1')
sim('mpc_bumpless',Tstop);

%%
bdclose('mpc_bumpless')
displayEndOfDemoMessage(mfilename)
