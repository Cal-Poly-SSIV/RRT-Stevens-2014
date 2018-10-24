%EC Rand_Space Development based on lidar coordinates.



yaw = -30;
xr= 8;
xl = -3.54; 

Y1= 10;
Y2= 2; 

if yaw < 0
    
    x_extra= tand(abs(yaw))* (Y1-Y2);
    X2 = xr;
    X1 = xl - x_extra;
    
else
    x_extra= tand(abs(yaw))* (Y1-Y2);
    X1 = xl;
    X2 = xr + x_extra;
    
end
    
    
    