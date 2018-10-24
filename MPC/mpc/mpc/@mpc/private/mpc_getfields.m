function [ManipulatedVariables,OutputVariables,Plant,Disturbance,Noise,... %InputCovariance,DisturbanceCovariance,NoiseCovariance,...
      Ts,MinOutputECR,MaxIter,...
      PredictionHorizon,ControlHorizon,Nominal,MPCData,Weights]=...
   mpc_getfields(mpcobj)
% MPC_GETFIELDS Get fields from MPC object

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/09 20:40:28 $   

mpcobj=struct(mpcobj);

%%
fields={'ManipulatedVariables','OutputVariables','Model', ... %'StateEstimator',...
      'Ts','MPCData','Optimizer','PredictionHorizon','ControlHorizon',...
      'Weights'};
for i=1:length(fields),
   %eval(['isf=isfield(mpcobj,''' fields{i} ''');']);
   isf=isfield(mpcobj,fields{i});
   if isf,
      %aux=['mpcobj.' fields{i}];
      aux=mpcobj.(fields{i});
   else
      %aux='[]';
      aux=[];
   end
   %eval([fields{i} '=' aux ';']);
   switch fields{i}
       case 'ManipulatedVariables'
           ManipulatedVariables=aux;
       case 'OutputVariables'
           OutputVariables=aux;
       case 'Model' ;%case 'StateEstimator'
           Model=aux;
       case 'Ts'
           Ts=aux;
       case 'MPCData'
           MPCData=aux;
       case 'Optimizer'
           Optimizer=aux;
       case 'PredictionHorizon'
           PredictionHorizon=aux;
       case 'ControlHorizon'
           ControlHorizon=aux;
       case 'Weights'
           Weights=aux;
   end
end

%%
fields={'Plant','Disturbance','Noise','Nominal'};
for i=1:length(fields),
   %aux=['Model.' fields{i}]; 
   aux=Model.(fields{i}); % Field exists because MPC constructor checked for it
   
   %eval([fields{i} '=' aux ';']);
   switch fields{i}
       case 'Plant'
           Plant=aux;
       case 'Disturbance'
           Disturbance=aux;
       case 'Noise'
           Noise=aux;
       case 'Nominal'
           Nominal=aux;
   end
end

%%
fields={'MinOutputECR','MaxIter'};
for i=1:length(fields),
   %eval(['isf=isfield(Optimizer,''' fields{i} ''');']);
   isf=isfield(Optimizer,fields{i});
   if isf,
      %aux=['Optimizer.' fields{i}];
      aux=Optimizer.(fields{i});
   else
       %aux='[]';
       aux=[];
   end
   %eval([fields{i} '=' aux ';']);
   switch fields{i}
       case 'MinOutputECR'
           MinOutputECR=aux;
       case 'MaxIter'
           MaxIter=aux;
   end
end

%% Fill in possible missing fields in Nominal
fields={'X','U','Y','DX'};
for i=1:length(fields),
   %eval(['isf=isfield(Nominal,''' fields{i} ''');']);
   isf=isfield(Nominal,fields{i});
   if ~isf
      %eval(['Nominal.' fields{i} '=[];']);
      Nominal.(fields{i})=[];
   end
end

