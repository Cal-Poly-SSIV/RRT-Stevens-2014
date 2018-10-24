function this = simplot(varargin)
%SIMPLOT  Constructor for @timeplot class
%
%  H = SIMPLOT(AX,NY) creates a @simplot object with an NY-by-1 grid of
%  axes (@axesgrid object) in the area occupied by the axes with handle AX.
%
%  H = SIMPLOT(NY) uses GCA as default axes.
%
%  H = SIMPLOT(NY,'Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2008/10/31 06:21:52 $

% Create class instance
this = mpcobjects.simplot;

% Parse input list
if ishghandle(varargin{1},'axes')
   ax = varargin{1};
   varargin = varargin(2:end); 
else
   ax = gca;
end
gridsize = [varargin{1} 1];

% Check for hold mode
[this,HeldRespFlag] = check_hold(this, ax, gridsize);
if HeldRespFlag
   % Adding to an existing response (this overwritten by that response's handle)
   % RE: Skip property settings as I/O-related data may be incorrectly sized (g118113)
   return
end

% Style is always paired
this.InputStyle = 'paired';

% Generic property init
init_prop(this, ax, gridsize);

% User-specified initial values (before listeners are installed...)
this.set(varargin{2:end});

% Initialize the handle graphics objects used in @simplot class.
this.initialize(ax, gridsize);

% Create @siminput for input data tracking
createinput(this)

