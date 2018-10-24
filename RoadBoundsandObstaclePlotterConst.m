clc
close all
figure
hold on;
plot(-Run_1(:,2),Run_1(:,1));
OBSTACLE_ARRAY = Obstacles.signals.values(:,:,1);
index = find(OBSTACLE_ARRAY(:,1),1,'last');
OBSTACLE_ARRAY = OBSTACLE_ARRAY(1:index,:);  
for i =1:1:length(OBSTACLE_ARRAY(:,1));
    rectangle('position',[(OBSTACLE_ARRAY(i,1)-(OBSTACLE_ARRAY(i,3)/2)) (OBSTACLE_ARRAY(i,2)-(OBSTACLE_ARRAY(i,4)/2))... 
    OBSTACLE_ARRAY(i,3) OBSTACLE_ARRAY(i,4)] );
end
xLimits = get(gca,'XLim');  %# Get the range of the x axis
yLimits = get(gca,'YLim');  %# Get the range of the y axis
br = (-RoadBounds.signals.values(2,1,1))/tand(RoadBounds.signals.values(3,1,1)); 
m = -br/RoadBounds.signals.values(2,1,1);         
bl = (-RoadBounds.signals.values(1,1,1))/tand(RoadBounds.signals.values(3,1,1)); 
ROADLINES=[m, bl, br] ;
x=-100:1:100;
y1=ROADLINES(1)*x+ROADLINES(3);
y2=ROADLINES(1)*x+ROADLINES(2);
plot(x,y1,'-*k',x,y2,'-.ok')
grid on;
xlim(xLimits);
ylim(yLimits);