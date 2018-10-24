function MPCobj = mpc(varargin)
%MPC  Create an MPC controller object.
%
%   MPCOBJ = MPC(PLANT) creates the MPC object based on the discrete-time
%   model PLANT. This is a SS, TF, ZPK or IDMODEL model.
%
%   MPCOBJ = MPC(PLANT,TS) specifies a sampling time for the MPC controller.
%   A continuous-time model PLANT is discretized with sampling time
%   TS.  A discrete-time model PLANT is resampled to sampling time TS.
%
%   MPCOBJ = MPC(PLANT,TS,P) specifies the prediction horizon P.
%   P is a positive, finite integer.
%
%   MPCOBJ = MPC(PLANT,TS,P,M) specifies the control horizon, M. M is either an
%   integer (<= P) or a vector of blocking factors such that sum(M) <= P.
%
%   Weights and constraints on outputs, inputs, input rates, as well as other
%   properties, can be specified using
%
%         SET(MPCOBJ,Property1,Value1,Property2,Value2,...)
%     or
%         MPCOBJ.Property = Value
%
%   Type MPCPROPS for details.
%
%   Disturbance models and operating conditions can be directly specified using
%   the syntax:
%
%   MPCOBJ = MPC(MODELS,TS,P,M) where MODELS is a structure containing
%      MODELS.Plant = plant model (LTI or IDMODEL)
%            .Disturbance = model describing the input disturbances.
%                           This model is assumed to be driven by unit variance
%                           white noise.
%            .Noise = model describing the plant output measurement noise.
%                           This model is assumed to be driven by unit variance
%                           white noise.
%            .Nominal = structure specifying the plant nominal conditions
%                       (e.g., at which the plant was linearized).
%
%   MPCOBJ = MPC creates an empty MPC object
%
%   See also MPCPROPS, MPCVERBOSITY.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.17 $  $Date: 2009/07/18 15:52:57 $

% get default values
default=mpc_defaults;

% if no input argument, create an empty mpc object
ni = nargin;
if ni<1,
    ManipulatedVariables=[];
    OutputVariables=[];
    Weights=[];
    Model=[];
    Ts=[];
    Optimizer=[];
    p=[];
    moves=[];
    Private=[];
    Private.isempty=1;
    DV=[];
else

    % mpc object
    if isa(varargin{1},'mpc'),
        % Quick exit for MPC(MODEL) with MODEL of class MPC
        if ni==1
            MPCobj = varargin{1};
            return            
        else
            ctrlMsgUtils.error('MPC:object:UseSetToModifyProperty');            
        end
    end

    % prediction model
    Model = varargin{1};
    if isa(Model,'lti') || isa(Model,'idmodel'),
        Model = struct('Plant',Model);
    end
    if ~isa(Model,'struct'),
        ctrlMsgUtils.error('MPC:object:Invalid1stInputForConstructor');            
    end

    % extra input arguments for some property pairs
    fields={'Ts','PredictionHorizon','ControlHorizon','Weights','ManipulatedVariables','OutputVariables','DV'};
    nf = length(fields);
    if ni>nf+1,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ExtraInputArgumentIgnored'));
    end
    for i=1:nf,
        if ni>i,
            aux=varargin{i+1};
        else
            aux=[];
        end
        switch fields{i}
            case 'Ts'
                Ts=aux;
            case 'PredictionHorizon'
                PredictionHorizon=aux;
            case 'ControlHorizon'
                ControlHorizon=aux;
            case 'Weights'
                Weights=aux;
            case 'ManipulatedVariables'
                ManipulatedVariables=aux;
            case 'OutputVariables'
                OutputVariables=aux;
            case 'DV'
                DV=aux;
        end
    end
    
    % validate properties
    try

        % Check consistency of sampling time.
        mpc_chkts(Ts);

        % Check the Model structure and consistencies
        [Model,nu,ny,nutot,mvindex,mdindex,unindex,myindex]=mpc_prechkmodel(Model,Ts);

        % If Ts=[] then Plant is discrete time, it was checked by MPC_PRECHKMODEL
        if isempty(Ts),
            Ts=Model.Plant.Ts;
        end

        % Check correctness of prediction horizon
        [p,p_defaulted]=mpc_chkp(PredictionHorizon,default.p,Model,Ts);

        % Check correctness of input horizon/blocking moves
        moves=mpc_chkm(ControlHorizon,p,default.m);

        % Define default weights
        WeightsDefault=isempty(Weights);
        Weights=mpc_chkweights(Weights,p,nu,ny,myindex);

        % Define default InputSpecs and limits, ECRs
        namesfromplant=1;
        ManipulatedVariables=mpc_specs(ManipulatedVariables,nu,'ManipulatedVariables',...
            p,[],Model.Plant.InputName,mvindex,namesfromplant);

        % Define default Optimizer structure
        Optimizer=mpc_chkoptimizer([]);

        % Define default OutputSpecs and limits, ECRs
        OutputVariables=mpc_specs(OutputVariables,ny,'OutputVariables',p,...
            Optimizer.MinOutputECR,Model.Plant.OutputName,1:ny);

        % Define default DisturbanceVariables
        DV=mpc_specs(DV,nutot-nu,'DisturbanceVariables',[],...
            [],Model.Plant.InputName,[mdindex;unindex]);

    catch ME
        throw(ME);
    end

    % DisturbanceSpecs can be only defined by SET.M
    Private=struct('p_defaulted',p_defaulted,...
        'mvindex',mvindex,'mdindex',mdindex,...
        'myindex',myindex,'unindex',unindex,...
        'nutot',nutot,'ny',ny,'nu',nu,...
        'QP_ready',0,'L_ready',0,...
        'Init',0,'isempty',0,'OutDistFlag',0,'WeightsDefault',WeightsDefault);
    
end

% Define property values
MPCobjStructure = struct('ManipulatedVariables',ManipulatedVariables,...
    'OutputVariables',OutputVariables,...
    'DisturbanceVariables',DV,...
    'Weights',Weights,...
    'Model',Model,...
    'Ts',Ts,...
    'Optimizer',Optimizer,...
    'PredictionHorizon',p,...
    'ControlHorizon',moves,...
    'History',clock,...
    'Notes',{{}},...
    'UserData',[],...
    'MPCData',Private,...
    'Version','2.0');


% Label MPCobj as an object of class MPC
MPCobj = class(MPCobjStructure,'mpc');

