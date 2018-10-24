%This function calibrates the IMU, based on a specific calibration procedure.
function [output] = calibrate (IMULOG)

%Determine how much of the datalog was filled
[a, ~, c] = size(IMULOG);

%If the datalog overflowed, use datalog length
if a < c;
    c = a;
end

%Condense the data
idle = 19;

x = 1;
y = (x+1)*idle;

while y < c
    condensed(x, :) = IMULOG(y, :, c);
    x = x + 1;
    y = x*idle + 1;
end

%output = condensed;

%Arrange data in ascending order
sorted = sort(condensed);

%output = sorted;

%Append 7th column of zeroes for plotting
x = 1;
[a, ~] = size(condensed);

while x <= a
    condensed(x, 7) = x;
    x = x + 1;
end

%Plot data
subplot(2, 1, 1), plot(condensed(:, 7), condensed(:, 1), condensed(:, 7), condensed(:, 2), condensed(:, 7), condensed(:, 3));
subplot(2, 1, 2), plot(condensed(:, 7), sorted(:, 1), condensed(:, 7), sorted(:, 2), condensed(:, 7), sorted(:, 3));
legend ('x-axis', 'y-axis', 'z-axis');

%Create bins for low, middle, and high data points
y = 1;

while y <= 6
    bins(:, y) = hist(sorted(:, y), 3);
    y = y + 1;
end

bins(2, :) = bins(1, :) + bins(2, :);
bins(3, :) = bins(2, :) + bins(3, :);

bins = cat(1, [0 0 0 0 0 0], bins);

%output = bins;

%Average the data within the bins
y = 1;

while y <= 3
    
    x = 1;

    while x <= 3;
           
        averages(x, y) = mean(sorted((bins(x, y)+1):bins(x+1, y), y));
        
        x = x + 1;
        
    end
    
    y = y + 1;
    
end

%output = averages;

%Determine calibration constants
gravity(1, :) = (averages(3, :) - averages(1, :)) / 2;

accelg = 9.81; %m/s^2

calibration(1, :) = bsxfun(@rdivide, [accelg accelg accelg], gravity(1, :));
calibration(2, :) = averages(2, :);

%Test calibration constants
y = 1;

while y <= 3
    
    x = 1;

    while x <= 3;
           
        calibration(x+2, y) = calibration(1, y) * (averages(x, y) - calibration(2, y));
        
        x = x + 1;
        
    end
    
    y = y + 1;
    
end

output = calibration;