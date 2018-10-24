function [newmodel,newunindex,newxd0,nnUMD,nnUMDyint,nxumd,outdistchannels,indistchannels]=...
    mpc_chkumdmodel(...
    model,umdmodel,xd0,channels,magnitude,order,unindex,myindex,nutot,...
    outmodelflag,out_umdmodel)
%MPC_CHKUMDMODEL Check Model.Disturbance and eventually augment the system

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2007/11/09 20:40:21 $  


verbose = mpccheckverbose;

[nx,nutot]=size(model.B);
indistchannels=[];
if isempty(umdmodel) && ~isempty(unindex),
    % Default: an integrator for each unmeasured disturbance, i.e.
    %          step-like unmeasured disturbances, IF the system remains
    %          observable

    A=model.A;
    B=model.B;
    C=model.C;
    D=model.D;
    indistchannels=[];
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:NoModelDisturbanceGeneral'));
    end
        
    j=0;
    for i=1:length(unindex),
        nx1=size(A,1);
        B1=[B(:,unindex(i));zeros(j,1)];
        A1=[A,B1;zeros(1,nx1),1];
        C1=[C,D(:,unindex(i))];
        
        % Observability test
        % obs=rank(obsv(A1,C1(myindex,:))); % Use default rank tolerance
        
        % Use PBH test for observability of mode z=1:
        obs=rank([eye(nx1+1)-A1;C1(myindex,:)]);
        
        if obs==nx1+1,
            if verbose,
                fprintf('   %s\n',ctrlMsgUtils.message('MPC:object:NoModelDisturbance1',unindex(i)));
            end
            A=A1;
            C=C1;
            j=j+1;
            indistchannels=[indistchannels i];
        else
            if verbose,
                fprintf('   %s\n',ctrlMsgUtils.message('MPC:object:NoModelDisturbance2',unindex(i)));                
            end
        end
    end
    % indistchannels=UMD channels where integrators must be added
    nun=length(unindex);
    nindist=length(indistchannels);
    notindist=setdiff(1:nun,indistchannels);
    M=eye(nun);
    M(notindist,notindist)=0;
    umdmodel=M*tf(1,[1 0]);
    nxumd=nindist;

    %umdx0=zeros(nun,1);

    %% Default: a random noise with unit covariance matrix
    %%          for each unmeasured disturbance
    %nun=length(unindex);
    %umdmodel=tf(eye(nun));
end

if isa(umdmodel,'idmodel'),
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertIDToSS'));
    end
    % Convert umdmodel to SS:
    umdmodel=mpc_id2ss(umdmodel);
end

if ~isa(umdmodel,'ss'),
    if norm(xd0)>0,
        ctrlMsgUtils.error('MPC:utility:InvalidUMDModelInitialState');
    else
        xd0=[]; % Zero initial states are emptied, to alleviate the user for wrong dimensions of zero vectors
    end
    umdmodel=ss(umdmodel);
    if ~isempty(umdmodel),
        % Use DARE to test detectability
        if ~mpc_chkdetectability(umdmodel.A,umdmodel.C,umdmodel.ts), % System is not detectable
            umdmodel=minreal(umdmodel);
        end
    end
end

if isempty(umdmodel.a) && isempty(umdmodel.b) && isempty(umdmodel.c) && (norm(umdmodel.d,'inf')==0),
    % No unmeasured input disturbance
    newb=model.b;
    newb(:,unindex)=newb(:,unindex)*0;
    newd=model.d;
    newd(:,unindex)=newd(:,unindex)*0;
    
    
    set(model,'b',newb,'d',newd);
    newmodel=model;
    newunindex=unindex;
    
    nxumd=0;
    nnUMD=length(unindex); % Number of white noise inputs to Model.Disturbance
