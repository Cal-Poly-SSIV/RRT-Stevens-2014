function this = advisor(MPCSIM)
% ADVISOR object constructor

%  Author:  Rong Chen
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:21:40 $

this = mpcobjects.advisor;
this.Handles = [];
this.Task = MPCSIM.getRoot;
this.Scenario = MPCSIM;
this.Controller = [];

