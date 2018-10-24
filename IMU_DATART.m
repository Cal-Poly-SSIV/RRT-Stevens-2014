function IMU_DATA(block)
% Level-2 M file S-Function for unit delay demo.
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ 

  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = [1 16];     %IMU data in 8 bit ints
  block.InputPort(1).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = [1 6];    %IMU data in 16 bit ints
  
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

  %GET THE IMU ARRAY
  IMUsmall = block.InputPort(1).Data;
  
  %CONCATINATE DATA
  
     IMUlarge(1) = IMUsmall(1) * (2^8) + IMUsmall(2);
     IMUlarge(2) = IMUsmall(3) * (2^8) + IMUsmall(4);
     IMUlarge(3) = IMUsmall(5) * (2^8) + IMUsmall(6);
     IMUlarge(4) = IMUsmall(7) * (2^8) + IMUsmall(8);
     IMUlarge(5) = IMUsmall(9) * (2^8) + IMUsmall(10);
     IMUlarge(6) = IMUsmall(11) * (2^8) + IMUsmall(12);
      
  %SCALE DATA
  
%        xshift = 479;         %CALIBRATED
%        yshift = 471;
%        zshift = 548;
%        xscale = .0416;
%        yscale = .0404;
%        zscale = .0403;
%        
%        gyroscale = .977;     %FROM DATASHEET
%        rollshift = 588;    %CALIBRATED
%        pitchshift = 595;
%        yawshift = 583;
%     
%      IMUlarge(1) = xscale*(IMUlarge(1) - xshift);
%      IMUlarge(2) = yscale*(IMUlarge(2) - yshift);
%      IMUlarge(3) = zscale*(IMUlarge(3) - zshift);
%      
%       IMUlarge(4) = gyroscale*(3.142/180)*(IMUlarge(4) - rollshift);
%       IMUlarge(5) = gyroscale*(3.142/180)*(IMUlarge(5) - pitchshift);
%       IMUlarge(6) = gyroscale*(3.142/180)*(IMUlarge(6) - yawshift);
%      
%      IMUlarge(7) = (2/12)*3.142*10*IMUlarge(7)/32;
%      IMUlarge(8) = (2/12)*3.142*10*IMUlarge(8)/32;
%      IMUlarge(9) = (2/12)*3.142*10*IMUlarge(9)/32;
%      IMUlarge(10) = (2/12)*3.142*10*IMUlarge(10)/32;
     
    %TESTING
     
%      IMUlarge(6) = 0;
%      IMUlarge(9) = 4;
%      IMUlarge(10) = 4;
  
    block.OutputPort(1).Data = IMUlarge;

  %end
 
%endfunction

function Update(block)

  %block.Dwork(1).Data = block.InputPort(1).Data(1);
  
%endfunction

