road=[-8,3,30];  %[x_left,x_right,yaw]

xl=road(1);  %perpendicular distance from lidar to left road boundary
xr=road(2);  %perpendicular distance from lidar to right road boundary
yaw=road(3); %angle between y-lidar coordinate and road 
             %yaw is positive in the counterclockwise direction

counter=0;
X1=0;
X2=0;
Y1= 20; %Subject to Change 20 feet in y direction from car
Y2= 2; %lower limit two feet in front of car

RAND_SPACE=zeros(2,2);  %SCALAR AND OFFSETS [XSCALAR YSCALAR; XOFFSET YOFFSET]
good = 0; %verifies if RAND_NODE is within the road boundaries 


% CREATES X BOUNDARIES FOR RAND_NODE TO BE IN
if yaw < 0
    
    x_extra= tand(abs(yaw))* (Y1-Y2);
    X2 = xr;
    X1 = xl - x_extra;
    
else
    x_extra= tand(abs(yaw))* (Y1-Y2);
    X1 = xl;
    X2 = xr + x_extra;
    
end



while (good == 0)
    
    counter= counter + 1;
RAND_SPACE(1,1)=(X2-X1);    %XSCALAR             [ft]
RAND_SPACE(1,2)=(Y1-Y2);    %YSCALAR             [ft]     
RAND_SPACE(2,1)=X1;         %XOFFSET FROM ZERO   [ft]
RAND_SPACE(2,2)=Y2;         %YOFFSET FROM ZERO   [ft]


%CREATES RANDOME NODE IN BOX 
RAND_NODE(1)=RAND_SPACE(1,1)*rand+RAND_SPACE(2,1);    %X
RAND_NODE(2)=RAND_SPACE(1,2)*rand+RAND_SPACE(2,2);    %Y 



% CHECKS TO SEE IF RANDOM NODE IS IN ROAD BOUNDARIES
if yaw<0
    
    y_int=xr/tand(abs(yaw));
    
if  RAND_NODE(2) <= (- y_int/xr) * RAND_NODE(1) + y_int && RAND_NODE(2) >= (- y_int/xr) * RAND_NODE(1) - xr/tand(abs(yaw))
    good = 1;
else 
    good = 0;
end

elseif yaw == 0
    good = 1;

else % yaw > 0
    
    y_int=-xl/tand(yaw);
    
    if   RAND_NODE(2) <= (y_int/-xl) * RAND_NODE(1) + y_int && RAND_NODE(2) >= (y_int/-xl) * RAND_NODE(1) + xl/tand(yaw)
       good = 1;
    else
       good = 0;
    end
end

end

RAND_NODE
          