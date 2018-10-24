function GOAL = GET_GOAL(ROAD,ROADLINES)

%ROAD=[-3,8,-20];

xl=ROAD(1);  %perpendicular distance from lidar to left road boundary
xr=ROAD(2);  %perpendicular distance from lidar to right road boundary
yaw=ROAD(3); %angle between y-lidar coordinate and road 

m=ROADLINES(1);
GOAL_DIST= 30; %distance down the road the goal is from the car
xrr= abs(cosd(yaw)*xr); %closest distance to road from car on right
xlr= abs(cosd(yaw)*xl); %closest distance to road from car on left
SIGN = yaw/abs(yaw);

% car is aligned straight with road
if yaw == 0
        GOAL=[(xr+xl)/2,GOAL_DIST];
else

% car xl is the same as xr
if abs(xl)== xr
    Y=cosd(yaw)*GOAL_DIST;
end

% car on the left side of road
if abs(xl) < xr
    x_dist = xrr - (xlr + xrr)/2;
    w = sind(yaw)*x_dist;
    Y=cosd(yaw) * GOAL_DIST + SIGN*w; 
    
end

% car is on the right side of road
if abs(xl)> xr
    x_dist = xlr - (xlr + xrr)/2;
    w = sind(abs(yaw))*x_dist;
    Y=cosd(yaw) * GOAL_DIST +  SIGN*w;       
    
end

   % now using a centerline of road to find x value
   % if it is on the right side of road middle line will have - yint
    
        
       
    Bl= ROADLINES(2); %y-intercept of left road line
    Br= ROADLINES(3); %y-intercept of right road line
    Bc = (Bl + Br)/2; %y-intercept of center road line
       
      
    %road center line 
    X = (Y - Bc)/m; %X value of goal
    GOAL= [X,Y];
     
end

% 
% x=0:1:10;
% y1=m*x+br;
% y2=m*x+bl;
% plot(x,y1,'-*k',x,y2,'-.ok')
% hold on
% plot(GOAL(1,1),GOAL(1,2),'o')


end