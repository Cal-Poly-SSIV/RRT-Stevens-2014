function [sys,x0]=mpc_switching_animation(t,x,u,flag,ts,x0,speed,avifile,...
    create_movie,yeq1,yeq2,OFF)
% MPC_SWITCHING_ANIMATION S-function for animating multi-MPC control of a
% two-mass system with inelastic impacts.

% Author: A. Bemporad
% Copyright 1990-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $

persistent hM1 hM11 hs1 hs2 hM2 hF href Mwidth j M delay text1 text2

% u(1) = position y1
% u(2) = position y2
% u(3) = force F
% u(4) = reference for y1
% u(5) = switching signal

scale=1;
if flag==2,
    sys=x0([1 2])';
    if OFF
        return
    end
    set(hM1,'Xdata',[u(1)*scale-Mwidth/2 u(1)*scale+Mwidth/2 u(1)*scale+Mwidth/2 u(1)*scale-Mwidth/2]');
    set(hM11,'Xdata',[u(1)*scale-Mwidth/2-0.2 u(1)*scale-Mwidth/2 u(1)*scale-Mwidth/2 u(1)*scale-Mwidth/2-0.2]');
    set(text1,'Position',[u(1)*scale-0.05 0.4 0]);
 
    set(hs1,'Xdata',[u(1) yeq1]');
    set(hs2,'Xdata',[yeq2 u(2)]');

    set(hM2,'Xdata',[u(2)*scale-Mwidth/2 u(2)*scale+Mwidth/2 u(2)*scale+Mwidth/2 u(2)*scale-Mwidth/2]');
    set(text2,'Position',[u(2)*scale-0.05 0 0]);
 
    set(hF,'Xdata',[u(1)*scale-max(u(3)/5,.1) u(1)*scale]');
    set(href,'Xdata',[u(4)*scale-.5 u(4)*scale+.5 u(4) u(4)]');
    %drawnow;
    j=j+1;
    if create_movie,
        M(j)=getframe(gcf);
    end
    
    drawnow;
    pause(delay);

elseif flag == 4 % Return next sample hit

    % ns stores the number of samples
    ns = t/ts;

    % This is the time of the next sample hit.
    sys = (1 + floor(ns + 1e-13*(1+ns)))*ts;

elseif flag==0,
    % NumContStates  = 0;
    % NumDiscStates  = 2;
    % NumOutputs     = 0;
    % NumInputs      = 2;
    % DirFeedthrough = 0;
    % NumSampleTimes = 0;

    sys=[0 2 0 5 0 0];

    x0=x0([1 2]);

    if OFF
        return
    end
% Initialize the figure for use with this simulation
    fig = findobj('Type','figure', 'Tag', 'mpc_switching_demo');
    if isempty(fig),
        fig=figure;
        set(fig,'Tag','mpc_switching_demo');
    end
    figure(fig);
    clf
    axis([-10 10 -0.4 0.8]);
    set(fig,'Position', [192   148   573   337]);
    grid
    hold on;

    Mwidth=0.5;
    u=x0([1 2])';
    r0=0; % Initial value of reference

    % Draw the floor under the masses
    patch([-10 10 8 -8],[-0.4 -0.4 -0.2 -0.2],[.4 .4 .4]);
    % Draw spring #1
    im=imread('mpc_switching_spring.jpg');
    hs1=image([u(1)*scale yeq1],[0.3 0.5],im);
    % Draw spring #2
    hs2=image([yeq2 u(1)*scale],[-0.1 0.1],im);
    % Draw Force
    im=imread('mpc_switching_force.jpg');
    hF=image([u(1)*scale u(1)*scale],[0.5 0.6],im);

    c1=[0 .7 0];   % Color of Mass 1
    c2=[0 0 .7]; % Color of Mass 2
    c3=[.4 .4 .7];  % Color of reference pointer
    ctext=[.8 .8 .8]; % Text color
    
    hM1=patch([u(1)*scale-Mwidth/2 u(1)*scale+Mwidth/2 u(1)*scale+Mwidth/2 u(1)*scale-Mwidth/2]',...
        [0.2 0.2 0.6 0.6],c1);

    hM11=patch([u(1)*scale-Mwidth/2-0.1 u(1)*scale-Mwidth/2 u(1)*scale-Mwidth/2 u(1)*scale-Mwidth/2-0.1]',...
        [0.15 0.1 0.3 0.25],c1);
    
    text1=text(u(1)*scale-0.05, 0.4, '1');
    set(text1,'FontWeight','demi','Color',ctext);

    hM2=patch([u(2)*scale-Mwidth/2 u(2)*scale+Mwidth/2 u(2)*scale+Mwidth/2 u(2)*scale-Mwidth/2]',...
        [-0.2 -0.2 0.2 0.2],c2);

    text2=text(u(2)*scale-0.05, 0,'2');
    set(text2,'FontWeight','demi','Color',ctext);

    href=patch([r0*scale-.5 r0*scale+.5 r0*scale r0*scale]',...
        [-0.3 -0.3 -0.2 -0.2],c3);

    if create_movie,
        M=[];
        M=getframe(fig);
        j=1;
    end

    delay=0.05*(1-speed);
    if delay<0,
        delay=0;
    end
    if delay>2,
        delay=2;
    end

elseif flag==9,
    if create_movie && ~OFF
        if ~isempty(avifile),
            h=figure;
            set(h, 'Tag', 'Movie', ...
                'numbertitle','off','name','Please wait, generating AVI ...',...
                'Position',[268   476   315    74],'MenuBar','none',...
                'Resize','off','NumberTitle','off','PaperPosition',get(0,'defaultfigurePaperPosition'),...
                'Color',[.5 .5 .5],'HandleVisibility','off');
            pause(0.5);
            movie2avi(M,avifile,'FPS',15,'COMPRESSION','Cinepak','Quality',85);
            set(h,'name','Done!');
            pause(0.5);
            close(h)
        end
    end
end;

