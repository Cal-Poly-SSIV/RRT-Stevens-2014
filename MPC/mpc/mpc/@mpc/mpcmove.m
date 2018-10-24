function [u, Info] = mpcmove(MPCobj,state,y,r,v)
%MPCMOVE computes the current manipulated plant inputs for MPC.
%
%   [u, Info]=MPCMOVE(MPCobj,x,y,r,v)
%
%   MPCobj = an MPC object specifying the controller to be used.
%   x = current extended state vector, an mpcstate object. 
%   y = current measured plant outputs.
%   r = current setpoints for plant outputs.
%   v = current measured disturbances.
%
%   u = manipulated plant inputs computed by MPC, to be used in
%     the next sampling time.
%   Info = structure giving details of the optimal control calculations, with fields
%     Info.Uopt = optimal input sequence
%         .Yopt = optimal output sequence
%         .Xopt = optimal state sequence
%         .Topt = time sequence 0,1,...p-1 (p=prediction horizon) 
%         .Slack = ECR slack variable at optimum
%         .Iterations = number of iterations needed by the QP solver
%         .QPCode = exit code from QP solver
%
%
%   r/v can be either a sample (no future reference/disturbance known) 
%   or a sequence of samples (when a preview anticipative effect is desired). 
%   The last sample is extended constantly over the horizon, to obtain the 
%   correct size
%
%   Note:  upon the first call, if the input variable x is omitted a zero
%   state object will be constructed.
%
%   Use this same form in all subsequent calls.
%
%   See also ESTIMATOR, MPC, SIM, MPCSTATE.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2008/06/13 15:25:47 $   

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','mpcmove');
end

if nargin<2 || isempty(state) || ~isa(state,'mpcdata.mpcstate')
    ctrlMsgUtils.error('MPC:computation:InvalidState','mpcmove');    
end

MPCData=getmpcdata(MPCobj);
InitFlag=MPCData.Init;

if nargout>=2,
    save_flag='saveQPmodel';
else
    save_flag='base';
end

if strcmp(save_flag,'saveQPmodel'),
    if ~isfield(MPCData,'MPCstruct'),
        InitFlag=0;
    else
        if ~isfield(MPCData.MPCstruct,'QPmodel'),
            InitFlag=0;
        end
    end
end

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer) 
    try
        MPCstruct=mpc_struct(MPCobj,[],save_flag); % xmpc0=[]
    catch ME
        throw(ME);
    end
    MPCobj = mpc_updatempcdata(MPCobj,MPCstruct,1,1,1);        
    % Before invoking SS, update object (init, ready) when necessary   
    if ~isempty(inputname(1))
        assignin('caller',inputname(1),MPCobj);
    end
else
    MPCstruct=MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct
nu=MPCstruct.nu;
nv=MPCstruct.nv;
nym=MPCstruct.nym;
nx=MPCstruct.nx;
ny=MPCstruct.ny;
nxQP=MPCstruct.nxQP;

A=MPCstruct.A;
Bu=MPCstruct.Bu;
Bv=MPCstruct.Bv;
Cm=MPCstruct.Cm;
Dvm=MPCstruct.Dvm;
PTYPE=MPCstruct.PTYPE;
M=MPCstruct.M;
MuKduINV=MPCstruct.MuKduINV;
KduINV=MPCstruct.KduINV;
Kx=MPCstruct.Kx;
Ku1=MPCstruct.Ku1;
Kut=MPCstruct.Kut;
Kr=MPCstruct.Kr;
Kv=MPCstruct.Kv;
Jm=MPCstruct.Jm;
DUFree=MPCstruct.DUFree;
zmin=MPCstruct.zmin;
rhsc0=MPCstruct.rhsc0;
Mlim=MPCstruct.Mlim;
Mx=MPCstruct.Mx;
Mu1=MPCstruct.Mu1;
Mv=MPCstruct.Mv;
rhsa0=MPCstruct.rhsa0;
TAB=MPCstruct.TAB;
optimalseq=MPCstruct.optimalseq;
utarget=MPCstruct.utarget;
degrees=MPCstruct.degrees;
uoff=MPCstruct.uoff;
yoff=MPCstruct.yoff;
voff=MPCstruct.voff;
myoff=MPCstruct.myoff;
maxiter=MPCstruct.maxiter;

