function OBSTACLEA=OBSTACLE_MATRIX(OBSTACLERAW)

n = size(OBSTACLERAW);
N = n(2);
NO = N/6;
i = NO;
z = 1;

 while (i > 0) 
 OBSTACLEA((NO-i+1),:)=[OBSTACLERAW(z),OBSTACLERAW(z+1),OBSTACLERAW(z+2),OBSTACLERAW(z+3),OBSTACLERAW(z+4),OBSTACLERAW(z+5)];
 i=i-1;
 z=z+6;
 end

end
 
 
    



  