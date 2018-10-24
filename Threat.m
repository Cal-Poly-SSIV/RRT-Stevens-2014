function Threat(block)
% Level-2 MATLAB file S-Function for Segmentation.
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 
  setup(block);
%endfunction

function setup(block)
  %% Register number of input and output ports
  block.NumInputPorts  = 2; %detected obstacles/road boundaries, vehicle state
  block.NumOutputPorts = 2; %threatening obstacles, RRT toggle
  %block.OutputPort(1).DimensionMode = 'Variable';
  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
  % Register the parameters.
  block.NumDialogPrms = 4; % Threat threshold (1/time-to-impact), distance-based (max),distance (min), min controlled car speed to engage
  %% {Threshold Distance, Max Points for Segmentation Clustering, Detected Obstacle Scaling (1=100%)
  %% Set block sample time to inherited
  block.SampleTimes = [-1 0]; 
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState'; 
  %% Register methods
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
  block.RegBlockMethod('SetInputPortDimensions', @SetInpPortDims);
  block.RegBlockMethod('Outputs', @Output);
  
function SetInputPortSamplingMode(block, idx, fd)
 block.InputPort(1).SamplingMode = fd;
 block.InputPort(2).SamplingMode = fd;
 block.OutputPort(1).SamplingMode = fd;
 block.OutputPort(2).SamplingMode = fd;
%endfunction

function SetInpPortDims(block, idx, di)
 block.InputPort(1).Dimensions = di;
 block.InputPort(2).Dimensions = [1, 2];
 block.OutputPort(1).Dimensions = di;
 block.OutputPort(2).Dimensions = 1;
%endfunction

function Output(block)
  tic;
  Obstacles = block.InputPort(1).Data(:,:);
  ThreateningObstacles = zeros(size(Obstacles));
  Vehicle = block.InputPort(2).Data;
  Toggle = 0;
  for i=1:length(Obstacles(:,1))
    dist = sqrt(Obstacles(i,1)^2+Obstacles(i,2)^2);
    deltaTx = abs(Obstacles(i,5)/dist);        % divide relative velocity between car and obstacle by dist - time to collision x dir
    deltaTy = abs(Obstacles(i,6)/dist);        % divide relative velocity between car and obstacle by dist - time to collision y dir
    deltaT = min(deltaTx,deltaTy);
    if(deltaT==0)
        threat = 0;
    else
        threat = 1/deltaT;
    end
%      dont engage RRT if controlled vehicle isnt moving min. speed
%      and if the detected obstacle is outside the minimum dist (if any)
    if( (sqrt(Vehicle(1)^2+Vehicle(2)^2) > block.DialogPrm(4).Data)&&(dist>=block.DialogPrm(3).Data)) 
%          engage if threat or distance criteria is met
       if((threat>=block.DialogPrm(1).Data)||(dist<=block.DialogPrm(2).Data))
			ThreateningObstacles(i,:) = Obstacles(i,:);
%             calculate and set obstacles abs velocity based on relative (from
%             segmentation) and the measured controlled vehicle
           ThreateningObstacles(i,5) = Obstacles(i,5)-Vehicle(1);
           ThreateningObstacles(i,6) = Obstacles(i,6)-Vehicle(2);
			if(Toggle==0)
				Toggle = 1;
			end
		else
 			ThreateningObstacles(i,:) = zeros(1,6);
       end
    end
  end
  block.OutputPort(1).Data = ThreateningObstacles;
  block.OutputPort(2).Data = Toggle;
  toc;
%endfunction