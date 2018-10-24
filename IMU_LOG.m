function IMU_DATA(block)
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
 
  block.InputPort(1).Dimensions        = [1 6];     %IMU data in 16 bit ints
  block.InputPort(1).DirectFeedthrough = false;
  
  block.InputPort(2).Dimensions        = [2001 6];
  block.InputPort(2).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = [2001 6];    %IMU data in 16 bit ints
  
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
  
  %GET THE INPUTS
  NEW_DATA = block.InputPort(1).Data;
  LOG = block.InputPort(2).Data;
  
  %INITIALIZE LOG ARRAY
  if LOG(1, 1) == 0
      LOG(1, 1) = 2;
  end
  
  %GET INDEX
  INDEX = LOG(1, 1);
    
  %RECORD DATA
  if INDEX <= 2001
      LOG(INDEX, 1) = NEW_DATA(1);
      LOG(INDEX, 2) = NEW_DATA(2);
      LOG(INDEX, 3) = NEW_DATA(3);
      LOG(INDEX, 4) = NEW_DATA(4);
      LOG(INDEX, 5) = NEW_DATA(5);
      LOG(INDEX, 6) = NEW_DATA(6);
  end
  
  %OUTPUT LOG
  LOG(1, 1) = INDEX + 1;
  block.OutputPort(1).Data = LOG;
 
%endfunction

function Update(block)

  %block.Dwork(1).Data = block.InputPort(1).Data(1);
  
%endfunction

