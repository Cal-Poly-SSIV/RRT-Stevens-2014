function RRT_BLOCK(block)
% Level-2 M file S-Function for unit delay demo.
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ 

  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 5;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 4;     %VEHICLE
  block.InputPort(1).DirectFeedthrough = false;
  
  block.InputPort(2).Dimensions        = [726,6];     %OBSTACLE
  block.InputPort(2).DirectFeedthrough = false;
  
  block.InputPort(3).Dimensions        = 3;     %ROAD
  block.InputPort(3).DirectFeedthrough = false;
  
  %block.InputPort(4).Dimensions        = 2;     %GOAL
  %block.InputPort(4).DirectFeedthrough = false;
  
  block.InputPort(4).Dimensions        = 1;     %GOGO FLAG
  block.InputPort(4).DirectFeedthrough = false;
  
  block.InputPort(5).Dimensions        = 1;     %CLOCK
  block.InputPort(5).DirectFeedthrough = false;
  
%   block.InputPort(6).Dimensions        = [50 5];     %Previous Path
%   block.InputPort(6).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = [100 5];
  
  %block.OutputPort(2).Dimensions       = 1;
  
  %% Set block sample time to inherited
  block.SampleTimes = [0 1]; % Fixed during minor Time step calculations.
  
  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update);  
  
%endfunction

function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 1;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  block.Dwork(1).Data = block.DialogPrm(1).Data;
  
%endfunction

function Output(block)

    %toc
  GO_NOGO = block.InputPort(4).Data;    % Threat trigger
  
  %disp RRT BLOCK;
   
 % if GO_NOGO == 1
        %VEHICLE=block.InputPort(1).Data
        VEHICLE = [0, 0, 0, 15];
        OBSTACLE=block.InputPort(2).Data;
        ROAD(1)=block.InputPort(3).Data(1);
        ROAD(2)=block.InputPort(3).Data(2);
        ROAD(3)=block.InputPort(3).Data(3);
        %GOAL(1:2)=block.InputPort(4).Data(1:2);
        CLOCK=block.InputPort(5).Data;
        %CurrentPath = block.InputPort(6).Data;
       % disp Run;
   % if VEHICLE(4) > 0
        tic
        %disp Run RRT
        FINAL_PATH = RUN_RRT(VEHICLE, OBSTACLE, ROAD);
        toc
    if (FINAL_PATH (1,1)<9000)
        FINAL_PATH(:,5) = FINAL_PATH( : , 5) + CLOCK;
        FINAL_PATH(1,1) = FINAL_PATH(1,1);
    end
    block.OutputPort(1).Data = FINAL_PATH;
   % end
 % end
  %block.OutputPort(1).Data = block.InputPort(4).Data(1);
  %FINAL_PATH = RUN_RRT(VEHICLE, OBSTACLE, ROAD, GOAL)
%endfunction

function Update(block)

  %block.Dwork(1).Data = block.InputPort(1).Data(1);
  
%endfunction

