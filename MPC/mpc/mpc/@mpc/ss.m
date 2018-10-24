function [sys, ut] = ss(MPCobj, signals, ref_preview, md_preview)
%SS State-space system corresponding to linearized MPC object (no constraints)
%
%   SYS=ss(MPCobj) returns the linear controller SYS corresponding to 
%   the MPC controller when the constraints are not active. 
%   The MPC controller SYS has the linear discrete-time state-space form
%
%   x(t+1) = A x(t) + B ym(t)
%   u(t)  = C x(t) + D ym(t)
%
%   where vector x(t) includes the observer states (plant+disturbance+noise model) 
%   and the previous vector of manipulated variables u(t-1), 
%   u(t) is the computed current vector of manipulated variables, 
%   ym(t) is the vector of measured outputs, and the controller's
%   sampling time SYS.Ts=MPCobj.Ts.
%
%   The purpose is to use the linear equivalent control SYS in the 
%   Control Toolbox for sensitivity and other linear analysis.
%
%   SYS=ss(MPCobj,SIGNALS) get the more general form of system SYS:
%
%   x(t+1) = A x(t) + B ym(t) + Br r(t) + Bv v(t) + Boff + Bt ut(t)
%   u(t)  = C x(t) + D ym(t) + Dr r(t) + Dv v(t) + Doff + Dt ut(t)
%
%   where r is the reference signal, v is the measured disturbance, ut
%   is the input target value. SIGNALS is a character string made from 
%   one element from any or all the following:
%
%   r      output references
%   v      measured disturbances
%   o      offset terms
%   t      input targets
%
%   and selects which signals must be included as inputs to the LTI 
%   object SYS. For example, SYS=ss(MPCobj,'rv') returns the controller
%   that maps [ym;r;v] to u, and that corresponds to the MPC controller 
%   MPCobj when constraints are not active.
%  
%   In the general case of nonzero offsets, ym[r,v] must be interpreted 
%   as the difference between the vector and the corresponding offset. 
%   Vectors Boff,Doff are constant terms due to nonzero offsets, in particular 
%   they are nonzero if and only if Nominal.DX is nonzero (continuous-time 
%   prediction models), or Nominal.Dx-Nominal.X is nonzero (discrete-time 
%   prediction models). Note that when Nominal.X is an equilibrium state, 
%   Boff,Doff are zero.
%
%   SYS=ss(MPCobj,SIGNALS,ref_preview,md_preview) specifies
%   if reference and measured disturbance signals are looked ahead. 
%   If flag ref_preview='on', matrices Br and Dr correspond 
%   to the whole reference sequence: 
%
%   x(t+1) = A x(t) + B ym(t) + Br*[r(t);r(t+1);...;r(t+p-1)] + ...
%  
%   Similarly if flag md_preview='on', matrix Bv(Dv)corresponds to the 
%   whole measured disturbance sequence: 
%   
%   x(t+1) = A x(t) + ... + Bv*[v(t);v(t+1);...;v(t+p)] + ...
%  
%   [SYS,ut]=ss(MPCobj) also returns the input target values 
%   ut=[utarget(t);utarget(t+1);...utarget(t+h)]:
%
%   x(t+1) = A x(t) + ... + But*ut
%   u(t)  = C x(t) + ... + Dut*ut
%
%   where h is the maximum over i of length(MPCobj.MV(i).Target), 
%   i.e., the largest horizon input targets are looked ahead 
%   (default: h=1, ut=[0 0 ... 0]'). In the general case of nonzero 
%   offsets, each utarget is interpreted as the difference between 
%   the input target and the corresponding input offset. Note that vector 
%   ut depends on MPCobj because input target values are MPC object's properties.
%
%   See also TF, ZPK.
  
%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2007/11/09 20:39:55 $   

if isempty(MPCobj),
    sys=ss;
    ut=[];
    return
end

if nargin<2,
    signals='';
end

if nargin<3,
    ref_preview='off';
end
if ~ischar(ref_preview) || (~strcmp(ref_preview,'on') && ~strcmp(ref_preview,'off')),
    ctrlMsgUtils.error('MPC:analysis:InvalidSetpointOption','ss');
end

if nargin<4,
    md_preview='off';
end
if ~ischar(md_preview) || (~strcmp(md_preview,'on') && ~strcmp(md_preview,'off')),
    ctrlMsgUtils.error('MPC:analysis:InvalidMDOption','ss');    
end

InitFlag=MPCobj.MPCData.Init;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer)
    try
        MPCstruct=mpc_struct(MPCobj,[],'base'); % xmpc0=[]
    catch ME
        throw(ME);
    end
    MPCobj = mpc_updatempcdata(MPCobj,MPCstruct,1,1,1);        
    % Before invoking SS, update object (init, ready) when necessary   
    if ~isempty(inputname(1))
        assignin('caller',inputname(1),MPCobj);
    end