else
    %noumd=0; % Model.Disturbance is specified
     Cbar=umdmodel.c;
    nxumd=size(Cbar,2); % Number of states in umdmodel, which will
    % be appended below the states of MODEL
    
    nun=length(unindex);
    if nun~=size(Cbar,1),
        ctrlMsgUtils.error('MPC:utility:InvalidUMDModel',nun);
    end
    
    ts=model.Ts;
    nts=umdmodel.Ts;
    
    if nts<0,
        if ts>0,
            if verbose,
                fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:AssumeSampleTimeUMDModel',ts));            
            end
            nts=ts;
            umdmodel.ts=ts;
        else
            ctrlMsgUtils.error('MPC:utility:InvalidUMDModelSampleTime');
        end
    end

    if nts==0,
        umdmodel=c2d(umdmodel,ts);    % Note: UserData field is lost during conversion !!!
        
    elseif abs(ts-nts)>1e-10, % ts different from nts
        if verbose,
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:UMDModelresample',ts));                    
        end
        try
            umdmodel=d2d(umdmodel,ts);
        catch ME
            ctrlMsgUtils.error('MPC:utility:InvalidUMDModelD2D',ME.message);        
        end
        
        %takes out possible imaginary parts
        set(umdmodel,'a',real(umdmodel.a),'b',real(umdmodel.b));
    end
    if hasdelay(umdmodel),
        %umdmodel=d2d(umdmodel,'nodelay');
        if verbose,  
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertDelayToSS'));
        end
        umdmodel=delay2z(umdmodel);
    end   
    
    
    % Augment the system
    A=model.a;
    B=model.b;
    D=model.d;
    
    Bd=B(:,unindex);
    Dd=D(:,unindex);
    
    Bbar=umdmodel.b;
    Dbar=umdmodel.d;
    [nxumd,nubar]=size(Bbar); 
    
    Cbar=umdmodel.c; % This may have changed after d2d or delay2z

    % Initialize new matrices B,D
    newb=[B;zeros(nxumd,nutot)]; % Just adds zeros
    newd=D;
    
    if nun==nubar, % umdmodel is square, so simply replace d(t) with n(t)
        
        newb(:,unindex)=[Bd*Dbar;Bbar];
        newd(:,unindex)=Dd*Dbar;
        
    elseif nun>nubar,  % umdmodel is not square, must update also unindex
        
        % n(t) has dimension lower than d(t). 
        keep=unindex(1:nubar); 
        cut=unindex(nubar+1:nun);
        
        newb(:,keep)=[Bd*Dbar;Bbar];
        newb(:,cut)=[];
        newd(:,keep)=Dd*Dbar;
        newd(:,cut)=[];
        unindex=keep(:);
        
    else %if nun<nubar    % umdmodel is not square, must update also unindex
        
        % n(t) has dimension greater than d(t). 
        B2=[Bd*Dbar;Bbar];
        D2=Dd*Dbar;
        
        newb(:,unindex)=B2(:,1:nun);   % d(t) is replaced by the first nun components
        % of n(t),
        newb=[newb,B2(:,nun+1:nubar)]; % the last (nubar-nun) components of n(t)
        % are appended at the end of u(t)
        
        newd(:,unindex)=D2(:,1:nun);   % idem
        newd=[newd,D2(:,nun+1:nubar)]; % idem   
        
        unindex=[unindex(:);nutot+(1:nubar-nun)];
    end
    
    model=ss([A, Bd*Cbar;zeros(nxumd,nx), umdmodel.a],...
        newb,[model.c,Dd*Cbar],newd,model.ts);
    
        %     % After adding the input disturbance model, the overall system may have
        %     % become unobservable
        %     theta=obsv(model.A,model.C(myindex,:));
        %     obs=rank(theta,0);
        %     if obs<size(model.A,1),
        %         error('mpc:mpc_chkumdmodel:obsv',...
        %             sprintf('%s%s',...
        %             'The series interconnection of input disturbance and plant models is unobservable.\n',...
        %             'You should perhaps change Model.Disturbance (see also GETINDIST and SETINDIST)\n'));
        %     end
        %     % Now check for "numerical" observability
        %     obs=rank(theta);
        %     if obs<size(model.A,1),
        %         warning('mpc:mpc_chkumdmodel:obsv',...
        %             sprintf([...
        %             'The series interconnection of input disturbance and plant models is almost unobservable,\n',...
        %             'the condition number of the observability matrix of the overall system is %g.\n',...
        %             'You should perhaps change Model.Disturbance (see also GETINDIST and SETINDIST)\n'],...
        %             cond(theta)));
        %     end

    newmodel=model;
    newunindex=unindex;
    
    nnUMD=nubar; % Number of white noise inputs to Model.Disturbance
    