p=MPCobj.PredictionHorizon;
xoff=MPCstruct.xoff;

% Output measurement
if nargin<3,
    y=[];
end
if isempty(y),
    y=zeros(nym,1);
else
    if ~isa(y,'double') || ~all(isfinite(y(:)))
        ctrlMsgUtils.error('MPC:computation:InvalidMeasurement','mpcmove');            
    else
        [n,m]=size(y);
        if n*m~=nym, 
            ctrlMsgUtils.error('MPC:computation:InvalidMeasurementSize',nym);
        end
        y=y(:)-myoff;
    end
end

% Reference signal
if nargin<4,
    r=[];
end
if isempty(r),
    r=yoff';
    n=1;
else
    if ~isa(r,'double') || ~all(isfinite(r(:)))
        ctrlMsgUtils.error('MPC:computation:InvalidSetpoint','mpcmove');            
    else
        [n,m]=size(r);
        if n==ny,
            r=r'; % Puts it as a row vector
            m=ny;
            n=1;
        end
        if m~=ny, 
            ctrlMsgUtils.error('MPC:computation:InvalidSetpointSize',ny);                        
        end
    end
end

if n==1,
    % no preview, r has dimension 1-by-ny
    r=r-yoff';
    r=ones(p,1)*r;
else
    % preview is on
    r=r-ones(n,1)*yoff';
    if n>p,
        r=r(1:p,:);
    elseif n<p,
        r=[r;ones(p-n,1)*r(n,:)];
    end
end
r=r';
r=r(:);    %Put r in one column


% Measured disturbance signal
% Here nv = number of true measured disturbances + 1 (because offsets are treated as MDs)
if nargin<5,
    v=[];
end
if isempty(v),
    v=voff';
    n=1;
else
    if ~isa(v,'double') || ~all(isfinite(v(:)))
        ctrlMsgUtils.error('MPC:computation:InvalidMeasuredDisturbance','mpcmove');            
    else
        [n,m]=size(v);
        if n==nv-1,
            v=v'; % Puts it as a row vector
            m=nv-1;
            n=1;
        end
        if m~=nv-1, 
            ctrlMsgUtils.error('MPC:computation:InvalidMeasuredDisturbance',nv-1);                                    
        end
    end
end

if n==1,
    % no preview, v has dimension 1-by-nv-1
    v=v-voff';
    v=[v,1]; % Add measured disturbance for offsets
    v=ones(p+1,1)*v;
else
    % preview is on
    v=v-ones(n,1)*voff';
    if n>p+1,
        v=v(1:p+1,:);
    elseif n<p,
        v=[v;ones(p+1-n,1)*v(n,:)];
    end
    v=[v,ones(p+1,1)]; % Add measured disturbance for offsets
end
v=v';
v=v(:);  %Put v in one column 

nxp=MPCstruct.nxp;
nxumd=MPCstruct.nxumd;
nxnoise=MPCstruct.nxnoise;

try
    xp=mpc_chkstate(state,'Plant',nxp,xoff(1:nxp));
    xd=mpc_chkstate(state,'Disturbance',nxumd,xoff(nxp+1:nxp+nxumd));
    xn=mpc_chkstate(state,'Noise',nxnoise,xoff(nxp+nxumd+1:end));
    uold=mpc_chkstate(state,'LastMove',nu,uoff);
catch ME
    throw(ME);
end
x=[xp;xd;xn]; % offset-free current state