else
    MPCstruct=MPCobj.MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct
nym=MPCstruct.nym;
ny=MPCstruct.ny;
nu=MPCstruct.nu;
nx=MPCstruct.nx;
nv=MPCstruct.nv;
nxQP=MPCstruct.nxQP;
degrees=MPCstruct.degrees;

Ts=MPCstruct.ts;
p=MPCstruct.p;

A=MPCstruct.A;
Cm=MPCstruct.Cm;
Bu=MPCstruct.Bu;
Bv0=MPCstruct.Bv;
Dvm0=MPCstruct.Dvm;
M=MPCstruct.M;

KduINV=MPCstruct.KduINV;
Kx=MPCstruct.Kx;
Ku1=MPCstruct.Ku1;
Kut=MPCstruct.Kut;
Kr=MPCstruct.Kr;
Kv=MPCstruct.Kv;
PTYPE=MPCstruct.PTYPE;

% Unconstrained MPC equations:
%
% 1) x=offset-free extended state vector (Plant + Disturbance + Noise)
% 2) uold=offset-free manipulated input vector
% 3) xQP=offset-free Plant + Disturbance state vector
%
% A) ymest=Cm*x+Dvm*(v-voff);  % Measurement update of state observer
% B) x1=x+L*(ym-ymoff-ymest);   % (NOTE: what is called L here is called M in KALMAN's help file)
% C) xQP=x1(1:nxQP); % Only these first nxQP states are fed back to the QP problem
% D) zopt=-KduINV*(Kx'*xQP+Ku1'*uold+Kut'*(utarget-uoff)+Kr'*(r-yoff)+Kv'*(v-voff));
% E) u-uoff=uold+zopt(1:nu)
% F) xnew=A*x1+Bu*(u-uoff)+Bv*(v-voff);

