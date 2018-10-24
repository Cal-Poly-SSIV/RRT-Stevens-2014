function LinearAnalysis = LinearizeModel(this,linopt)
%% Method to linearize the simulink model and return a linearization node.
%% The input argument linopt are the linearization options that will be
%% used for the linearization.

%  Author(s): John Glass
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2009/03/09 19:23:29 $

import java.lang.*;

%% Create a new analysis result node
LinearAnalysis = mpcnodes.LinearAnalysisResultNode('1');
LinearAnalysis.Model = this.Model;

%% Get the linearization IO
io = this.IOData;

%% Get the operating point object
op = this.OPPoint;

%% Linearize the model
[sys,J,iostruct] = linearize(this.Model,op,io,linopt,'StoreJacobianData',true);

%% Store operating condition note
sys.Notes = 'Operating Condition';

%% Create the new operating conditions results or value panel depending
%% on whether a opreport is available. Note that the getDialogSchema method
%% of a OperConditionResultPanel will fail if the OPReport is empty
if ~isempty(this.OPReport)
   node = OperatingConditions.OperConditionResultPanel('Operating Point'); 
   set(node,'OpReport',copy(this.OPReport),'OpPoint', copy(this.OPPoint));
else
   node = OperatingConditions.OperConditionValuePanel(copy(this.OPPoint),'Operating Point'); 
end

%% Add it to the Linearization Result node
LinearAnalysis.addNode(node);

%% Add the data the linearization results node
LinearAnalysis.LinearizedModel = sys;
LinearAnalysis.ModelJacobian = J;
LinearAnalysis.LinearizationOptions = copy(linopt);
LinearAnalysis.IOStructure = iostruct;
LinearAnalysis.getInspectorPanelData(this.Model);