function FINAL_PATH = RUN_RRT(VEHICLE, OBSTACLE_ARRAY, ROAD)

%BEGINNING OF SIMULINK BLOCK*******************************    
%LOOPAL INITIALIZATION*****************
%WHAT WILL BE IN THE SIMULINK BLOCK
TEMP_NODE= zeros(3);    %[x,y,cn]
TREE=zeros(500, 3);    %[x,y,cn]
ROUTE_TREE=zeros(400,2);%[x,y]
PATH=zeros(100,5);      %[x,y,theta,delta,t,r]
NODE_DIST=3;
DONE=0;
NODES=1;
RAND_GO=0;
FINAL_TREE=zeros(20,2);
%EC: Don't need this TREE(1,1:2)=VEHICLE(1:2);
%EC: Don't need this TREE(1,3)=0;
FAIL=0;
ITERATIONS=0;
VEHICLE_GEO_ACTUAL = [2 1];
BUFFER = .25;
VEHICLE_GEO=VEHICLE_GEO_ACTUAL+BUFFER; %[length,width]
FINAL_PATH=zeros(100,5); %arbitrary size

%Trimming Function
index = find(OBSTACLE_ARRAY(:,1),1,'last'); % Find the first 0 in array
OBSTACLE_ARRAY = OBSTACLE_ARRAY(1:index+1,:); % Trim array to that index
SIZE=size(OBSTACLE_ARRAY); %OBSTACLE array size
ONumber = SIZE(1); %Number of Obstacles

% no road detected
if ~any(ROAD)
    FAIL = 1;
end

% Road aligned along car axis
 if ROAD(3) == 0
    ROAD(3) = 0.00000001;
 end

%GET LINES OF ROAD BOUNDARIES
ROADLINES = GET_ROADLINES(ROAD);  %ROADLINES = [slope,left y-intercept, right y-intercept]

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
               OBSTACLE=OBSTACLE_ARRAY((ONumber-MOBI+1),:);   %Single Row of Obstacle Array
               indices = find(isnan(OBSTACLE) == 1); % Check for NaN which indicates Zero Velocity
               [I,J] = ind2sub(size(OBSTACLE),indices);
               for ind = 1:length(I)
                   OBSTACLE(I(ind),J(ind)) = 0; %Replace all NaN values with Zero
               end
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


if (FAIL >0 )
    FINAL_PATH(1,1) = 9001;
end

ITERATIONS

TREE(1:20,:)

PATH








end