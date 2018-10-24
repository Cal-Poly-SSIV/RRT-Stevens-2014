function this = LinearAnalysisResultNode(Label)
%Constructor for @LinearAnalysisResultNode class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $  $Date: 2007/11/09 20:42:21 $

%% Create class instance
this = mpcnodes.LinearAnalysisResultNode;

if nargin ~= 0
    %% Set properties
    this.AllowsChildren = 1;
    this.Label = Label;
    this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
    this.Status = 'Linearization analysis result.';
    %% Set the icon
    this.Icon = fullfile('toolbox', 'shared', 'slcontrollib/resources', 'plot_op_conditions_results.gif');
    % Add required components
    nodes = this.getDefaultNodes;
    for i = 1:size(nodes,1)
        this.addNode(nodes(i));
    end
end