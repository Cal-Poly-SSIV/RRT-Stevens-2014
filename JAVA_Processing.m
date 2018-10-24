function JAVA_Processing(block)
% Level-2 MATLAB file S-Function for times two demo.
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 

  setup(block);
  
%endfunction

function setup(block)
  javaaddpath({'/'});
  import ClusterMethod.*;
  %% Register number of input and output ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 1;
  
  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).DirectFeedthrough = true;
  block.InputPort(2).DirectFeedthrough = true;
  
  % Register the parameters.
  block.NumDialogPrms = 3;
  
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

block.OutputPort(1).SamplingMode = fd;

function SetInpPortDims(block, idx, di)
block.InputPort(idx).Dimensions = di;
block.OutputPort(1).Dimensions = [block.DialogPrm(3).Data,6];
%endfunction

function Output(block)
  cluster = ClusterMethod(block.DialogPrm(1).Data,block.DialogPrm(2).Data,block.DialogPrm(3).Data);
  xin = block.InputPort(1).Data;
  yin = block.InputPort(2).Data;
  cluster.identifyObstacles(xin,yin);
  x = cluster.returnXData();
  y = cluster.returnYData();
  dx = cluster.returnWidth();
  dy = cluster.returnHeight();
  place = zeros(block.DialogPrm(3).Data,1);
  block.OutputPort(1).Data = [x y dx dy place place];
%endfunction