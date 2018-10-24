function  ROAD  = GET_ROAD( ROADLINES)

%THIS PROGRAM CREATES THE ROAD BOUNDARY LINES BASED ON 

%ROADLINES=[1.7321 5.1962 -13.8564];

m= ROADLINES(1); 
bl=ROADLINES(2);
br= ROADLINES(3);

yaw=atand(1/m); %perpendicular distance from lidar to left road boundary
%yaw is positive in the counterclockwise direction

xr = -br*tand(yaw); %perpendicular distance from lidar to right road boundary

xl= -bl*tand(yaw); %angle between y-lidar coordinate and road [degrees]

ROAD=[xl,xr,yaw]; 

end

