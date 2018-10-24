function TEMP_NODE= ADD_RANDOM(NODE_DIST, TREE, NODES, ROAD, ROADLINES)


% CREATE RANDOM NODE ON ROAD
%yaw is positive in the counterclockwise direction
xl=ROAD(1);  %perpendicular distance from lidar to left road boundary
xr=ROAD(2);  %perpendicular distance from lidar to right road boundary
yaw=ROAD(3); %angle between y-lidar coordinate and road             
m=ROADLINES(1); %slope of road
         
             
Ymin=2;  %minimum distance in y direction to search in
Ymax=30; %maximum distance in y direction to search in
             
X = (xr-xl)*rand+xl             %RANDOM x-point along line perpindicular to y-axis
Y = (Ymax-Ymin)*rand+Ymin       %RANDOM y-point along y-lidar axis

if yaw == 0 %the road is parallel to y-lidar axis

        RAND_NODE(1) = X;
        RAND_NODE(2) = Y;

else %projects point along random line parallel and within the road 
    
 %Solving y=mx+b for y=0 and x = Xrandom to find b
        B_rand = -m*X + 0; %random y-intercept based on X 
 
        RAND_NODE(1)= (Y- B_rand)/m; %RAND_NODE x value is then calulated based on Y
        RAND_NODE(2) = Y; %RAND_NODE Y value is same as Y
end
 
%SOLVING FOR THE DISTANCE TO THE RANDOM NODE
%INITIALIZES RAND_DIST TO A MAXIMUM VALUE WHICH WOULD BE 
%THE DISTANCE TO THE START OF THE TREE
RAND_DIST=((RAND_NODE(1)-TREE(1,1))^2+(RAND_NODE(2)-TREE(1,2))^2)^.5; 
        
%DETERMINING CLOSEST NODE TO THE RANDOM NODE
for i=1:1:NODES
    
    %SOLVING FOR THE DISTANCE TO THE RANDOM NODE FROM THE A NODE IN [TREE]
    TEMP_DIST=((RAND_NODE(1)-TREE(i,1))^2+(RAND_NODE(2)-TREE(i,2))^2)^.5;
    
    if (TEMP_DIST<=RAND_DIST)
        RAND_DIST=TEMP_DIST;               %MAKES THE CHECKED DISTANCE THE NEW DISTANCE
        CLOSE_NODE=TREE(i, 1:2);           %SETS THE CLOSEST NODE
        TEMP_NODE(3)=i;                    %MARKS WHAT NODE IT IS
    end
    
end
        
%LOCATION OF TEMPORARY NODE
TEMP_NODE(1)=CLOSE_NODE(1) + NODE_DIST*(RAND_NODE(1)-CLOSE_NODE(1))/RAND_DIST;   %X
TEMP_NODE(2)=CLOSE_NODE(2) + NODE_DIST*(RAND_NODE(2)-CLOSE_NODE(2))/RAND_DIST;   %Y
                
if (TEMP_NODE(2)<CLOSE_NODE(2))
    TEMP_NODE(3)=TREE(TEMP_NODE(3),3);
end


end