end

%if ~isa(integr_flag,'double'),
%   error('Plant.DefaultDisturbanceIntegrators should be either 0 or 1');
%end
%if isempty(integr_flag),
%   integr_flag=1;
%end
%if ~(integr_flag==1) & ~(integr_flag==0),
%   error('Plant.DefaultDisturbanceIntegrators should be either 0 or 1');
%end   

A=model.A;
B=model.B;
C=model.C;
D=model.D;
ts=model.ts;
[ny,nx]=size(C);
[nx,nu1]=size(B);

outdistchannels=[];
if ~outmodelflag, % Adds default output integrators  
    
    %if integr_flag,
    if ~isempty(channels),
        % Now try to add one integrator per measured output. Outputs are ordered by weight 
        % (that's why 'weight' is needed), and we try to add an integrator on outputs one by one,
        % starting from the most weighted. 
        
        I=eye(ny);
        h=0;
        
        for i=order, % starts with the most weighted
            if ismember(i,channels);
                
                nx1=size(A,1);
                A1=[A,zeros(nx1,1);zeros(1,nx1),1];
                C1=[C,zeros(ny,1)];
                C1(i,nx1+1)=magnitude(i);
                
                
                % Observability test
                %   obs=rank(obsv(A1,C1(myindex,:))); % Use default rank tolerance
                
                % Use PBH test for observability of mode z=1:
                obs=rank([eye(nx1+1)-A1;C1(myindex,:)]);
                
                if obs==nx1+1,
                    if ismember(i,myindex),
                        if verbose,
                            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:WhiteNoiseAdded',i));
                        end
                    else
                        if verbose,
                            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:IntegratorAddedToUMDModel',i));
                        end
                    end
                    h=h+1;
                    A=A1;
                    C=C1;
                    outdistchannels=[outdistchannels i];
                end
            end
        end
        
        nnUMDyint=h; % number of added output integrators driven by white noise
        
        B=[B,zeros(nx,h);zeros(h,nutot),ts*eye(h)];
        D=[D,zeros(ny,h)];
        
        newmodel=ss(A,B,C,D,ts);
        
        newunindex=[unindex;nutot+(1:h)']; % Total unmeasured disturbances
    else
        nnUMDyint=0;
    end

    newxd0=mpc_chkx0u1(xd0,nxumd,zeros(nxumd,1),ctrlMsgUtils.message('MPC:utility:InitialStateUnmeasuredDisturbanceModel'));
    newxd0=[newxd0;zeros(nnUMDyint,1)];
    
    nxumd=nxumd+nnUMDyint;

else
    % Generic output disturbance model
    
    % We assume here out_umdmodel was already checked in SETDISTURB.M, and
    % that it is therefore a valid discrete-time LTI model
    
    [Ay,By,Cy,Dy]=ssdata(out_umdmodel);
    [nyo,nxo]=size(Cy);
    [nxo,nuo]=size(By);
    
    % Extend state-space model (out_umdmodel is additive on output vector)
    A=[A,zeros(nx,nxo);
        zeros(nxo,nx),Ay];
    C=[C,Cy];
    
    %     %theta=obsv(A,C);
    %     %if rank(theta,0)<nx+nxo,
    %     %    error('mpc:mpc_chkumdmodel:outdistobsv','Invalid output disturbance model, overall system is unobservable');
    %     %end
    %     %if rank(theta)<nx+nxo,
    %     if ~mpc_chkdetectability(A,C,1), % System is not detectable
    %         warning('mpc:mpc_chkumdmodel:outdistobsv',...
    %         'Output disturbance model may be invalid, the overall system is not detectable');
    %     end

    
    B=[B,zeros(nx,nuo);
        zeros(nxo,nu1),By];
    D=[D,Dy];
    
    newmodel=ss(A,B,C,D,ts);

    nnUMDyint=nuo; % number of white noise signals driving output unmeasured disturbance model
    newunindex=[unindex;nutot+(1:nyo)']; % Total unmeasured disturbances
    
    nxumd=nxumd+nxo;
    %newxd0=zeros(nxo,1);
    newxd0=zeros(nxumd,1);
end


% end of mpc_chkumdmodel
