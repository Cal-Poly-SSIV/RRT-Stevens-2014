function PLOT_OBJECTS(VEHICLE, VEHICLE_GEO, OBSTACLEA, ROAD, PATH, TIME)

RT=[50;-5];   

THETA=PATH(TIME,3);
LENGTH=VEHICLE_GEO(1);
WIDTH=VEHICLE_GEO(2);


    %CALCULATE VERTICIES OF THE VEHICLE
    %LOCATION OF THE FRONT CENTER
    TIP(1)=-LENGTH*sin(THETA)+PATH(TIME,1);  
    TIP(2)=LENGTH*cos(THETA)+PATH(TIME,2);
    
    %CALCULATE THE FRONT LEFT CORNER
    KARTER(1,1)=TIP(1)-(WIDTH/2)*cos(THETA);
    KARTER(5,1)=KARTER(1,1);
    KARTER(1,2)=TIP(2)-(WIDTH/2)*sin(THETA);
    KARTER(5,2)=KARTER(1,2);
    %CALCULATE THE FRONT RIGHT CORNER
    KARTER(2,1)=TIP(1)+(WIDTH/2)*cos(THETA);
    KARTER(2,2)=TIP(2)+(WIDTH/2)*sin(THETA);
    %CALCULATE THE REAR RIGHT CORNER
    KARTER(3,1)=PATH(TIME,1)+(WIDTH/2)*cos(THETA);
    KARTER(3,2)=PATH(TIME,2)+(WIDTH/2)*sin(THETA);
    %CALCULATE THE REAR LEFT CORNER
    KARTER(4,1)=PATH(TIME,1)-(WIDTH/2)*cos(THETA);
    KARTER(4,2)=PATH(TIME,2)-(WIDTH/2)*sin(THETA);

    axis([-15, 15, -5,25])
    
    OBSTACLEA(:,1)=OBSTACLEA(:,1)+OBSTACLEA(:,5)*PATH(TIME,5);
    OBSTACLEA(:,2)=OBSTACLEA(:,2)+OBSTACLEA(:,6)*PATH(TIME,5);
    
    SIZE=size(OBSTACLEA); %OBSTACLE array size
    PLOTOBSTACLENUMBER =SIZE(1); %Number of Obstacles
    PLOTINDEX= PLOTOBSTACLENUMBER; %Multiple Obstacle Index
    
    while (PLOTINDEX > 0)
        OBSTACLEP=OBSTACLEA((PLOTOBSTACLENUMBER-PLOTINDEX+1),:);
    
    %CALCULATE THE VERTICES OF THE OBSTACLE
    %FRONT LEFT
    OBSTACLER(1,1)=OBSTACLEP(1)-OBSTACLEP(4)/2;
    OBSTACLER(1,2)=OBSTACLEP(2)+OBSTACLEP(3)/2;
    OBSTACLER(5,1)=OBSTACLER(1,1);
    OBSTACLER(5,2)=OBSTACLER(1,2);
    
    %FRONT RIGHT
    OBSTACLER(2,1)=OBSTACLER(1,1)+OBSTACLEP(4);
    OBSTACLER(2,2)=OBSTACLER(1,2);
    %REAR RIGHT
    OBSTACLER(3,1)=OBSTACLER(2,1);
    OBSTACLER(3,2)=OBSTACLER(2,2)-OBSTACLEP(3);
    %REAR LEFT
    OBSTACLER(4,1)=OBSTACLER(1,1);
    OBSTACLER(4,2)=OBSTACLER(3,2);
    
    %OBSTACLER
    %KARTER
    
    %PLOT OBSTACLE
    plot(OBSTACLER(1:5,1),OBSTACLER(1:5,2),'red')
    hold on

    PLOTINDEX=PLOTINDEX - 1;
    
    end
    
    %hold on
    
    
    
    %PLOT THE VEHICLE
    plot(KARTER(1:5,1),KARTER(1:5,2))
    hold on
    
   
    
    %PLOT ROAD
    %LEFT SIDE
    plot([ROAD(1);ROAD(1)],RT(1:2),'G')
    hold on
    %RIGHT SIDE
    plot([ROAD(2);ROAD(2)],RT(1:2),'G')
    hold on
    
    
    
end