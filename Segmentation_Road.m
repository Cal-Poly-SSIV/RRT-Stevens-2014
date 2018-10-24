function Segmentation_Road(block)
% Level-2 MATLAB file S-Function for LiDAR Data Segmentation.
  setup(block);
%endfunction

function setup(block)
  %% Register number of input and output ports
  block.NumInputPorts  = 3; %current point-cloud,previous point-cloud, and elasped time
  block.NumOutputPorts = 2; %detected obstacles,road boundaries
  %block.OutputPort(1).DimensionMode = 'Variable';
  
  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
  
  % Register the parameters.
  %block.NumDialogPrms = 3;
  %% {Threshold Distance, Max Points for Segmentation Clustering, Detected Obstacle Scaling (1=100%)
  %% Set block sample time to inherited
  
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';
  %% Point MATLAB to segmentation .class file and import it for use

  %% Register methods
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
  block.RegBlockMethod('SetInputPortDimensions', @SetInpPortDims);
  block.RegBlockMethod('Terminate', @Terminate);
  block.RegBlockMethod('Outputs', @Output);
  
function SetInputPortSamplingMode(block, idx, fd)
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.OutputPort(1).SamplingMode = fd;
 block.OutputPort(2).SamplingMode = fd;
%endfunction

function SetInpPortDims(block, idx, di)
 block.InputPort(idx).Dimensions = di;
 block.InputPort(idx).Dimensions = di;
 block.InputPort(3).Dimensions = 1;
 %Num_Beams = evalin('base', 'Num_Beams;');
 block.OutputPort(1).Dimensions = [726,6];
 block.OutputPort(2).Dimensions = [3,1];
%endfunction

function Terminate(block)
clear DataCluster;
%endfunction

function Output(block)
%tic
Datain = block.InputPort(1).Data;
xin = Datain(:,1);
yin = Datain(:,2);
Datain1 = block.InputPort(2).Data;
prev_xin = Datain1(:,1);
prev_yin = Datain1(:,2);
deltaT = block.InputPort(3).Data;
DataCluster = evalin('base','DataCluster;');
DataCluster.identifyObstacles(xin,yin,prev_xin,prev_yin,deltaT);
x = DataCluster.returnXData();
y = DataCluster.returnYData();
dx = DataCluster.returnWidth();
dy = DataCluster.returnHeight();
% Vx = DataCluster.returnVeloX();
% Vy = DataCluster.returnVeloY();
Vx = zeros(726,1);
Vy = zeros(726,1);
Roadway = DataCluster.returnRoadBounds();
%toc
block.OutputPort(1).Data = [x, y, dx, dy, Vx, Vy];
block.OutputPort(2).Data = Roadway(1:3); 
%endfunction