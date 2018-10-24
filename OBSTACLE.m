function OBSTACLE(block)
% Level-2 M file S-Function for unit delay demo.
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ 

  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 2;     %PRE SET [ Y, L]
  block.InputPort(1).DirectFeedthrough = false;
  
  block.InputPort(2).Dimensions        = 3;     %FROM SERIAL [X, W, V]
  block.InputPort(2).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = 5;
  
  %block.OutputPort(2).Dimensions       = 1;
  
  %% Set block sample time to inherited
  block.SampleTimes = [0 0];
  
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

  %GET PRESET DATA
  PRESET = block.InputPort(1).Data;
  
  %GET SERIAL DATA
  SERIAL = block.InputPort(2).Data;
    
  %OUTPUT THE TWO IN ONE ARRAY

  SEND(1) = (SERIAL (1) - 32)/12; %X position (ft)
  SEND(2:3)=PRESET(:);     %Y positon and length (ft)
  SEND(4)=SERIAL (2)/12;   %width (ft)
  SEND(5)=SERIAL (3)/120;  %Velocity (ft/s)
  
    block.OutputPort(1).Data = SEND;
    %block.OutputPort(1).Data = PATH(1, 4);

 
%endfunction

function Update(block)

  %block.Dwork(1).Data = block.InputPort(1).Data(1);
  
%endfunction

