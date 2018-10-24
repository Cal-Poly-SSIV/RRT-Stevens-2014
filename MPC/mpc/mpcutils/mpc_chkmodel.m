function [newmodel,newts,newxp0,newu1,uoff,yoff,xoff,dxoff]=mpc_chkmodel(...
    model,ts,offsets,xp0,u1,mvindex,myindex)
%MPC_CHKMODEL Check if 'model', 'ts', 'xp0', 'u1' are ok

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.16 $  $Date: 2007/11/09 20:46:47 $

verbose = mpccheckverbose;

ismodelss=isa(model,'ss');
if ~ismodelss,
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertPlantToSS'));
    end
    model=ss(model);

    % Use DARE to test detectability:
    if ~mpc_chkdetectability(model.A,model.C(myindex,:),model.ts), % System is not detectable
        model=minreal(model);
    end

    offsets.X=zeros(size(model.A,1),1);
    offsets.DX=offsets.X;
    if ~isempty(xp0),
        ctrlMsgUtils.error('MPC:utility:InvalidNoiseModelInitialState');
    end
end

% Delete input/output names, to avoid conflicts when augmenting the
% plant without adding names for new inputs/outputs
model.InputName(:) = {''};
model.OutputName(:) = {''};

% Check Offsets and augment model
xoff=offsets.X;
uoff=offsets.U;
yoff=offsets.Y;
dxoff=offsets.DX;

% Augment the model
[ny,nx]=size(model.c);

% Sample time
mts=model.ts;
if mts<0,
    if ts>0,
        if verbose,
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:AssumeSampleTimePlantModel',ts));
        end
        mts=ts;
        model.ts=ts;
    else
        ctrlMsgUtils.error('MPC:utility:NoSampleTimeForModel');
    end
end

% Add contribution of offset term
%iod=model.ioDelay;
%model.ioDelay=0*iod;
%set(model,'b',[model.b,dxoff],'d',[model.d,zeros(ny,1)],'inputdelay',[model.inputdelay;0]);
%model.ioDelay=[iod,zeros(ny,1)];

%PASCAL's suggestion: (Nov 17, 2005):
[a,b,c,d] = ssdata(model);
if any(model.ioDelay(:))
    % Cannot use SET to resize state-space model with I/O delays (R6a change)
    model = [model ss(a,dxoff,c,0,mts)]; %<< This doubles the state size
else
    set(model,'b',[b,dxoff],'d',[d,zeros(size(d,1),1)],'InputDelay',[model.InputDelay;0]);
end

% Name the additional signal as 'Offset'
ingroup=model.InputGroup;
% Convert possible old 6.xx cell format to structure, using mpc_getgroup
ingroup=mpc_getgroup(ingroup);
ingroup.Offset=size(model.b,2);
set(model,'InputGroup',ingroup);

% Check consistency of xp0
xp0=mpc_chkx0u1(xp0,nx,xoff,ctrlMsgUtils.message('MPC:utility:InitialStatePlantModel'));
xp0=xp0-xoff; % Initial condition for linearized plant

% Check consistency of u1
nu=length(mvindex);
u1=mpc_chkx0u1(u1,nu,uoff(mvindex),ctrlMsgUtils.message('MPC:utility:LastMoveField'));
u1=u1-uoff(mvindex); % Initial condition for linearized previous input

% model is continuous
if mts==0,
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertToDiscrete'));
    end

    newts=ts;
    try
        % Try is needed because C2D may give the error 'Initial state mapping G is not meaningful for
        % models with I/O delays.' when iodelays are present

        % Note: UserData field is lost during conversion !!!
        [model,TRmat]=c2d(model,ts);    
        % TRmat maps continuous initial conditions
        % into discrete initial conditions.  Specifically, if x0,u0
        % are initial states and inputs for the continuous time model,
        % then equivalent initial conditions for the discrete time model
        % are given by  xd0 = TRmat * [x0;u0],  ud0 = u0 .

        nutot=size(model.b,2);
        u0=zeros(nutot,1);  % Possible initial inputs for UDs are zero
        u0(mvindex)=u1;     % u1=initial input for MVs
        u0(end)=1;          % 1=initial input for the offset MD
        xp0=TRmat*[xp0;u0];

        utoff=uoff;     % offsets for MVs+UDs
        utoff(end+1)=0; % offset for the offset MD=1

        dxoff=dxoff*ts; % Maps continuous-time DX offset into discrete-time DX offset
        xoff=TRmat*[xoff(:);utoff(:)];
        dxoff=TRmat*[dxoff(:);0*utoff(:)];

        %if norm(xp0)>0 & norm(u1)>0 & norm(TRmat(:,nx+1:size(TRmat,2)))>0,
        %   % Usually this never happens
        %   disp('Warning: initial state information might be wrong')
        %   disp('         because of continuous->discrete conversion.')
        %end
    catch ME
        % Note: UserData field is lost during conversion !!!
        if model.ts==0,
            model=c2d(model,ts);    
        end
        if norm(xp0)>0,
            if verbose,
                fprintf('-->%s',ctrlMsgUtils.message('MPC:object:InitialX'));
            end
        end
        xp0=zeros(size(model.A,1),1);
        if norm(xoff)>0 || norm(dxoff)>0,
            if verbose,
                fprintf('-->%s',ctrlMsgUtils.message('MPC:object:InitialXffset'));
            end
        end
        xoff=xp0;
        dxoff=xp0;
    end
% inherit controller sampling time from model    
elseif isempty(ts) || abs(ts-mts)<=1e-10,
    newts=mts; 
% ts different from mts
elseif abs(ts-mts)>1e-10, 
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ResamplePlantModel'));
    end
    try
        model=d2d(model,ts);
    catch ME
        throw(ME);
    end
    %takes out possible imaginary parts
    %set(model,'a',real(model.a),'b',real(model.b));
    newts=ts;
    % No, state dimension may not be consistent in case d2d augments the
    % order of the system
    xextra=zeros(size(model.A,1)-length(xp0),1);
    xp0=[xp0;xextra];
    xoff=[xoff(:);xextra];
    dxoff=[dxoff(:);xextra];
    if norm(xp0,'inf')>1e-10,
        warning('MPC:computation:X0Incorrect',ctrlMsgUtils.message('MPC:computation:X0Incorrect'));    
    end
    if norm(xoff,'inf')>1e-10,
        warning('MPC:computation:XOffsetIncorrect',ctrlMsgUtils.message('MPC:computation:XOffsetIncorrect'));
    end
    if norm(dxoff,'inf')>1e-10,
        warning('MPC:computation:XDotIncorrect',ctrlMsgUtils.message('MPC:computation:XDotIncorrect'));
    end
end

% Eventually transforms I/O delays into poles in z=0
if hasdelay(model),
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:DelayToSS'));
    end
    model=delay2z(model);
    % Pad xp0 with zeros
    % Maybe only works for SISO
    aux=size(model.A,1)-length(xp0);
    xp0=[xp0(:);zeros(aux,1)];
    if norm(u1)>0,
        warning('MPC:computation:U0Incorrect',ctrlMsgUtils.message('MPC:computation:U0Incorrect'));        
    end
    xoff=[xoff(:);zeros(aux,1)];
    dxoff=[dxoff(:);zeros(aux,1)];
end

newmodel=model;
newxp0=xp0;
newu1=u1;
