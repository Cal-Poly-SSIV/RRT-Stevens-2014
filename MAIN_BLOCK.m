%GLOBAL INITIALIZATION*****************
clear all

tic
DONERS=0;     %done flag
LOOPER=0;     %loop counter
COUNTERSON=0; %print counter


%PHYSICAL OBJECTS**********************
VEHICLE=[0,0,0,10];      %INITIAL STATE [x,y,theta,v]
%OBSTACLERAW=[0,22,1,1,0,0,3,20,2,2,0,1,-4,20,2,2,0,-1,2,30,1,1,0,2,4,40,3,3,-1,0,-2,30,1,1,0,-1];  %[x,y,L,W,Vx,Vy]
ROAD=[-4, 4, -10];  %[xl,xr,yaw(degrees)];


%OBSTACLEA = OBSTACLE_MATRIX(OBSTACLERAW); %OBSTACLE ARRAY MATRIX
%OBSTACLEA = [2 12 2 2 0 0;];
            %2 20 2 2 0 0;];
            
              %4 40 3 3 -.3 0;
             % -2 30 1 1 2 2;
             % 1 15 2 2 -.6 0;
             OBSTACLEA = [ -4 20 2 2 0 0];

SIZE=size(OBSTACLEA); %OBSTACLE array size
ONumber =SIZE(1); %Number of Obstacles



% hold off
% while (DONERS==0)
%     hold off
% if VEHICLE(2)>=(GOAL(2)-10)
%     DONERS=1;
% end 
LOOPER=LOOPER+1;

%BEGINNING OF SIMULINK BLOCK*******************************    
%LOOPAL INITIALIZATION*****************
%WHAT WILL BE IN THE SIMULINK BLOCK
%BEGINNING OF SIMULINK BLOCK*******************************    
%LOOPAL INITIALIZATION*****************
%WHAT WILL BE IN THE SIMULINK BLOCK
TEMP_NODE= zeros(3);    %[x,y,cn]
TREE=zeros(500, 3);    %[x,y,cn]
ROUTE_TREE=zeros(400,2);%[x,y]
PATH=zeros(50,6);      %[x,y,theta,delta,t,r]
NODE_DIST=5;
DONE=0;
NODES=1;
RAND_GO=0;
TREE=zeros(500,3);
FINAL_TREE=zeros(20,2);

%EC: Don't need this TREE(1,1:2)=VEHICLE(1:2);
%EC: Don't need this TREE(1,3)=0;
FAIL=0;
ITERATIONS=0;
VEHICLE_GEO=[2,1]; %[width,length]
FINAL_PATH=zeros(50,6); %arbitrary size

%Trimming Function
 %index = find(OBSTACLE_ARRAY(:,1),1,'last');
 %OBSTACLE_ARRAY = OBSTACLE_ARRAY(1:index,:);
 
%GET LINES OF ROAD BOUNDARIES
ROADLINES = GET_ROADLINES(ROAD); %ROADLINES = [slope,left y-intercept, right y-intercept]


%GET GOAL 
GOAL = GET_GOAL(ROAD,ROADLINES);

while (DONE==0 && FAIL==0)
    NOGOGO=0;
    %ADD A TEMPORARY NODE TO [TREE]
    if (RAND_GO==0)
        TEMP_NODE= ADD_LINEAR(NODE_DIST, TREE, NODES, GOAL);
    else
        TEMP_NODE= ADD_RANDOM(NODE_DIST, TREE, NODES, ROAD, ROADLINES);
    end
    
    %CHECK TO SEE IF FINISHED
    % EC WHY DOES THIS MEAN ITS FINISHED  
    
    if (TEMP_NODE(1:2) == GOAL(1:2)) 
       DONE=1;
    end
    
    %GENERATE A PATH TO THE TEMPORARY NODE
    [PATH,PATH_COUNT] = GET_PATH(TREE, TEMP_NODE, NODE_DIST, VEHICLE,VEHICLE_GEO);
    %CHECK IF IT WAS A GOOD PATH
    if PATH(1,1)>9000
        NOGOGO=1;
        RAND_GO=1;
    else
        %PATH IS GOOD, NOW CHECK FOR COLLISION
        
        %MULTIPLE OBJECT LOOP
        MOBI= ONumber; %Multiple Obstacle Index
        
        while (MOBI > 0 && NOGOGO==0)
               OBSTACLE=OBSTACLEA((ONumber-MOBI+1),:);   %Single Row of Obstacle Array
               NOGOGO= CHECK_COLLISION(PATH, OBSTACLE, VEHICLE_GEO, ROAD, ROADLINES, 0);
               MOBI=MOBI-1;
             
        end
    end

    %ADD TEMPORARY NODE TO THE TREE IF IT IS VALID
    if (NOGOGO==0)
        NODES = NODES+ 1;                   %INCREMENT THE NODE COUNTE
        TREE(NODES, :)=TEMP_NODE;           %ADDS THE NODE TO [TREE]            
        RAND_GO=0;                          %STOPS CHECKING RANDOM NODES
    else  %TRY A NEW RANDOM NODE
        RAND_GO=1;
        
    end
    %plot(PATH(2:(PATH_COUNT),1), PATH(2:(PATH_COUNT),2),'c')
      
    if (NOGOGO==1)
        DONE=0;
    end
    
    if (DONE==1)
        FINAL_PATH=PATH;
       
        
        CONNECTING_NODE=NODES;     %INITIALIZES THE CONNECTION NODE FROM THE GOAL
        FINAL_NODES=0;
    
        while(CONNECTING_NODE>0)
            FINAL_NODES=FINAL_NODES+1;
            FINAL_TREE(FINAL_NODES, :)=TREE(CONNECTING_NODE,1:2);   %MOVES THE PREVIOUS NODE IN THE TREE INTO THE FINAL TREE
            CONNECTING_NODE=TREE(CONNECTING_NODE,3);          %SETS THE NEXT CONNECTING NODE 
        end
         %PLOT THE PATH IN BLUE
