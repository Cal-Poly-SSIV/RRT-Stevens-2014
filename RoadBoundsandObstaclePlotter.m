close all
figure
for n = 1:length(Lidar_Data.time(:,1))
    plot(Lidar_Data.signals.values(:,1,n),Lidar_Data.signals.values(:,2,n));
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
yLimits = get(gca,'YLim');  %# Get the range of the y axis
for i =1:1:length(OBSTACLE_ARRAY(:,1))
    rectangle('position',[(OBSTACLE_ARRAY(i,1)-(OBSTACLE_ARRAY(i,3)/2)) (OBSTACLE_ARRAY(i,2)-(OBSTACLE_ARRAY(i,4)/2))... 
    OBSTACLE_ARRAY(i,3) OBSTACLE_ARRAY(i,4)] );
   % arrowline([OBSTACLE_ARRAY(i,1),OBSTACLE_ARRAY(i,5)],[OBSTACLE_ARRAY(i,2),OBSTACLE_ARRAY(i,6)]);
end
try
 for i=1:1:length(THREAT_ARRAY(:,1))
      if((THREAT_ARRAY(i,3)~=0)&&(THREAT_ARRAY(i,4)~=0))
        rectangle('position',[(THREAT_ARRAY(i,1)-(THREAT_ARRAY(i,3)/2)) (THREAT_ARRAY(i,2)-(OBSTACLE_ARRAY(i,4)/2))...
            THREAT_ARRAY(i,3) THREAT_ARRAY(i,4)],'FaceColor','r' );
         arrowline([THREAT_ARRAY(i,1),THREAT_ARRAY(i,5)],[THREAT_ARRAY(i,2),THREAT_ARRAY(i,6)]);
      end
 end
catch err
end
if Toggle.signals.values(n,1)>0
    filledCircle([0,0],1,100,'g'); 
elseif Toggle.signals.values(n,1)==0
    filledCircle([0,0],1,100,'r'); 
else
    filledCircle([0,0],1,100,'y'); 
end
br = (-RoadBounds.signals.values(2,1,n))/tan(RoadBounds.signals.values(3,1,n)*(pi/180)); 
m = -br/RoadBounds.signals.values(2,1,n);         
bl = (-RoadBounds.signals.values(1,1,n))/tan(RoadBounds.signals.values(3,1,n)*(pi/180)); 
ROADLINES=[m, bl, br] ;
x=-100:1:100;
y1=ROADLINES(1)*x+ROADLINES(3);
y2=ROADLINES(1)*x+ROADLINES(2);
plot(x,y1,'-*k',x,y2,'-.ok')
grid on;
xlim(xLimits);
ylim(yLimits);
%k = waitforbuttonpress ;
pause(.15)
clf
end