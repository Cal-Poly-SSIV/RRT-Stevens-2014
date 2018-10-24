%This function calibrates the IMU, based on a specific calibration procedure.
function [output] = calibrateRT (IMULOG)

%Determine how much of the datalog was filled
[a, ~, c] = size(IMULOG);

%If the datalog overflowed, use datalog length
if a < c;
    c = a;
end

%Condense the data
idle = 4;

x = 1;
y = (x+1)*idle;

while y < c
    if (IMULOG(y, 1, c)) < 1024
        condensed(x, :) = IMULOG(y, :, c);
        x = x + 1;
    end
    y = y + idle;
end

y = 1;

while y <= 6
      
    averages(1, y) = mean(condensed(:, y));
 
    y = y + 1;
    
end

save constants averages;

output = averages;

