function Segmentation_RoadandThreatFinal(block)
% Level-2 MATLAB file S-Function for LiDAR Data Segmentation.
  setup(block);
%endfunction

function setup(block)
  %% Register number of input and output ports
  block.NumInputPorts  = 4; %current point-cloud,previous point-cloud, elasped time, and vehicle state
  block.NumOutputPorts = 4; %detected obstacles,threatening obstacles,road boundaries,RRT Toggle
  %block.OutputPort(1).DimensionMode = 'Variable';
  
  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;

  %% Set block sample time to inherited
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
  block.RegBlockMethod('SetInputPortDimensions', @SetInpPortDims);
  block.RegBlockMethod('Outputs', @Output);
  
function SetInputPortSamplingMode(block, idx, fd)
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.OutputPort(1).SamplingMode = fd;
 block.OutputPort(2).SamplingMode = fd;
 block.OutputPort(3).SamplingMode = fd;
 block.OutputPort(4).SamplingMode = fd;
%endfunction

function SetInpPortDims(block, idx, di)
 block.InputPort(idx).Dimensions = di;
 block.InputPort(idx).Dimensions = di;
 block.InputPort(3).Dimensions = 1;
 block.InputPort(4).Dimensions = [2,1];
 block.OutputPort(1).Dimensions = [726,6];
 block.OutputPort(2).Dimensions = [3,1];
 block.OutputPort(3).Dimensions = [726,6];
 block.OutputPort(4).Dimensions = 1;
%endfunction

function Output(block)
%tic
VehicleState = block.InputPort(4).Data;
Datain = block.InputPort(1).Data;
xin = Datain(:,1);
yin = Datain(:,2);
Datain1 = block.InputPort(2).Data;
prev_xin = Datain1(:,1);
prev_yin = Datain1(:,2);
deltaT = block.InputPort(3).Data;
DataCluster = evalin('base','DataCluster;');
% DataCluster.identifyObstacles(xin,yin,prev_xin,prev_yin,deltaT,VehicleState);
DataCluster.identifyObstacles(xin,yin,xin,yin,deltaT,VehicleState);
%DataCluster.identifyObstacles(xin,yin,prev_xin,prev_yin,deltaT);
x = DataCluster.returnXData();
y = DataCluster.returnYData();
dx = DataCluster.returnWidth();
dy = DataCluster.returnHeight();
% Vx = DataCluster.returnVeloX();
% Vy = DataCluster.returnVeloY();
Vx = zeros(726,1);
Vy = zeros(726,1);
xThreat = DataCluster.returnThreatXData();
yThreat = DataCluster.returnThreatYData();
dxThreat = DataCluster.returnThreatWidth();
dyThreat = DataCluster.returnThreatHeight();
% VxThreat = DataCluster.returnThreatVeloX();
% VyThreat = DataCluster.returnThreatVeloY();
VxThreat = zeros(726,1);
VyThreat = zeros(726,1);
Roadway = DataCluster.returnRoadBounds();
Enable = DataCluster.returnThreat();
block.OutputPort(1).Data = [x, y, dx, dy, Vx, Vy];
block.OutputPort(2).Data = Roadway(1:3); 
block.OutputPort(3).Data = [xThreat, yThreat, dxThreat, dyThreat, VxThreat, VyThreat];
block.OutputPort(4).Data = Enable;
%block.OutputPort(4).Data = 1;

%toc
%endfunction