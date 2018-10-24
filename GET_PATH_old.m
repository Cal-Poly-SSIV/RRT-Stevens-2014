function [PATH, PATH_COUNT] = GET_PATH(TREE, TEMP_NODE, NODE_DIST, VEHICLE, VEHICLE_GEO)

ANGLE_LIMIT=18;             %MAXIMUM ALLOWABLE ANGLE OF THE FRONT WHEEL
PATH_COUNT=0;
ROUTE_COUNT=0;            %NUMBER OF NODES IN THE ROUTE TO BE TESTED
%ROUTE_TREE=zeros(500,2);  %STORES THE NODES IN THE TESTED ROUTE [x,y]
PATH=zeros(50,6);        %PATH TAKEN [x,y,theta]
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

NU2=0;

TESTS=0;                  %NUMBER OF TESTS REQUIRED
%VERTS=zeros(400,4);       %VERTICIES OR THE VEHICLE [x,y,x,y], LEFT SIDE, RIGHT SIDE
nogogo=0;                 %FLAG TO DETERMINE PATH FEASIBILITY
CENTERS=zeros(60,2);
%TIP=[0,0];                    %CENTER OF FRONT OF THE VEHICLE [x,y]
LENGTH=VEHICLE_GEO(1);                 %LENGTH OF THE VEHICLE
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

while(CONNECTING_NODE>0)
    XER=(1/DIV)*(ROUTE_TREE(ROUTE_COUNT,1)-TREE(CONNECTING_NODE,1));
    YER=(1/DIV)*(ROUTE_TREE(ROUTE_COUNT,2)-TREE(CONNECTING_NODE,2));
    for i=1:1:(DIV-1)      %divides up each node length
        ROUTE_COUNT=ROUTE_COUNT+1;
        ROUTE_TREE(ROUTE_COUNT,1)=ROUTE_TREE(ROUTE_COUNT-1,1)-XER;
        ROUTE_TREE(ROUTE_COUNT,2)=ROUTE_TREE(ROUTE_COUNT-1,2)-YER;
        
    end
    ROUTE_COUNT=ROUTE_COUNT+1;
    ROUTE_TREE(ROUTE_COUNT, :)=TREE(CONNECTING_NODE,1:2);   %MOVES THE PREVIOUS NODE IN THE TREE INTO THE FINAL TREE
    CONNECTING_NODE=TREE(CONNECTING_NODE,3);          %SETS THE NEXT CONNECTING NODE 
   
end

%TESTS=ROUTE_COUNT-DIV;
%CURRENT_POSITION=PATH(1,:);

%CC=ROUTE_COUNT;
%cccc=0;

NN=1;
CC=ROUTE_COUNT;
TESTS=ROUTE_COUNT-DIV_LOOK;


%initial position of the vehicle
%EC LOOK INTO THIS.....................

%PATH(1,1:2)=VEHICLE(1:2); %[x, y]
%PATH(1,3)=VEHICLE(3);      %angle [rad]


        

for i=TESTS:(-1):1
    if  (nogogo==0)
        
        %CALCULATE Lfw
        Lfw=((PATH(NN,1)-ROUTE_TREE(CC-DIV_LOOK,1))^2+(PATH(NN,2)-ROUTE_TREE(CC-DIV_LOOK,2))^2)^.5;
        %CALCULATE Nu
        NU=atan((PATH(NN,1)-ROUTE_TREE(CC-DIV_LOOK,1))/(PATH(NN,2)-ROUTE_TREE(CC-DIV_LOOK,2)))-PATH(NN,3);
        NU2=PATH(NN,3)+atan2((ROUTE_TREE(CC-DIV_LOOK,1)-PATH(NN,1)),(ROUTE_TREE(CC-DIV_LOOK,2)-PATH(NN,2)));
        CC=CC-1;
    
    
        if NU==0
            RADIUS=0;
            
            PATH(NN+1,1)=ROUTE_TREE(CC,1);
            PATH(NN+1,2)=ROUTE_TREE(CC,2);
            PATH(NN+1,3)=PATH(NN,3);
            PATH(NN+1,4)=0;
            %y = PATH(NN+1,2)
            %thet = PATH(NN+1,3)
            NN=NN+1;
            
            TIME_DIF=(((PATH(NN,1)-PATH(NN-1,1))^2+(PATH(NN,2)-PATH(NN-1,2))^2)^.5)/VEHICLE(4);
            TIME_TOT=TIME_TOT+TIME_DIF;
            
            PATH(NN,5)=TIME_TOT;
            PATH(NN,6)=RADIUS;
          %  rad = PATH(NN,6);
        else
            THETA=PATH(NN,3);
            RADIUS=Lfw/(2*sin(NU/2));
            %SIGMA = atan(LENGTH*sin(NU)/(Lfw/2));
            SIGMA = atan2(LENGTH*sin(NU2),(Lfw/2));
            
            SIGMA = atan(LENGTH/RADIUS);
            
            %FAKE
            %TEST FEASIBILITY OF TURN ANGLE
            if (abs(SIGMA)>1)
                nogogo=1;
            end
            %SIGMA=NU-PATH(NN,3);
            PATH(NN,4)=SIGMA;
            PATH(NN,6)=NU2;
            

            %LOCATE THE CENTER OF THE TURN 
            CENTER(1)=PATH(NN,1)+RADIUS*cos(PATH(NN,3));  %X
            CENTER(2)=PATH(NN,2)+RADIUS*sin(PATH(NN,3));  %Y
        
            PHI=-2*NU;
            NN=NN+1;
            
            %ADD NEXT NODE TO THE TREE [x,y,theta]
            PATH(NN,1)=CENTER(1)-RADIUS*cos(THETA+PHI/DIV_LOOK);
            PATH(NN,2)=CENTER(2)-RADIUS*sin(THETA+PHI/DIV_LOOK);
            PATH(NN,3)=PHI/DIV-THETA;
            
            %CALCULATE THE TIME DIFFERENCE BETWEEN THE CURRENT AND LAST
            %NODE
            
            TIME_DIF=(((PATH(NN,1)-PATH(NN-1,1))^2+(PATH(NN,2)-PATH(NN-1,2))^2)^.5)/VEHICLE(4);
            TIME_TOT=TIME_TOT+TIME_DIF;
            
            PATH(NN,5)=TIME_TOT;
            PATH_COUNT=NN;
            %TRIG CHECKS
            if PATH(NN,2)<=PATH((NN-1),2)
                    nogogo=1;
            end
            if abs(PATH(NN,3)-PATH((NN-1),3))>1.2
                    nogogo=1;
            end
            
            %REAL STUFF
            cord = ((PATH(NN,2)-PATH(NN-1,2))^2 + (PATH(NN,1)-PATH(NN-1,1))^2 )^.5;
            RAGE= cord/(2*sin((PATH(NN,3)-PATH(NN-1,3))/2));
            
            DUMB= atan(LENGTH/RAGE);
            
            DUMB = DUMB * 180/pi;
            PATH(NN-1,6)= DUMB;
            

           % PATH(NN-1,6)= RAGE;
            %REAL STUFF
            
               if (abs(DUMB)> ANGLE_LIMIT)
                   nogogo=1;
              end
            
            %PATH(NN-1,6)= RADIUS;
            
%             if (PATH(NN,3)>PATH(NN-1,3))
%                 PATH(NN-1,4)= abs(PATH(NN-1,4))-PATH(NN-1,3);
%             else
%                 PATH(NN-1,4)= -abs(PATH(NN-1,4))+PATH(NN-1,3);
%             end
            
            
        end
        
        if nogogo==1
            PATH(1,1)=9001;
        end
    end
end






end