% Measurement update of state observer
yest=Cm*x+Dvm*v(1:nv);
x=x+M*(y-yest);  % (NOTE: what is called L here is called M in KALMAN's help file)

% Solves MPC optimization problem
isunconstr=(PTYPE==2);
useslack=(PTYPE==0);

if isempty(Kv),
    vKv=zeros(1,degrees);
    if ~isunconstr,
        Mvv=zeros(size(Mlim));
    end
else
    vKv=v'*Kv;
    if ~isunconstr,
        Mvv=Mv*v;
    end
end


xQP=x(1:nxQP); % Only these first nx states are fed back to the QP problem
% (i.e., multiplied by the Kx gain)

% Solves optimization problem
try
    if isunconstr,
        [zopt,slack,how,iter]=mpc_solve([],KduINV,Kx,Ku1,Kut,Kr,[],[],...
            [],[],[],[],[],[],Jm,DUFree,...
            xQP,uold,utarget,r,vKv,...
            nu,p,degrees,optimalseq,isunconstr,useslack,maxiter);

    else
        [zopt,slack,how,iter]=mpc_solve(MuKduINV,KduINV,Kx,Ku1,Kut,Kr,zmin,rhsc0,...
            Mlim,Mx,Mu1,Mvv,rhsa0,TAB,Jm,DUFree,...
            xQP,uold,utarget,r,vKv,...
            nu,p,degrees,optimalseq,isunconstr,useslack,maxiter);
    end
catch ME
    throw(ME);
end

% Compute the current input (previous input + new input increment)
u=uold+zopt(1:nu); % The first delta-u move is always a degree of freedom

%%% BEGIN - Compute Optimal Trajectories
if nargout>=2,
    % Compute optimal sequence of inputs U
    duopt=Jm*zopt;
    for i=1:nu,
        uopt(:,i)=cumsum(duopt(i:nu:p*nu))+uold(i)+uoff(i);
    end
    Ar=MPCstruct.Ar;
    Bur=MPCstruct.Bur;
    Bvr=MPCstruct.Bvr;
    Cr=MPCstruct.Cr;
    Dvr=MPCstruct.Dvr;
    %Dur=MPCstruct.Dur;
    ts=MPCstruct.ts;        
    
    yopt=zeros(p,ny);
    xopt=zeros(p+1,MPCstruct.nxQP);
    topt=zeros(p+1,1);
    for t=1:p+1,
        vv=v((t-1)*nv+1:t*nv);
        xopt(t,:)=(xQP+xoff(1:nxQP))';
        topt(t,:)=ts*(t-1);
        if t<p+1,
            uu=uopt(t,:)'-uoff;
            xQP=Ar*xQP+Bur*uu+Bvr*vv;
            %yopt(t,:)=(Cr*xQP+Dvr*vv+Dur*uu+yoff)';
            yopt(t,:)=(Cr*xQP+Dvr*vv+yoff)';  % Assumption: no direct feedthrough from MV's to any output
        end
    end
    % Only returns optimal trajectories for t=0,...,p-1
    Info=struct('Uopt',uopt,'Yopt',yopt(1:p,:),'Xopt',xopt(1:p,:),'Topt',topt(1:p,:),'Slack',slack,...
        'Iterations',iter,'QPCode',how);
end
%%% END - Compute Optimal Trajectories

% Time update of state observer (based on the full model Plant+Disturbance+Noise)

xnew=A*x+Bu*u+Bv*v(1:nv);

%% Rebuilds optimalseq from zopt
%free=find(kron(Mat.DUFree(:),ones(nu,1))); % Indices of free moves
%MPCstruct.optimalseq=zopt;%(free);

%MPCstruct.lastx=xnew;
%MPCstruct.lastu=u;


%% Update MPC object in the workspace, in order to save .lastx and .lastu
%MPCobj.MPCData.MPCstruct=MPCstruct;
%mpcobjname=inputname(1);
%assignin('caller',mpcobjname,MPCobj);

xnew = xnew+xoff; % Add offset on extended state
u = u+uoff; % Add offset on manipulated vars
set(state,'Plant',xnew(1:nxp),'Disturbance',xnew(nxp+1:nxp+nxumd),'Noise',...
    xnew(nxp+nxumd+1:end),'LastMove',u);
