function [plant,noise,dist]=mpc_id2ss(idmod)
% MPC_ID2SS Converts IDMODEL model to state-space for MPC
%
% SSMOD=MPC_ID2SS(IDMOD) converts model IDMOD to LTI state-space form
%
% [Plant,Noise,Dist]=MPC_ID2SS(IDMOD) converts model IDMOD to state-space
% form splitting the identified model into plant, noise and disturbance models.

%   Authors: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/09 20:47:03 $

error(nargchk(1,1,nargin))

if idmod.ts>0,
    % x(t+1)=A*x(t)+B*u(t)+Be*dist(t),   dist(t)=white noise
    % y(t)=C*x(t)+D*noise(t),            noise(t)=white noise
    if isa(idmod,'idarx'),
        [A,B]=arxdata(idmod);
        if size(B,3)>size(A,3),
            % Probably an Impulse response model
            idmod=ss(idmod);
        else
            idmod=ss(d2d(idmod,idmod.ts));
        end
    else
        idmod=ss(d2d(idmod,idmod.ts));
    end
else
    idmod=ss(idmod);
end

if nargout<=1,
    % Return full model
    plant=idmod;
    % Clean up groups and names
    plant.inputgroup=[];
    plant.outputgroup=[];
    plant.inputname=[];
    plant.outputname=[];
else
    noisechannels=idmod.InputGroup.Noise;
    dist=ss(eye(length(noisechannels)));
    noise=ss(idmod.d(:,noisechannels));
    idmod.d(:,noisechannels)=0*idmod.d(:,noisechannels);
    idmod.InputGroup=struct('Manipulated',idmod.InputGroup.Measured,...
        'Unmeasured',noisechannels);
    for i=1:length(noisechannels),
        j=noisechannels(i);
        idmod.Inputname{j}=sprintf('d%d',i);
    end
    plant=idmod;
end
