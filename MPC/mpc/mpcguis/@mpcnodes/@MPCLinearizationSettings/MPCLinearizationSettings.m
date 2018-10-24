function this = MPCLinearizationSettings(opcondnode)
%%  MPCLINEARIZATIONSETTINGS Constructor for @MPCLinearizationSettings class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.11 $  $Date: 2008/05/19 23:19:08 $

%% Create class instance
this = mpcnodes.MPCLinearizationSettings;
%% Store the model name
this.Model = opcondnode.model;
