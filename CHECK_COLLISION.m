function NOGOGO = CHECK_COLLISION(PATH, OBSTACLE, VEHICLE_GEO, ROAD, ROADLINES, PRINT)

NN=1;
LENGTH=VEHICLE_GEO(1);
WIDTH=VEHICLE_GEO(2);
V_OBSTACLEX=OBSTACLE(5);      %VELOCITY OF OBSTACLE in X direction [ft/s]
V_OBSTACLEY=OBSTACLE(6);      %VELOCITY OF OBSTACLE in Y direction [ft/s]
NOGOGO=0;
DONE=0;
KARTER=zeros(5,2);
OBSTACLEB=zeros(2,2);


%BUFFER????
BUFFER=.5;

m=ROADLINES(1);   %slope
Bl=ROADLINES(2);  %left road boundary y-intercept
Br=ROADLINES(3);  %right road boundary y-intercept
yaw=ROAD(3);

%OBSTACLE STUFF
%EASY MODE
%CENTER
CENTER_POS=OBSTACLE(1:2);   %[x,y]
O_HIT=OBSTACLE(3);             %HEIGHT[ft]
O_WIT=OBSTACLE(4);             %WIDTH [ft]

%INITIAL POSITION
OX1=CENTER_POS(1)-O_WIT/2;  %LEFT BOUNDARY   %THE OBSTACLE IS DEFINED BY A RECTANCLE
OX2=CENTER_POS(1)+O_WIT/2;   %RIGHT BOUNDARY %THESE VALUES WILL BE COMING FROM SENSORS 
OY1=CENTER_POS(2)+O_HIT/2;  %UPPER BOUNDARY                 %AND WILL BE SUBJECT TO CHANGE WHEN THE OBSTACLE MOVES
OY2=CENTER_POS(2)-O_HIT/2;  %LOWER BOUNDARY

DIAG=(VEHICLE_GEO(2)^2+VEHICLE_GEO(1)^2)^.5;  

%THE CORNER TO CORNER LENGTH OF THE VEHICLE, CONSTANT
 

while (PATH(NN+1,5)>0 && NOGOGO==0)
    
NN=NN+1;
    
%CALCULATE VERTICES OF THE CAR

x_0= PATH(NN,1); %center x-position of car
y_0= PATH(NN,2); %center y-position of car
THETA=PATH(1,3); %angle of car relative to Lidar-Coordinate system

THETA0 = atan((LENGTH/2)/(WIDTH/2)); %angle from center of car to vertices

%VERTICES
%1=front left corner 
%2=front right corner
%3=back left corner
%4=back right corner

THETA14 = THETA0 - THETA; %Angle from vertices 1 and 4 from lidar coordinate system
THETA23 = THETA0 + THETA; %Angle from vertices 2 and 3 from lidar coordinate system

dx14= DIAG/2*cos(THETA14); %Change in x-position from parallel to coordinate system for 1 and 4
dx23= DIAG/2*cos(THETA23); %Change in x-position from parallel to coordinate system for 2 and 3
dy14= DIAG/2*sin(THETA14); %Change in y-position from parallel to coordinate system for 1 and 4
dy23= DIAG/2*sin(THETA23); %Change in y-position from parallel to coordinate system for 2 and 3

   
VERTICES(1,:)=[x_0 - dx14, y_0 + dy14]; %front left corner
VERTICES(2,:)=[x_0 - dx23, y_0 - dy23]; %back left corner
VERTICES(3,:)=[x_0 + dx23, y_0 + dy23]; %front right corner
VERTICES(4,:)=[x_0 + dx14, y_0 - dy14]; %back right corner


%CHECK TO SEE IF VERTICES ARE OFF THE ROAD

if yaw ==0 %STRAIGHT ROAD SCENARIO
    if any(VERTICES(:,1)<ROAD(1)) %checks x values of vertices and compares them to left side of road 
        NOGOGO=1;
    end
    
    if any(VERTICES(:,1)>ROAD(2)) %checks x values of vertices and compares them to right side of road
        NOGOGO=1;
    end
    
else %ANGLED ROAD SCENARIOS

    %Finds the y values on the road based on the x-positions of the vertices of the car
    if yaw > 0 %road veers left
        Y_max = VERTICES(:,1)*m + Bl;
        Y_min = VERTICES(:,1)*m + Br;
    end
    
    if yaw < 0 %road veers right
        Y_max = VERTICES(:,1)*m + Br;
        Y_min = VERTICES(:,1)*m + Bl;
    end
   
  
    %CHECK Y VALUES    
    %makes sure that none of the y-values of the vertices of the car are above or below the road
        
    if any((Y_max-VERTICES(:,2))<0) %checks to see if any y values are below  the road
        NOGOGO=1;
    end
    
    if any((VERTICES(:,2)-Y_min)<0) %checks to see if any y values are below  the road
        NOGOGO=1;
    end


