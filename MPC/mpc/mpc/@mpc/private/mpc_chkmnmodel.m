function [newmodel,newxn0,nnMN,Bmn,Dmn,nxbar] = mpc_chkmnmodel(...
    model,mnmodel,xn0,myindex,mvindex,mdindex,nym)
%MPC_CHKMNMODEL Check for Model.Noise and eventually augment the system
%   for Kalman filter design, including white noise on measured outputs,
%   white noise on the state of Model.Noise,
%   and white noise on each manipulated variable channel

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date:

verbose = mpccheckverbose;

if isempty(mnmodel)

    % Default: Add white noise + an integrator driven by unit-variance white noise
    %          for each measured output channel, i.e. step-like measurement noise.
    %          **UNLESS** a UMD model was specified by the user, in this case no integrators
    %          are added on outputs, as the user may already have included output integrators
    %          in his UMD model, and therefore duplicating such integrators should lead to
    %          unobservability.

    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:AssumeNoiseModel'));
    end

    %% Default: a random noise with unit covariance matrix for each unmeasured disturbance
    mnmodel=tf(eye(length(myindex)));

    % Do nothing, random white noise is added anyway later in the Kalman filter design end
    
end

if isa(mnmodel,'idmodel'),
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertIDToSS'));
    end
    % Convert Model.Noise to SS:
    mnmodel=mpc_id2ss(mnmodel);
end

if ~isa(mnmodel,'ss'),
    if norm(xn0)>0,
        % no initial state is expected for a non-ss model
        ctrlMsgUtils.error('MPC:utility:InvalidNoiseModelInitialState');
    else
        % Zero initial states are emptied, to alleviate the user for wrong dimensions of zero vectors        
        xn0=[]; 
    end
    mnmodel=ss(mnmodel);
    if ~isempty(mnmodel),
        % Use DARE to test detectability
        if ~mpc_chkdetectability(mnmodel.A,mnmodel.C,mnmodel.ts), % System is not detectable
            mnmodel=minreal(mnmodel);
        end
    end
end

% plant model sample time
ts = model.Ts;
% noise model sample time
nts = mnmodel.Ts;

% if the noise model sample time depends
if nts<0,
    % if plant is discrete, use plant sample time
    if ts>0,
        if verbose,
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:AssumeSampleTimeNoiseModel',ts));
        end
        nts=ts;
        mnmodel.ts=ts;
    % if plant is continuous, error out (here we don't have controller sample time info)
    else
        ctrlMsgUtils.error('MPC:utility:InvalidNoiseModelSampleTime');        
    end
end

% if the noise model is continuous
if nts==0,
    % if plant is discrete, use plant sample time
    if ts>0,
        mnmodel = c2d(mnmodel, ts);    
    % if plant is continuous, error out (here we don't have controller sample time info)
    else
        ctrlMsgUtils.error('MPC:utility:InvalidNoiseModelSampleTime');        
    end
% if the noise model is discrete
else
    if abs(ts-nts)>1e-10, % ts different from nts
        if verbose,
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ResampleNoiseModel',ts));
        end
        try
            mnmodel = d2d(mnmodel,ts);
        catch ME
            ctrlMsgUtils.error('MPC:utility:InvalidNoiseModelD2D',ME.message);        
        end
        %takes out possible imaginary parts
        set(mnmodel,'a',real(mnmodel.a),'b',real(mnmodel.b));
    end
end

% Augment the system (note that mnmodel may be just a static gain)
[nx,nutot]=size(model.b);
[ny,nx]=size(model.c);
nu=length(mvindex);
nv=length(mdindex);

[nxbar,nubar]=size(mnmodel.b); 
% nxbar=number of states in mnmodel, appended below the states of MODEL
newc=[model.c,zeros(ny,nxbar)];
newc(myindex,nx+1:nx+nxbar)=mnmodel.c;
newd=[model.d,model.d(:,[mvindex(:);mdindex(:)]'),zeros(ny,nxbar)]; % the term mnmodel.d * inputs-to-Model.Noise is treated as v-disturbance in the Kalman filter design
newb=[model.b,model.b(:,[mvindex(:);mdindex(:)]'),zeros(nx,nxbar);zeros(nxbar,nutot+nu+nv),eye(nxbar)];
newa=[model.a,zeros(nx,nxbar);zeros(nxbar,nx),mnmodel.a];

newmodel=ss(newa,newb,newc,newd,model.ts);

Bmn=mnmodel.b;
Dmn=mnmodel.d;

% This is to prevent the following message from
% KALMAN.M: The covariance matrix
%               E{(Hw+v)(Hw+v)'} = [H,I]*[Qn Nn;Nn' Rn]*[H';I]
%           must be positive definite.
if min(eig(Dmn*Dmn'))<1e-8,
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:FeedThroughAddedToNoiseModel'));
    end
    Dmn=Dmn+1e-4*eye(size(Dmn));
end


nnMN=nubar; % Number of white noise inputs to Model.Noise

newxn0=mpc_chkx0u1(xn0,nxbar,zeros(nxbar,1),ctrlMsgUtils.message('MPC:utility:InitialStateNoiseModel'));

% end of mpc_chkmnmodel
