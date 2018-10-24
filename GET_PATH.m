function [PATH, PATH_COUNT] = GET_PATH(TREE, TEMP_NODE, NODE_DIST, VEHICLE, VEHICLE_GEO)

ANGLE_LIMIT=17;           %MAXIMUM ALLOWABLE ANGLE OF THE FRONT WHEEL
PATH_COUNT=0;
ROUTE_COUNT=0;            %NUMBER OF NODES IN THE ROUTE TO BE TESTED
%ROUTE_TREE=zeros(500,2); %STORES THE NODES IN THE TESTED ROUTE [x,y]
PATH=zeros(100,5);         %PATH TAKEN [x,y,theta]
CENTER=[0,0];             %CENTER OF THE RADIUS OF CURVATURE
CURRENT_POSITION=[0,0,0]; %CURRENT POSITION OF THE FOLLOW [x,y,theta]

SIGMA=0;                  %TURN ANGLE OF THE FRONT WHEELS
THETA=0;                  %ANGLE OF THE CAR
PHI=0;                    %ARC ANGLE
NU=0;                     %LOOKAHEAD ANGLE
DELTA=0;                  %REQUIRED STEER ANGLE
Lfw=0;                    %LOOKAHEAD DISTANCE
RADIUS=0;                 %RADIUS OF CURVATURE
DIV_LOOK=8;               %NUMBER OF DIVISIONS TO LOOKAHEAD
DIV=4;                    %NUMBER OF DIVISIONS PER TREE SEGMENT
Angle_Diff = 4;           % Differential step size along the arc

NU2=0;

TESTS=0;                  %NUMBER OF TESTS REQUIRED
%VERTS=zeros(400,4);      %VERTICIES OR THE VEHICLE [x,y,x,y], LEFT SIDE, RIGHT SIDE
nogogo=0;                 %FLAG TO DETERMINE PATH FEASIBILITY
CENTERS=zeros(60,2);
%TIP=[0,0];               %CENTER OF FRONT OF THE VEHICLE [x,y]
LENGTH=VEHICLE_GEO(1);    %LENGTH OF THE VEHICLE
%WIDTH=.5;                %WIDTH OF THE VEHICLE

TIME_DIF=0;              %TIME BETWEEN NODES [s]
TIME_TOT=0;              %TOTAL TIME FROM THE ORIGIN [s]
%V_VEHICLE=1;            %VELOCITY OF THE VEHICLE IN [ft/s]

%FRAMES

%WORK THE ROUTE BACKWARDS

%EXTRACT THE COMPLETED PATH************************************************
CONNECTING_NODE=TEMP_NODE(3);     %INITIALIZES THE CONNECTION NODE FROM THE TEMP NODE
ROUTE_TREE(1,:)=TEMP_NODE(1:2);
ROUTE_COUNT=1;
CONNECTING_NODE;
% Divide each branch of the tree into sub-steps
while(CONNECTING_NODE>0)
    ROUTE_TREE(ROUTE_COUNT,1);
    TREE(CONNECTING_NODE,1);
    XER=(1/DIV)*(ROUTE_TREE(ROUTE_COUNT,1)-TREE(CONNECTING_NODE,1));
    ROUTE_TREE(ROUTE_COUNT,2);
    TREE(CONNECTING_NODE,2);
    YER=(1/DIV)*(ROUTE_TREE(ROUTE_COUNT,2)-TREE(CONNECTING_NODE,2));
    
    for i=1:1:(DIV-1)      %divides up each node length
        ROUTE_COUNT=ROUTE_COUNT+1;
        ROUTE_COUNT;
        ROUTE_TREE(ROUTE_COUNT,1)=ROUTE_TREE(ROUTE_COUNT-1,1)-XER;
        ROUTE_TREE(ROUTE_COUNT,1);
        ROUTE_TREE(ROUTE_COUNT,2)=ROUTE_TREE(ROUTE_COUNT-1,2)-YER;
         ROUTE_TREE(ROUTE_COUNT,2);
        
    end
    ROUTE_COUNT=ROUTE_COUNT+1;
    ROUTE_TREE(ROUTE_COUNT, :)=TREE(CONNECTING_NODE,1:2);   %MOVES THE PREVIOUS NODE IN THE TREE INTO THE FINAL TREE
    CONNECTING_NODE=TREE(CONNECTING_NODE,3);          %SETS THE NEXT CONNECTING NODE 
   
end
ROUTE_TREE;
% Initialize Path and Counters
NN=1;
CC=ROUTE_COUNT;

