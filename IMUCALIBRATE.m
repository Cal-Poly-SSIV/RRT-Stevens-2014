function IMUCALIBRATE(block)
% Level-2 M file S-Function for unit delay demo.
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ 

  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 3;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = [1 10];     %IMU data 
  block.InputPort(1).DirectFeedthrough = false;
    
  block.InputPort(2).Dimensions        = [1 1];      %GO FLAG
  block.InputPort(2).DirectFeedthrough = false;
  
  block.InputPort(3).Dimensions        = [1 7];      %OLD AVERAGES FOLLOWED BY COUNT
  block.InputPort(3).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = [1 7];    %NEW AVERAGES FOLLOWED BY COUNT
  
  
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

    %GET THE IMU DATA
    IMU_DATA = block.InputPort(1).Data;
    %GET GO FLAG
    GOFLAG = block.InputPort(2).Data;
    %GET OLD AVERAGES
    OLD_AVG = block.InputPort(3).Data;    
    
    n=OLD_AVG(7);

  if GOFLAG > 0

      x = 1;
      
      while x <= 6
          NEW_AVG(x)=(n*OLD_AVG(x)+IMU_DATA(x))/(n+1);
          x = x + 1;
      end
      
    n=n+1;
    NEW_AVG(7)=n;

  else
      NEW_AVG=OLD_AVG;
  end
  
    block.OutputPort(1).Data = NEW_AVG;
 
%endfunction

function Update(block)
  
%endfunction

