figure(2)
PLOT_OBJECTS(VEHICLE, VEHICLE_GEO, OBSTACLE, ROAD, PATH, 1)
hold on
axis([-10, 10, -10,50])
%PLOT THE PATH IN BLUE
plot(FINAL_PATH(1:(PATH_COUNT),1), FINAL_PATH(1:(PATH_COUNT),2))
%axis([-10, 10, -10,50])
%PLOT THE TREE IN RED
plot(FINAL_TREE(1:FINAL_NODES,1),FINAL_TREE(1:FINAL_NODES,2),'R')


for n = 2: (length(FINAL_PATH(:,1))-1)
x = linspace(FINAL_PATH(n-1,1),FINAL_PATH(n+1,1),10);
Beta = FINAL_PATH(n,4)*pi/180 + FINAL_PATH(n,3);
steer = tan(pi/2+Beta)*(x-FINAL_PATH(n,1))+FINAL_PATH(n,2);
heading = (tan(FINAL_PATH(n,3)+pi/2))*(x-FINAL_PATH(n,1))+FINAL_PATH(n,2);
plot(x,heading,'r',x,steer,'k')
%plot(x,heading,'r')
end
axis([-10, 10, -10,50])