% du(t)=(-[I 0 ... 0]*KduINV)*(Kx'*xQP+Ku1'*uold+Kut'*(utarget-uoff)+Kr'*(r-yoff)+Kv'*(v-voff));
%      = Fx*x+Dym*ym+Dv*v(1:nv-1)+Doff+Fu*uold+Dut*utarget+Dr*r

epsslack=(PTYPE==0); %=1 if eps slack is present, 0 otherwise

nmoves=degrees/nu; % number of free (vector) moves

Kmat=-[eye(nu),zeros(nu,(nmoves-1)*nu)]*KduINV(1:degrees,1:degrees);
KmatQP=Kmat*Kx'*[eye(nxQP) zeros(nxQP,nx-nxQP)];
Fx=KmatQP*(eye(nx)-M*Cm);
Dym=KmatQP*M;

IIoff=(1:p+1)*nv; % Indices of additional MD for offsets over prediction horizon
IIv=setdiff((1:nv*(p+1)),IIoff); % Indices of MDs over prediction horizon 
Ivaux=[eye(nv-1),zeros(nv-1,p*(nv-1))]; % Extract v(t) from [v(t);...;v(t+p)];

Dv=-KmatQP*M*Dvm0(:,1:nv-1)*Ivaux+Kmat*Kv(IIv,:)';
Doff=-KmatQP*M*Dvm0(:,nv)+Kmat*Kv(IIoff,:)'*ones(p+1,1);
Fu=Kmat*Ku1';
Dut=Kmat*Kut';
Dr=Kmat*Kr';

% MPC controller's state: [x;uold], where x=offset-free extended state vector 
% (Plant + Disturbance + Noise) and uold=offset-free manipulated input vector

C=[Fx Fu+eye(nu)];
AM=A*M;
AA=[A-AM*Cm+Bu*Fx,Bu+Bu*Fu;
    C];
Bym=[AM+Bu*Dym;Dym];

% Assign names to LTI MPC controller sys
xaux={};
for i=1:nx,
    xaux{i}='xMPC';
    if nx>1,
        xaux{i}=sprintf('%s%d',xaux{i},i);
    end
end
for i=1:nu,
    xaux{nx+i}='prev.MV';
    if nu>1,
        xaux{nx+i}=sprintf('%s%d',xaux{nx+i},i);
    end
end
uaux={};
for i=1:nym,
    uaux{i}='meas.Y';
    if nym>1,
        uaux{i}=sprintf('%s%d',uaux{i},i);
    end
end
yaux={};
for i=1:nu,
    yaux{i}='MV';
    if nu>1,
        yaux{i}=sprintf('%s%d',yaux{i},i);
    end
end

BB=Bym;
DD=Dym;

isr=~isempty(findstr(signals,'r'));
isv=~isempty(findstr(signals,'v'));
iso=~isempty(findstr(signals,'o'));
ist=~isempty(findstr(signals,'t'));

if isr,
    Br=[Bu*Dr;Dr];
    if ~strcmp(ref_preview,'on')
        aux=kron(ones(p,1),eye(ny));
        Br=Br*aux;
        Dr=Dr*aux;
    end
    BB=[BB,Br];
    DD=[DD,Dr];
    for i=1:ny,
        uaux{end+1}='r';
        if ny>1,
            uaux{end}=sprintf('%s%d',uaux{end},i);
        end
        if strcmp(ref_preview,'on'),
            uaux{end}=[uaux{end} '(1)'];
        end
    end
    if strcmp(ref_preview,'on'),
        for j=1:p-1,
            for i=1:ny,
                uaux{end+1}='r';
                if ny>1,
                    uaux{end}=sprintf('%s%d',uaux{end},i);
                end
                uaux{end}=sprintf('%s(%d)',uaux{end},j+1);
            end
        end
    end
end

if isv,
    Bv=[(Bv0(:,1:nv-1)-AM*Dvm0(:,1:nv-1))*Ivaux+Bu*Dv;Dv];
    if ~strcmp(md_preview,'on')
        aux=kron(ones(p+1,1),eye(nv-1));
        Bv=Bv*aux;
        Dv=Dv*aux;
    end
    BB=[BB,Bv];
    DD=[DD,Dv];
    for i=1:nv-1,
        uaux{end+1}='MD';
        if nv-1>1,
            uaux{end}=sprintf('%s%d',uaux{end},i);
        end
        if strcmp(md_preview,'on'),
            uaux{end}=[uaux{end} '(0)'];
        end
    end
    if strcmp(md_preview,'on'),
        for j=1:p,
            for i=1:nv-1,
                uaux{end+1}='MD';
                if nv-1>1,
                    uaux{end}=sprintf('%s%d',i);
                end
                uaux{end}=sprintf('%s(%d)',uaux{end},j);
            end
        end
    end
end

if iso,
    Boff=[Bv0(:,nv)+Bu*Doff-AM*Dvm0(:,nv);Doff];
    BB=[BB,Boff];
    DD=[DD,Doff];
    uaux{end+1}='1 [offset]';
end

if ist || nargout==2,
    % Determine max utarget preview horizon
    nutp=0;
    ut=zeros(nu,p);
    for i=1:nu,
        uti=MPCobj.ManipulatedVariables(i).Target;
        if ischar(uti),
            uti=MPCobj.Model.Nominal.U(i);
        end
        nuti=length(uti);
        if nuti>nutp,
            nutp=nuti;
        end
        ut(i,:)=MPCstruct.utarget(i+nu*(0:p-1));
    end
    % Truncates ut to max utarget preview horizon
    ut=ut(:,1:nutp);ut=ut(:);

    if ist,
        But=[Bu*Dut;Dut];
        % Collapse the last p-nutp gains onto the nutp-th input target:
        aux=kron(ones(p-nutp+1,1),eye(nu));
        But(:,nu*(nutp-1)+1:nu*nutp)=But(:,nu*(nutp-1)+1:nu*p)*aux;
        But(:,nu*nutp+1:nu*p)=[];
        Dut(:,nu*(nutp-1)+1:nu*nutp)=Dut(:,nu*(nutp-1)+1:nu*p)*aux;
        Dut(:,nu*nutp+1:nu*p)=[];

        BB=[BB,But];
        DD=[DD,Dut];

        for i=1:nu,
            uaux{end+1}='ut';
            if nu>1,
                uaux{end}=sprintf('%s%d',uaux{end},i);
            end
            if nutp>1,
                uaux{end}=[uaux{end} '(0)'];
            end
        end
        if nutp>1,
            for j=1:nutp-1,
                for i=1:nu,
                    uaux{end+1}='ut';
                    if nu>1,
                        uaux{end}=sprintf('%s%d',uaux{end},i);
                    end
                    uaux{end}=sprintf('%s(%d)',uaux{end},j);
                end
            end
        end
    end
end

sys=ss(AA,BB,C,DD,Ts);
set(sys,'StateName',xaux,'InputName',uaux,'OutputName',yaux);
