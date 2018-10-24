function [sys,x0,str,ts] = sfun_keyboard_input_v1_01(t,x,u,flag,Ts)
%SFUNTMPL General M-file S-function template
%   With M-file S-functions, you can define you own ordinary differential
%   equations (ODEs), discrete system equations, and/or just about
%   any type of algorithm to be used within a Simulink block diagram.
%
%   The general form of an M-File S-function syntax is:
%       [SYS,X0,STR,TS] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%
%   What is returned by SFUNC at a given point in time, T, depends on the
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS,
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%
%
%   The state vectors, X and X0 consists of continuous states followed
%   by discrete states.
%
%   Optional parameters, P1,...,Pn can be provided to the S-function and
%   used during any FLAG operation.
%
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%               Any of the first four elements in SYS can be specified
%               as -1 indicating that they are dynamically sized. The
%               actual length for all other flags will be equal to the
%               length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%
%
%      X0     = Initial state conditions or [] if no states.
%
%      STR    = State ordering strings which is generally specified as [].
%
%      TS     = An m-by-2 matrix containing the sample time
%               (period, offset) information. Where m = number of sample
%               times. The ordering of the sample times must be:
%
%               TS = [0      0,      : Continuous sample time.
%                     0      1,      : Continuous, but fixed in minor step
%                                      sample time.
%                     PERIOD OFFSET, : Discrete sample time where
%                                      PERIOD > 0 & OFFSET < PERIOD.
%                     -2     0];     : Variable step discrete sample time
%                                      where FLAG=4 is used to get time of
%                                      next hit.
%
%               There can be more than one sample time providing
%               they are ordered such that they are monotonically
%               increasing. Only the needed sample times should be
%               specified in TS. When specifying than one
%               sample time, you must check for sample hits explicitly by
%               seeing if
%                  abs(round((T-OFFSET)/PERIOD) - (T-OFFSET)/PERIOD)
%               is within a specified tolerance, generally 1e-8. This
%               tolerance is dependent upon your model's sampling times
%               and simulation time.
%
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying
%               SYS(7) = 1 and TS = [-1 1].

% modified from sfuntmpl.m by
% Marc Compere
% CompereM@asme.org
% created : 17 June 2003
% modified: 20 June 2003

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.18 $

%
% The following outlines the general structure of an S-function.
%
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(Ts);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(Ts)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = 43; % init with the ascii representation of a '+' character

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts = [Ts 0]; % set Ts to some stepsize to avoid evaluating this S-fcn every time step

% -----------------------------------------------------------------

%
% Initialize Figure Window
%
   handle.figure=findobj('type','figure','Tag','keyboard input figure');
   
   if isempty(handle.figure)
      % 'position' args -> [left, bottom, width, height]
      handle.figure=figure('position',[100 100 400 200],...
                           'WindowStyle','Modal',...
                           'Color',get(0,'DefaultUicontrolBackgroundColor')); %,...
                           %'HandleVisibility','callback');
      %handle.figure=figure('position',[800 620 400 300]);
      %handle.figure=figure('position',[800 620 400 300],'WindowButtonDownFcn',@myCallback)
      %handle.figure=figure('position',[800 620 400 300],'WindowButtonMoveFcn',@myCallback_move,'WindowButtonDownFcn',@myCallback_clickdown)
      set(handle.figure,'Tag','keyboard input figure');

      % Make the OFF button (position args->[left bottom width height])
      handle.offbutton = uicontrol(handle.figure,...
          'Style','pushbutton',...
          'Units','characters',...
          'Position',[5 5 46 2],...
          'String','Disable exclusive figure-keyboard input',...
          'Callback',{@turn_modal_off,handle});

      % Make the ON button (position args->[left bottom width height])
      handle.onbutton = uicontrol(handle.figure,...
          'Style','pushbutton',...
          'Units','characters',...
          'Position',[5 1 46 2],...
          'String','Re-enable exclusive figure-keyboard input',...
          'Callback',{@turn_modal_on,handle});

   else, % reset the figure to 'modal' to continue accepting keyboard input
      set(handle.figure,'WindowStyle','Modal')
   end

   %handle.axis = axis;
   %text(0.2,0.5,sprintf('Hit Ctrl-C to stop keyboard input\nexclusively through this figure'))


%
% Initialize Axes & line object (the point)
%
%    steer_min = -pi; % (rad) max positive steering input signal
%    steer_max = +pi; % (rad) max negative steering input signal
%    throttle_min = -1.0; % (unitless) normalized max positive throttle signal
%    throttle_max = +1.0; % (unitless) normalized max negative throttle signal
%    axis_dims=[steer_min steer_max throttle_min throttle_max]; % [XMIN XMAX YMIN YMAX]

   %set(handle.figure,'userdata',handle)  % store handle structure in figure userdata space

% -----------------------------------------------------------------


% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

   handle.figure = findobj('type','figure','Tag','keyboard input figure'); % retrieve figure handle
   %handle = get(handle.figure,'userdata');

   current_char=get(handle.figure,'CurrentCharacter'); % a single character, like 'b'

   % update the grahics object
   %set(handle.point,'Xdata',[x(1) x(1)],'Ydata',[x(2) x(2)],'Zdata',[-1 +1]);


   % conditionally update the (numeric) state
   if ~strcmp(current_char,''), % if current_char is not blank, assign it to the state
      sys = str2num(sprintf('%i',current_char));
   else,
      sys = 0;
   end

   % reset 'CurrentCharacter' so if user lifts up from key, this is noticed
   set(handle.figure,'CurrentCharacter','+') % the plus key is the only key that may be
                                   % pressed, but when the user stops, is not noticed

   % notes:
   %    - use sprintf() to convert string -> number contained in a string (or character) variable
   %    - use char() to convert floating point number -> ascii character
   %    - use str2num() to convert the string-number into a (double) floating point number
   %    - use str2num() with char() to convert a number-string into a char-string
   %         char(97) == char(str2num('97')) --> 'a'
   %    - use num2str() to convert a (double) number into the same number but contained
   %      in a string variable
   % For example:
   %    tmp='a';                        % assign a string
   %    tmp_num=sprintf('%i',tmp)       % convert that string into a number contained in a string variable, tmp_num
   %        (tmp_num is the string containing the characters '97')
   %    tmp_char=char(str2num(tmp_num)) % convert that string variable back into a number, then into the original string


% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

   if 0, % debugging....
   if x~=43,
      x
   end
   end

   % output the current 2 states, the [x,y] graphics pair most recently updated
   sys = x; % [x(1),x(2)] -> [abscissa, ordinate] -> [x,y]

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

% unised unless ts=[-2 0] in mdlInitializesizes
sampleTime = Ts;    %  set the next hit to be Ts seconds later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate




% Callback for turning Modal OFF
function turn_modal_off(obj,eventdata,handle)
%disp('turn_modal_off:')
%handle
set(handle.figure,'WindowStyle','Normal')
%end


% Callback for turning Modal ON
function turn_modal_on(obj,eventdata,handle)
%disp('turn_modal_on:')
%handle
set(handle.figure,'WindowStyle','Modal')
%end


% % Callback for 'WindowButtonMoveFcn' in figure
% function myCallback_move(obj,eventdata)
% str=sprintf('\tWindowButtonMoveFcn callback executing');disp(str)
% end
% 
% % Callback for 'WindowButtonDownFcn' in figure
% function myCallback_clickdown(obj,eventdata)
% str=sprintf('\t\tWindowButtonDownFcn callback executing');disp(str)
% end



