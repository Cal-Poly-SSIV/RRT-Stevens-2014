function lidarread(block)
% Level-2 MATLAB file S-Function for times two demo.
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 
  setup(block); 
%endfunction

function setup(block)
  %% Register number of input and output ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 1;
  block.OutputPort(1).SamplingMode = 'sample';
  block.OutputPort(1).Dimensions = [726,2];
  %% Set block sample time to inherited
  block.SampleTimes = [0 0];
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';
  %% Register methods
  block.RegBlockMethod('Outputs', @Output);

function Output(block)
 %[x y thet] = md_scan_old;
[x,y] = md_scan(1);
 block.OutputPort(1).Data = [-y,x];
%endfunction