% Start at the Rout-Div element of the route
TESTS=ROUTE_COUNT-DIV_LOOK;

% Initial position of the vehicle based on LiDAR Coords
PATH(1,1:2) =      0;       % [x, y]
PATH(1,3)   =      0;       % angle [rad]
  
% For each point in ROUTe_TREE-DIV_LOOK, estimate a curve from the current
% point to the DIV_LOOKth point and take a small step along that curve.  
for i=TESTS:(-1):1
    i;
    % Make sure that the path is still valid
    if  (nogogo==0)
        
        % CALCULATE Lfw distance from current position to some node Div_Look
        % ahead
        Lfw=sqrt((PATH(NN,1)-ROUTE_TREE(CC-DIV_LOOK,1))^2+(PATH(NN,2)-ROUTE_TREE(CC-DIV_LOOK,2))^2);
        
        % CALCULATE Nu The angle between current heading and the node that
        % is Div_look ahead Recall that Theta and Nu are negative in Quadrant 1 and
        % Positive in Quadrant 2.
        NU=-atan((ROUTE_TREE(CC-DIV_LOOK,1)-PATH(NN,1))/(ROUTE_TREE(CC-DIV_LOOK,2)-PATH(NN,2)))-PATH(NN,3);
        
        %Check feasability of turn
        if (abs(NU) > pi/2)
            nogogo=1;
        end
        
        % Update counter for route tree
        CC=CC-1;
    
        % if the node is directly ahead of the car and no turn is needed %
        if NU==0
            RADIUS=0;
            
            % Update Path to send car directly to that point %
            PATH(NN+1,1)=ROUTE_TREE(CC,1);
            PATH(NN+1,2)=ROUTE_TREE(CC,2);
            
            % No change in theta if the car does not turn
            PATH(NN+1,3)=PATH(NN,3);
            PATH(NN+1,4)=0;
            
            NN=NN+1;
            
            % Estimate time needed to complete manuver %
            TIME_DIF=(((PATH(NN,1)-PATH(NN-1,1))^2+(PATH(NN,2)-PATH(NN-1,2))^2)^.5)/VEHICLE(4);
            TIME_TOT=TIME_TOT+TIME_DIF;
            
            PATH(NN,5)=TIME_TOT;
            PATH(NN,6)=RADIUS;
           
            
        else % Turn required
            % Get Current orientation of vehicle %%
            THETA=PATH(NN,3);
            
            % Radius of turn should be signed
            RADIUS=Lfw/(2*sin(NU));
            
            % Angle of inscribed chord %
            Phi=2*NU;
            
            %Location of the center of turn                
            CENTER(1)=PATH(NN,1) - RADIUS*cos(THETA);  %X
            CENTER(2)=PATH(NN,2) - RADIUS*sin(THETA);  %Y
            
            %Calculate steer angle needed to follow the given curve, this
            %approximation uses ackerman steer for a bicycle model as an
            %overly simplistic approximation of the steer angle, future
            %developments should add slip angle as well as dynamic
            %models
            PATH(NN,4) = atan(LENGTH/RADIUS)*180/pi;
            
            % Check that steer angle is within physical limitations of
            % hardware
            if (abs(PATH(NN,4))> ANGLE_LIMIT)
                   nogogo=1;
            end
            
            % Next timestep
            NN=NN+1;
            
            % add next node to tree along the arc [x,y,theta]
            % if statment accounts for the case where the car is turning
            % right and the next node is to the left and vice versa
                % Angle used to find x,y of next step
                Alpha = Phi/Angle_Diff + THETA;

            % find next x,y point
            PATH(NN,1)=CENTER(1)+RADIUS*cos(Alpha);
            PATH(NN,2)=CENTER(2)+RADIUS*sin(Alpha);
            
            % Find heading at next step for perfect geometric steering
            PATH(NN,3)= Phi/Angle_Diff + THETA;
            
            %Check that the NN node is not behind the NN-1 Node
            if PATH(NN,2)<=PATH((NN-1),2)
                    nogogo=1;
            end
            
            % Estimate time needed to complete manuver %
            TIME_DIF = abs((Phi/Angle_Diff)*RADIUS/VEHICLE(4));
            TIME_TOT=TIME_TOT+TIME_DIF;
            PATH(NN,5)=TIME_TOT;
            PATH_COUNT=NN;
            
        end % End turn or straight
        
        % If any part of the path was not achieved, set the fail flag to
        % try a new set of nodes
        if nogogo==1
            PATH(1,1)=9001;
        end
        
    end % End If NoGoGo
    
end  % End for loop
end % End function