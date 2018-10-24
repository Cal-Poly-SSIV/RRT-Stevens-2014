function DATA_SCALING(block)
% Level-2 M file S-Function for PIC data scaling

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
 
  block.InputPort(1).Dimensions        = [1 10];     %IMU data in 8 bit ints
  block.InputPort(1).DirectFeedthrough = false;
  
  block.InputPort(2).Dimensions        = [1 7];      %constants
  block.InputPort(2).DirectFeedthrough = false;
    
  block.InputPort(3).Dimensions        = [1 1];      %GO FLAG
  block.InputPort(3).DirectFeedthrough = false;

  block.OutputPort(1).Dimensions       = [1 10];    %IMU data in 16 bit ints
  
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
  IMUlarge = block.InputPort(1).Data;
  
  %GET CALIBRATION VALUES
  constants = block.InputPort(2).Data;

  %GET GO FLAG
  GOFLAG = block.InputPort(3).Data;

  
  if (GOFLAG >0)
      
  %SCALE DATA

  xshift = constants(1); 
  yshift = constants(2);
  zshift = constants(3);
  rollshift = constants(4);    
  pitchshift = constants(5);
  yawshift = constants(6);
    
  xscale = .0403;   %g/tick FROM DATASHEET
  yscale = .0403;   %g/tick 
  zscale = .0403;   %g/tick 
  gyroscale = .977; %g/tick
  gravscale = 9.81;
  radscale = pi/180;
     
     %scale IMU data
     if abs(IMUlarge(1) - xshift) < 1.5
          IMUlarge(1) = xshift;
     end
     IMUlarge(1) = xscale*gravscale*(IMUlarge(1) - xshift);
     
     if abs(IMUlarge(2) - yshift) < 1.5
          IMUlarge(2) = yshift;
     end
     IMUlarge(2) = yscale*gravscale*(IMUlarge(2) - yshift);
     
     if abs(IMUlarge(3) - zshift) < 1.5
          IMUlarge(3) = zshift;
     end
     IMUlarge(3) = zscale*gravscale*(IMUlarge(3) - zshift);
     
     if abs(IMUlarge(4) - rollshift) < 1.5
          IMUlarge(4) = rollshift;
     end
     IMUlarge(4) = gyroscale*radscale*(IMUlarge(4) - rollshift);
      
     if abs(IMUlarge(5) - pitchshift) < 1.5
          IMUlarge(5) = pitchshift;
     end
     IMUlarge(5) = gyroscale*radscale*(IMUlarge(5) - pitchshift);
      
     if abs(IMUlarge(6) - yawshift) < 1.5
          IMUlarge(6) = yawshift;
     end
     IMUlarge(6) = gyroscale*radscale*(IMUlarge(6) - yawshift);
     
     %scale encoder data from ticks/cycle to ft/sec
     x = 7;
     while x<= 10
         IMUlarge(x) = 4.4*pi()/(32*12*.05*2)*IMUlarge(x);
         x = x + 1;
     end
  
    block.OutputPort(1).Data = IMUlarge;
     else
         
     block.OutputPort(1).Data = zeros(1, 10);
     end
     
  %end
 
%endfunction

function Update(block)

  %block.Dwork(1).Data = block.InputPort(1).Data(1);
  
%endfunction