end
  
    
%CHECK IF PATH AVOIDS OBSTACLE   
     
    TIME_TOT=PATH(NN,5);
    
    %SET THE OBSTACLE BOUNDING BOX
    OBSTACLEB(1,1)=OX1+V_OBSTACLEX*TIME_TOT;   %LEFT SIDE X
    OBSTACLEB(1,2)=OY1+V_OBSTACLEY*TIME_TOT;   %FURTHER SIDE Y
    OBSTACLEB(2,1)=OX2+V_OBSTACLEX*TIME_TOT;   %RIGHT SIDE X
    OBSTACLEB(2,2)=OY2+V_OBSTACLEY*TIME_TOT;   %CLOSER SIDE Y

    
    %CHECK COLLISION WITH OBSTACLE
    if (NOGOGO==0) %&& PRINT==0  
          
        if min(VERTICES(:,1)) > OBSTACLEB(2,1) %THE VEHICLE IS ON THE LEFT SIDE OF THE OBSTACLE
            DONE=1;
        elseif max(VERTICES(:,1))< OBSTACLEB(1,1) %THE VEHICLE IS ON THE RIGHT SIDE OF THE OBSTACLE
            DONE=1;
        elseif max(VERTICES(:,2))< OBSTACLEB(2,2) %THE VEHICLE IS BEFORE THE OBSTACLE
            DONE=1;
        elseif min(VERTICES(:,2))> OBSTACLEB(1,2) %THE VEHICLE IS PAST THE OBSTACLE
            DONE=1;
        else
            NOGOGO=1;
        end         
       
    end

end

% if PRINT==1
%     
% 
%     %ORGANIZE THE VERTICIES OF THE OBSTACLE
%     OBSTACLER(1,:)=OBSTACLE(1,:);   %FRONT LEFT CORNER
%     OBSTACLER(2,1)=OBSTACLE(2,1);   %FRONT RIGHT CORNER X
%     OBSTACLER(2,2)=OBSTACLE(1,2);   %FRONT RIGHT CORNER Y
%     OBSTACLER(3,:)=OBSTACLE(2,:);   %REAR RIGHT CORNER
%     OBSTACLER(4,1)=OBSTACLE(1,1);   %REAR LEFT CORNER X
%     OBSTACLER(4,2)=OBSTACLE(2,2);   %REAR LEFT CORNER Y
%     OBSTACLER(5,:)=OBSTACLE(1,:);   %FRONT LEFT CORNER
%     
%     %PLOT THE OBSTACLE
%     %axis([-4, 4, 0, 40]);
%     plot(OBSTACLER(1:5,1),OBSTACLER(1:5,2))
%     hold on
%     
%     %ORGANIZE THE VERTICIES OF THE VEHICLE
%     %FRONT
%     KARTER(1,:)=VERTS(1,1:2);      %FRONT LEFT CORNER
%     KARTER(2,:)=VERTS(1,3:4);      %FRONT RIGHT CORNER
%     KARTER(5,:)=VERTS(1,1:2);      %FRONT LEFT CORNER
%     %REAR
%     if (THETA>=0)    
%         KARTER(3,1)=AABB(2,1);                 %REAR RIGHT CORNER X
%         KARTER(3,2)=AABB(2,2)+WIDTH*sin(THETA);%REAR RIGHT CORNER Y
%         KARTER(4,1)=AABB(2,1)-WIDTH*cos(THETA);%REAR LEFT CORNER X
%         KARTER(4,2)=AABB(2,2);                 %REAR LEFT CORNER Y
%     elseif (THETA<0)
%         KARTER(3,1)=AABB(1,1)+WIDTH*cos(THETA);%REAR RIGHT CORNER X
%         KARTER(3,2)=AABB(2,2);                 %REAR RIGHT CORNER Y
%         KARTER(4,1)=AABB(1,1);                 %REAR LEFT CORNER X
%         KARTER(4,2)=AABB(2,2)-WIDTH*sin(THETA);%REAR LEFT CORNER Y
%     end
%     
%     %PLOT THE VEHICLE
%     plot(KARTER(1:5,1),KARTER(1:5,2))
%     %FRAMES=getframe(Figure(1));
%     axis([-6,6,-5,40])
%     hold off
%     
%     
% end

end