%          plot(FINAL_PATH(1:(PATH_COUNT),1), FINAL_PATH(1:(PATH_COUNT),2))
%          axis([-10, 10, -10,50])
%          hold on
%          %PLOT THE TREE IN RED
%          plot(FINAL_TREE(1:FINAL_NODES,1),FINAL_TREE(1:FINAL_NODES,2),'R')
%          axis([-10, 10, -10,50])
%          hold off
    end
    
    ITERATIONS=ITERATIONS+1;
    if ITERATIONS>400
        FAIL=1;
    end
end


if (FAIL >0)
    FINAL_PATH(1,1) = 9001;
end
%END OF SIMULINK BLOCK********************************
toc
figure(2)
x=-100:1:100;
y1=ROADLINES(1)*x+ROADLINES(3);
y2=ROADLINES(1)*x+ROADLINES(2);
 plot(x,y1,'-*k',x,y2,'-.ok')
 hold on
hold on
plot(FINAL_PATH(:,1),FINAL_PATH(:,2),'o')
hold on
%hold on
%plot(PATH(:,1),PATH(:,2),'ro')
hold on
plot(OBSTACLEA(:,1),OBSTACLEA(:,2),'x')
axis([-10 10 0 40])

% hold on
% PLOT_OBJECTS(VEHICLE, VEHICLE_GEO, OBSTACLE, ROAD, PATH, 1)
% hold on
axis([-10, 10, -10,50])
%PLOT THE PATH IN BLUE
% plot(FINAL_PATH(1:(PATH_COUNT),1), FINAL_PATH(1:(PATH_COUNT),2))
%axis([-10, 10, -10,50])
%PLOT THE TREE IN RED
% hold on
 plot(FINAL_TREE(1:FINAL_NODES,1),FINAL_TREE(1:FINAL_NODES,2),'R')
% 
% 
for n = 2: (length(FINAL_PATH(:,1))-1)
x = linspace(FINAL_PATH(n-1,1),FINAL_PATH(n+1,1),10);
Beta = FINAL_PATH(n,4)*pi/180 + FINAL_PATH(n,3);
steer = tan(pi/2+Beta)*(x-FINAL_PATH(n,1))+FINAL_PATH(n,2);
heading = (tan(FINAL_PATH(n,3)+pi/2))*(x-FINAL_PATH(n,1))+FINAL_PATH(n,2);
plot(x,heading,'r',x,steer,'k')
%plot(x,heading,'r')
end
axis([-10, 10, -10,50])

%PLOTTERS WILL NOT BE IN THE SIMULINK BLOCK***********

for i=1:1:3
    COUNTERSON=COUNTERSON+1;
% %SET THE AXIS
axis([-10, 10, -10,50])
%PLOT THE OBJECTS AT TIME OF PATH CALCULATION
PLOT_OBJECTS(VEHICLE, VEHICLE_GEO, OBSTACLEA, ROAD, PATH, i)
hold on
axis([-10, 10, -10,50])
%PLOT THE PATH IN BLUE
plot(FINAL_PATH(:,1), FINAL_PATH(:,2),'B')
axis([-10, 10, -10,50])
hold on
%PLOT THE TREE IN RED
plot(FINAL_TREE(1:FINAL_NODES,1),FINAL_TREE(1:FINAL_NODES,2),'Y')
axis([-10, 10, -10,50])

hold off
%STORE THE FRAME
PATH_FRAMES(COUNTERSON,:)=getframe(figure(1));
%hold off
end
hold off

VEHICLE(1:3)=FINAL_PATH(4,1:3);

%CHANGE OBSTACLE ARRAY
% OBSTACLEA(:,1)= OBSTACLEA(:,1) + OBSTACLEA(:,5)*FINAL_PATH(4,5);
% OBSTACLEA(:,2)= OBSTACLEA(:,2) + OBSTACLEA(:,6)*FINAL_PATH(4,5);
%ORIGINAL
OBSTACLE(1)=OBSTACLE(1)+OBSTACLE(5)*FINAL_PATH(4,5);


COMPLETE_PATH((3*LOOPER-2):(3*LOOPER),:)=FINAL_PATH(1:3,:);

movie(figure(1),PATH_FRAMES(1:COUNTERSON-1,:), 2,1)
hold off


%movie2avi(PATH_FRAMES(1:COUNTERSON-1,:),'steve2','compression','None','fps', 5);
for i=1:1:(LOOPER*3)
    axis([-10, 10, -10,50]);
    PLOT_OBJECTS(VEHICLE, VEHICLE_GEO, OBSTACLE, ROAD, COMPLETE_PATH, i);
    hold off
    GO_FRAMES(i,:)=getframe(figure(1));
end

movie(figure(1),GO_FRAMES(1:i),2,3)