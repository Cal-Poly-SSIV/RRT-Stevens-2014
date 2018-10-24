
function ROADLINES = GET_ROADLINES(ROAD)

%ROAD=[-3,8,30];

%THIS PROGRAM CREATES THE ROAD BOUNDARY LINES BASED ON 

xl  = ROAD(1) %perpendicular distance from lidar to left road boundary
xr  = ROAD(2) %perpendicular distance from lidar to right road boundary
yaw = ROAD(3) %angle between y-lidar coordinate and road [degrees]
%yaw is positive in the counterclockwise direction


%RIGHT ROAD EQUATION  y= m *x + br

br = (-xr)/tan(yaw*pi/180); %y-intercept
m = -br/xr;         %slope


%LEFT ROAD EQUATION y= m *x + bl

bl = (-xl)/tan(yaw*pi/180); %y-intercept

ROADLINES=[m, bl, br] ;

end
