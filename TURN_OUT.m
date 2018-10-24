function TURN_OUT(block)
% Level-2 M file S-Function for unit delay demo.
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ 

  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 7;
  block.NumOutputPorts = 3;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 3;     % Previous Steer Command
  block.InputPort(1).DirectFeedthrough = false; 
  
  block.InputPort(2).Dimensions        = 1;     %CLOCK
  block.InputPort(2).DirectFeedthrough = false;

  block.InputPort(3).Dimensions        = 4;     %VEHICLE DATA % Not Used %
  block.InputPort(3).DirectFeedthrough = false;  
  
  
  block.InputPort(4).Dimensions        = [100 5];     %PATH ARRAY
  block.InputPort(4).DirectFeedthrough = false;
  
  block.InputPort(5).Dimensions        = 1;     % Threat Detected?
  block.InputPort(5).DirectFeedthrough = false; 
  
  block.InputPort(6).Dimensions        = 1;     % Previous Stop Flag
  block.InputPort(6).DirectFeedthrough = false; 
  
  block.InputPort(7).Dimensions        = [100 5];     % Previous Path
  block.InputPort(7).DirectFeedthrough = false; 
  
  block.OutputPort(1).Dimensions       = 3;     % Steer and throttle commands
  
  block.OutputPort(2).Dimensions       = 1;    % Stop Flag
  
  block.OutputPort(3).Dimensions       = [100 5];    % Previous Path
  
  
  %% Set block sample time to inherited
  block.SampleTimes = [0 1];
  
  %% Register methods
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update);  
  
%endfunction

  
function SetInputPortSamplingMode(block, idx, fd)
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.InputPort(idx).SamplingMode = fd;
 block.OutputPort(1).SamplingMode = fd;
 block.OutputPort(2).SamplingMode = fd;
 block.OutputPort(3).SamplingMode = fd;
%endfunction

function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 1;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  block.Dwork(1).Data = block.DialogPrm(1).Data;
  
%endfunction

function Output(block)
  % Initialize array of throttle and Velocity values to neutral 
  SEND = [250 104 100];
  stopflag = 0;
  
  % Get previous steer command and convert to appropriate values
  PrevSend = block.InputPort(1).Data;
  PrevSend(2) = -1*(PrevSend(2)-104)*20/104;
  PrevSend(3) = (PrevSend(3)-134.99)/3.7702;
  
  %GET THE CURRENT TIME
  TIME = block.InputPort(2).Data;
  
  % Set Manuver speed, This should be updated to hold the speed that the
  % vehicle was at when it entered the manuver %
  SPEED = 12;
  
  %GET THE PATH ARRAY
  PATH = block.InputPort(4).Data;
  
  % Get Threat Flag
  Threat = block.InputPort(5).Data;
  
  % Get Previous Stop Flag
  PrevStopFlagTime = block.InputPort(6).Data;
  
  % Get previous path
  PrevPath = block.InputPort(7).Data;
    
  
  if (Threat == 1) % update steer commands if a threat is detected
      
  % The following statements check to see if the path was valid and that
  % the car is moving.  If a criteria is not met the stopflag is set and
  % the path is re-set to teh previous value.  If the stopflag is set again
  % on the next pass the car is brought to a stop.
  
  %Check to see if a path was output
    if (isempty(PATH))
       stopflag = 1;
       PATH = PrevPath; 
       disp('no path') 
    end
%       
%     % check to make sure that it was a valid path
    if (PATH(1,1)>9000)
        disp('failed path')
       stopflag = 1;
       PATH = PrevPath;
    end
%     
%      %Check to see if vehicle is moving
%     if (SPEED == 0)
%         stopflag=1;
%     end % End if
        
        %OUTPUT THE STEERING COMMAND FOR THE APPROPRIATE TIME
        % If less than the second timestamp, output the first steer command
        if TIME < PATH(2,5)
          SEND(2) = PATH(1,4);
          disp('first steer command')
        % If greater than second timestamp, continue to read the path
        else    
           Index = find((PATH(:,5)>TIME),1,'first');
           % if beyond the last timestamp, continue for one more pass
           % before failing
           
           if isempty(Index)
               SEND = PrevSend;
               stopflag = 1;
           % if a valid steer command is found   
           else
               disp('later steer command')
           SEND(2) = PATH(Index-1,4);
           end
           
        end % End test for first command
  
  % Scale steer and throttle command to send to PIC
    SEND(2) = -1*(SEND(2))*104/20+104;
    SEND(3) = 3.7702*SPEED+134.99;
    
  elseif (Threat == -1)
  % Output Neutral Steering
            SEND(3)=100;
            SEND(2)=104; 

  end % end check for threat
    

% %         If RRT has faild 6 iterations send neutral steer and set the
% %         throttle to zero.
%         if (stopflag)
%             % First Failed attempt, set timer
%             if PrevStopFlagTime == 0;
%             PrevStopFlagTime = TIME;
%             
%             %Subsequent failed paths
%             elseif ((TIME-PrevStopFlagTime) >= .3)
%             % Output Neutral Steering
%             SEND(3)=100;
%             SEND(2)=104;    
%             end
%             
%         else
%             PrevStopFlagTime = 0;            
%         end % End if stopflag
 
   % Update outputs

    block.OutputPort(1).Data = SEND;
    block.OutputPort(2).Data = PrevStopFlagTime;
    block.OutputPort(3).Data = PATH;
    

 
%endfunction

function Update(block)

  %block.Dwork(1).Data = block.InputPort(1).Data(1);
  
%endfunction

