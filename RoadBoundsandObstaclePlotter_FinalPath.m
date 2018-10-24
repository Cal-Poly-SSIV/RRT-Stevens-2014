close all
VEHICLE_GEO_ACTUAL = [2 1];

for n = 1:length(Lidar_Data.time(:,1))

 FINAL_PATH = Final_Path.signals.values(:,:,n);
Enable = Toggle.signals.values(n,1);
plot(Lidar_Data.signals.values(:,1,n),Lidar_Data.signals.values(:,2,n),'LineWidth',2,'LineStyle','--');
hold on;
OBSTACLE_ARRAY = Obstacles.signals.values(:,:,n);
index = find(OBSTACLE_ARRAY(:,1),1,'last');
OBSTACLE_ARRAY = OBSTACLE_ARRAY(1:index,:);  
try
THREAT_ARRAY = ThreatObstacles.signals.values(:,:,n);
index = find(THREAT_ARRAY(:,1),1,'last');
THREAT_ARRAY = THREAT_ARRAY(1:index,:);  
catch none
end
xLimits = get(gca,'XLim');  %# Get the range of the x axis
yLimits = get(gca,'YLim');  %# Get the range of learthe y axis
for i =1:1:length(OBSTACLE_ARRAY(:,1))
    rectangle('position',[(OBSTACLE_ARRAY(i,1)-(OBSTACLE_ARRAY(i,3)/2)) (OBSTACLE_ARRAY(i,2)-(OBSTACLE_ARRAY(i,4)/2))... 
    OBSTACLE_ARRAY(i,3) OBSTACLE_ARRAY(i,4)],'LineWidth',3 );
%    arrowline([OBSTACLE_ARRAY(i,1),OBSTACLE_ARRAY(i,5)],[OBSTACLE_ARRAY(i,2),OBSTACLE_ARRAY(i,6)]);
end
try
 for i=1:1:length(THREAT_ARRAY(:,1))
      if((THREAT_ARRAY(i,3)~=0)&&(THREAT_ARRAY(i,4)~=0))
        rectangle('position',[(THREAT_ARRAY(i,1)-(THREAT_ARRAY(i,3)/2)) (THREAT_ARRAY(i,2)-(OBSTACLE_ARRAY(i,4)/2)) THREAT_ARRAY(i,3) THREAT_ARRAY(i,4)],'FaceColor','r' );
         %arrowline([THREAT_ARRAY(i,1),THREAT_ARRAY(i,5)],[THREAT_ARRAY(i,2),THREAT_ARRAY(i,6)]);
      end
 end
catch err
end
if Toggle.signals.values(n,1)>0
    filledCircle([0,0],0.3,100,'g'); 
elseif Toggle.signals.values(n,1)==0
    filledCircle([0,0],0.3,100,'r'); 
else
    filledCircle([0,0],0.3,100,'y'); 
end
br = (-RoadBounds.signals.values(2,1,n))/tan(RoadBounds.signals.values(3,1,n)*(pi/180)); 
m = -br/RoadBounds.signals.values(2,1,n);         
bl = (-RoadBounds.signals.values(1,1,n))/tan(RoadBounds.signals.values(3,1,n)*(pi/180)); 
ROADLINES=[m, bl, br]
x=-100:1:100;
y1=ROADLINES(1)*x+ROADLINES(3)
y2=ROADLINES(1)*x+ROADLINES(2)
plot(x,y1,x,y2,'LineWidth',2,'LineStyle','-.','Color',[0 0 0])
grid on;
% if(Enable==1)
for n = 1:length(FINAL_PATH(:,1))
    rectangle('position',[(FINAL_PATH(n,1)-(VEHICLE_GEO_ACTUAL(2)/2)) ...
        (FINAL_PATH(n,2)-(VEHICLE_GEO_ACTUAL(1)/2)) VEHICLE_GEO_ACTUAL(2)...
        VEHICLE_GEO_ACTUAL(1)],'FaceColor',[0 0.498039215803146 0])
end
% end
%  rectangle('position',[(-3.2258-0.0434961/2) (6.1251-0.0434961/2) 0.0434961 0.0434961],'LineWidth',3);
%  rectangle('position',[(-3.3895-0.32186/2) (6.00685-0.13343/2) 0.32186 0.13343],'LineWidth',3);
%  rectangle('position',[(-3.3285-0.0240363/2) (1.8856-0.0240363/2) 0.0240363 0.0240363],'LineWidth',3);
%  
xlim(xLimits);
ylim(yLimits);
% Create xlabel
xlabel('X Position (feet)','FontSize',14);
% Create ylabel
ylabel('Y Position (feet)','FontSize',14);
% Create title
title('LiDAR Scan With Parsed Obstacles and Road','FontSize',14);
  k = waitforbuttonpress;
%pause(.026);
clf
end