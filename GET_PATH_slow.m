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
DIV_LOOK=10;               %NUMBER OF DIVISIONS TO LOOKAHEAD
DIV=4;                    %NUMBER OF DIVISIONS PER TREE SEGMENT
NU2=0;
TESTS=0;                  %NUMBER OF TESTS REQUIRED
nogogo=0;                 %FLAG TO DETERMINE PATH FEASIBILITY
CENTERS=zeros(60,2);
LENGTH=VEHICLE_GEO(1);                 %LENGTH OF THE VEHICLE
TIME_DIF=0;              %TIME BETWEEN NODES [s]
TIME_TOT=0;              %TOTAL TIME FROM THE ORIGIN [s]


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
    CONNECTING_NODE=TREE(CONNECTING_NODE,3);                %SETS THE NEXT CONNECTING NODE 
   
end

NN=1;
CC=ROUTE_COUNT;
TESTS=ROUTE_COUNT-DIV_LOOK;


%initial position of the vehicle
PATH(1,1:2)=VEHICLE(1:2); %[x, y]
PATH(1,3)=VEHICLE(3);      %angle [rad]


        

for i=TESTS:(-1):1
    if  (nogogo==0)
        
        %CALCULATE Lfw
        Lfw=((PATH(NN,1)-ROUTE_TREE(CC-DIV_LOOK,1))^2+(PATH(NN,2)-ROUTE_TREE(CC-DIV_LOOK,2))^2)^.5;
        %CALCULATE Nu
        NU=atan((PATH(NN,1)-ROUTE_TREE(CC-DIV_LOOK,1))/(PATH(NN,2)-ROUTE_TREE(CC-DIV_LOOK,2)))-PATH(NN,3);
        CC=CC-1;
    
    
        if NU==0
            RADIUS=0;
            
            PATH(NN+1,1)=ROUTE_TREE(CC,1);
            PATH(NN+1,2)=ROUTE_TREE(CC,2);
            PATH(NN+1,3)=PATH(NN,3);
            PATH(NN+1,4)=0;
            
            NN=NN+1;
            
            TIME_DIF=(((PATH(NN,1)-PATH(NN-1,1))^2+(PATH(NN,2)-PATH(NN-1,2))^2)^.5)/VEHICLE(4);
            TIME_TOT=TIME_TOT+TIME_DIF;
            
            PATH(NN,5)=TIME_TOT;
            PATH(NN,6)=RADIUS;
            
        else
            %% TO DELETE %%
            THETA=PATH(NN,3);
            RADIUS=Lfw/(2*sin(NU));         
           
            
            %LOCATE THE CENTER OF THE TURN 
            CENTER(1)=PATH(NN,1)+RADIUS*cos(PATH(NN,3));  %X
            CENTER(2)=PATH(NN,2)+RADIUS*sin(PATH(NN,3));  %Y
        
            PHI=-2*NU;
            NN=NN+1;
            
            %ADD NEXT NODE TO THE TREE [x,y,theta]
            PATH(NN,1)=CENTER(1)-RADIUS*cos(THETA+PHI/DIV_LOOK);
            PATH(NN,2)=CENTER(2)-RADIUS*sin(THETA+PHI/DIV_LOOK);          
            PATH(NN,3)=PHI/DIV_LOOK-THETA;  
            PATH(NN,4) = atan(LENGTH/RADIUS)*180/pi;


            %CALCULATE THE TIME DIFFERENCE BETWEEN THE CURRENT AND LAST
            %NODE
            
            TIME_DIF=(((PATH(NN,1)-PATH(NN-1,1))^2+(PATH(NN,2)-PATH(NN-1,2))^2)^.5)/VEHICLE(4);
            TIME_TOT=TIME_TOT+TIME_DIF;
            
            PATH(NN,5)=TIME_TOT;
            PATH_COUNT=NN;
            
            %REAL STUFF
            if NN <= 2;
            cord = ((PATH(NN,2)-PATH(NN-1,2))^2 + (PATH(NN,1)-PATH(NN-1,1))^2 )^.5;
            RAD_2= cord/(2*sin((PATH(NN,3)-PATH(NN-1,3))/2));
            
            else
            cord = ((PATH(NN,2)-PATH(NN-2,2))^2 + (PATH(NN,1)-PATH(NN-2,1))^2 )^.5;
            RAD_2 = cord/(2*sin((PATH(NN,3)-PATH(NN-2,3))/2));      
            
            end
            
            Delta= atan(LENGTH/RAD_2);
            Delta = Delta * 180/3.14;            
            PATH(NN-1,6)= Delta;   
            
             if (abs(Delta)> ANGLE_LIMIT)
                   nogogo=1;
             end
        
        if nogogo==1
            PATH(1,1)=9001;
        end
    end
end


ROUTE_TREE = ROUTE_TREE;



end