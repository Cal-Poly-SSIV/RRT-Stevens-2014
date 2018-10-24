function Out = set(MPCobj,varargin)
%SET  Set properties of MPC controllers.
%
%   SET(MPCOBJ,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the MPC model MPCOBJ to the value VALUE.  An equivalent syntax
%   is
%       MPCOBJ.PropertyName = VALUE .
%
%   SET(MPCOBJ,'Property1',Value1,'Property2',Value2,...) sets multiple
%   MPC property values with a single statement.
%
%   SET(MPCOBJ,'Property') displays legitimate values for the specified
%   property of MPCOBJ.
%
%   SET(MPCOBJ) displays all properties of MPCOBJ and their admissible
%   values.  Type HELP MPCPROPS for more details on MPC properties.
%
%   See also GET, MPCPROPS, MPC.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.12 $  $Date: 2008/05/19 23:18:46 $

ni = nargin;
no = nargout;

% Check i/o argument
if no && ni>2,
    ctrlMsgUtils.error('MPC:object:SetInvalidOutputSize');
end

% Get properties and their admissible values when needed
if ni<=2,
    [AllProps,AsgnValues] = pnames(MPCobj);
else
    AllProps = pnames(MPCobj);
end

% SET(MPCOBJ) or S = SET(MPCOBJ)
if ni==1,
    if no,
        Out = cell2struct(AsgnValues,AllProps,1);
    else
        disp(pvformat(AllProps,AsgnValues));
    end
    return
% SET(MPCOBJ,'Property') or STR = SET(MPCOBJ,'Property')
elseif ni==2,
    Property = varargin{1};
    if ~ischar(Property),
        ctrlMsgUtils.error('MPC:object:SetInvalidPropertyName');
    end
    % Return admissible property value(s)
    imatch = strmatch(lower(Property),lower(AllProps));
    aux = PropMatchCheck(length(imatch));
    if ~isempty(aux),
        ctrlMsgUtils.error(aux,lower(Property));
    end
    if no,
        Out = AsgnValues{imatch};
    else
        disp(AsgnValues{imatch})
    end
    return
end

MPCData=MPCobj.MPCData;

% Now left with SET(MPCOBJ,'Prop1',Value1, ...)
if MPCData.isempty,
    ctrlMsgUtils.error('MPC:object:SetEmptyObject');
end

% Retrieve info about previously stored properties
p=MPCobj.PredictionHorizon;
moves=MPCobj.ControlHorizon;
mvindex=MPCData.mvindex;
mdindex=MPCData.mdindex;
myindex=MPCData.myindex;
unindex=MPCData.unindex;
nutot=MPCData.nutot;
ny=MPCData.ny;
nu=MPCData.nu;
ts=MPCobj.Ts;
QP_ready=MPCData.QP_ready;
L_ready=MPCData.L_ready;
Model=MPCobj.Model;
Weights=MPCobj.Weights;
ManipulatedVariables=MPCobj.ManipulatedVariables;
OutputVariables=MPCobj.OutputVariables;
DisturbanceVariables=MPCobj.DisturbanceVariables;
WeightsDefault=MPCData.WeightsDefault;

% check pair
if rem(ni-1,2)~=0,
    ctrlMsgUtils.error('MPC:object:SetInvalidPair');
end

%%
% Initialize flags indicating which properties will be changed. These
% are stored in the structure Chg, having the same fieldnames of the MPC object
for i=1:length(AllProps);
    Chg.(AllProps{i})=0;
end

% Set each PV pair in turn
for i=1:2:ni-1,

    PropStr = varargin{i};
    if ~ischar(PropStr),
        ctrlMsgUtils.error('MPC:object:SetInvalidPropertyName');
    end

    propstr=lower(PropStr);

    % Handle multiple names
    if strcmp(propstr,'mv') || strcmp(propstr,'manipulated') || strcmp(propstr,'input'),
        propstr='manipulatedvariables';
    elseif strcmp(propstr,'ov') || strcmp(propstr,'controlled') || strcmp(propstr,'output'),
        propstr='outputvariables';
    elseif strcmp(propstr,'dv') || strcmp(propstr,'disturbance'),
        propstr='disturbancevariables';
    end

    imatch = strmatch(propstr,lower(AllProps));
    aux=PropMatchCheck(length(imatch));
    if ~isempty(aux),
        ctrlMsgUtils.error(aux,propstr);
    end
    Property = AllProps{imatch};
    Value = varargin{i+1};

    % Just sets what was required, will check later on when all
    % properties have been set
    MPCobj.(Property)=Value;
    Chg.(Property)=1;
end

%% Modify properties
default=mpc_defaults;

%-----------------%
try
    if Chg.Ts,
        % Check consistency of sampling time.
        mpc_chkts(MPCobj.Ts);
        Chg.Ts=~isequal(MPCobj.Ts,ts);
    end

    %-----------------%
    if Chg.Model || Chg.Ts,

        % Prediction model
        if isa(MPCobj.Model,'lti'), % |~isa(MPCobj.Model,'fir'), % FIR objects not yet available ...
            MPCobj.Model=struct('Plant',MPCobj.Model);
        end

        if ~isa(MPCobj.Model,'struct'),
            ctrlMsgUtils.error('MPC:object:SetInvalidModel');
        end

        % Check the Model structure and consistencies
        [MPCobj.Model,nu_,ny_,nutot_,mvindex_,mdindex_,unindex_,myindex_]=...
            mpc_prechkmodel(MPCobj.Model,MPCobj.Ts);

    else
        nu_=nu;
        ny_=ny;
        nutot_=nutot;
        mvindex_=mvindex;
        mdindex_=mdindex;
        unindex_=unindex;
        myindex_=myindex;
    end

    if Chg.PredictionHorizon || Chg.Model || Chg.Ts,
        % Check correctness of prediction horizon
        [MPCobj.PredictionHorizon,p_defaulted]=mpc_chkp(MPCobj.PredictionHorizon,default.p,MPCobj.Model,MPCobj.Ts);

        % Is PredictionHorizon changed ?
        Chg.PredictionHorizon=~isequal(MPCobj.PredictionHorizon,p);

    end
    p_defaulted=MPCData.p_defaulted;

    %-----------------%

    Chg.Model=~isequal(Model,MPCobj.Model);
    Chg.nu=(nu_~=nu);
    Chg.ny=(ny_~=ny);
    Chg.nutot=(nutot_~=nutot);
    Chg.mvindex=~isequal(mvindex_(:),mvindex(:));
    Chg.mdindex=~isequal(mdindex_(:),mdindex(:));
    Chg.unindex=~isequal(unindex_(:),unindex(:));
    Chg.myindex=~isequal(myindex_(:),myindex(:));
    Chg.ModelPlant=~isequal(Model.Plant,MPCobj.Model.Plant);
    Chg.ModelDisturbance=~isequal(Model.Disturbance,MPCobj.Model.Disturbance);
    Chg.ModelNoise=~isequal(Model.Noise,MPCobj.Model.Noise);
    Chg.ModelNominal=~isequal(Model.Nominal,MPCobj.Model.Nominal);

    %-----------------%

    if Chg.ControlHorizon || Chg.PredictionHorizon,
        % Check correctness of input horizon/blocking moves
        MPCobj.ControlHorizon=mpc_chkm(MPCobj.ControlHorizon,MPCobj.PredictionHorizon,default.m);

        Chg.ControlHorizon=~isequal(MPCobj.ControlHorizon,moves);
    end

    %-----------------%

    if Chg.Weights || Chg.nu || Chg.ny || Chg.PredictionHorizon,
        MPCobj.Weights=mpc_chkweights(MPCobj.Weights,MPCobj.PredictionHorizon,nu_,ny_);
        Chg.Weights=~isequal(MPCobj.Weights,Weights);

        WeightsDefault=isempty(MPCobj.Weights);
    end

    %-----------------%
    if Chg.DisturbanceVariables || Chg.nutot || Chg.nu || Chg.PredictionHorizon ||...
            Chg.ModelPlant || Chg.mdindex || Chg.unindex,
        MPCobj.DisturbanceVariables=mpc_specs(MPCobj.DisturbanceVariables,nutot_-nu_,...
            'DisturbanceVariables',MPCobj.PredictionHorizon,[],...
            MPCobj.Model.Plant.InputName,[mdindex_(:);unindex_(:)],Chg.ModelPlant);
    end

    %-----------------%

    if Chg.ManipulatedVariables || Chg.nu || Chg.PredictionHorizon ||...
            Chg.ModelPlant || Chg.mvindex,
        MPCobj.ManipulatedVariables=mpc_specs(MPCobj.ManipulatedVariables,nu_,'ManipulatedVariables',...
            MPCobj.PredictionHorizon,[],MPCobj.Model.Plant.InputName,mvindex_,Chg.ModelPlant);
        Chg.ManipulatedVariables=~isequal(MPCobj.ManipulatedVariables,ManipulatedVariables);
    end

    %-----------------%

    if Chg.Optimizer,
        MPCobj.Optimizer=mpc_chkoptimizer(MPCobj.Optimizer);
    end

    %-----------------%

    if Chg.OutputVariables || Chg.ny || Chg.PredictionHorizon || Chg.ModelPlant,
        MPCobj.OutputVariables=mpc_specs(MPCobj.OutputVariables,...
            ny_,'OutputVariables',MPCobj.PredictionHorizon,...
            MPCobj.Optimizer.MinOutputECR,MPCobj.Model.Plant.OutputName,1:ny_,Chg.ModelPlant);
        Chg.OutputVariables=~isequal(MPCobj.OutputVariables,OutputVariables);
    end

    %-----------------%
    if Chg.History,
        % Check consistency of history field and possibly convert it to DATEVEC (=CLOCK) format.
        MPCobj.History=mpc_chkhistory(MPCobj.History);
    end

    %-----------------%
    if Chg.Notes,
        % Check consistency of Notes field
        if ~iscell(MPCobj.Notes),
            ctrlMsgUtils.error('MPC:object:SetInvalidNote');
        end
    end
    %-----------------%

catch ME
    throw(ME);
end
%-----------------%

%% Update flags for readiness of QP matrices and estimator gain
QP_ready=QP_ready & ~Chg.PredictionHorizon & ~Chg.Model & ~Chg.ControlHorizon & ...
    ~Chg.mvindex & ~Chg.mdindex & ~Chg.unindex & ~Chg.Weights & ...
    ~Chg.ManipulatedVariables & ~Chg.OutputVariables & ~Chg.Ts;

L_ready=L_ready & ~Chg.Model & ~Chg.Weights & ...
    ~Chg.mvindex & ~Chg.mdindex & ~Chg.unindex & ~Chg.myindex & ~Chg.Ts;


MPCData.p_defaulted=p_defaulted;
MPCData.mvindex=mvindex_;
MPCData.mdindex=mdindex_;
MPCData.myindex=myindex_;
MPCData.unindex=unindex_;
MPCData.nutot=nutot_;
MPCData.ny=ny_;
MPCData.nu=nu_;
MPCData.QP_ready=QP_ready;
MPCData.L_ready=L_ready;

if ~QP_ready || ~L_ready,
    MPCData.Init=0;
end

MPCData.WeightsDefault=WeightsDefault;
MPCobj.MPCData=MPCData;

%% Finally, assign MPCobj in caller's workspace
if ~isempty(inputname(1))
    assignin('caller',inputname(1),MPCobj);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction PropMatchCheck
function errmsg = PropMatchCheck(nhits)
% Issues a standardized error message when the property name
% PROPERTY is not uniquely matched.
if nhits==1,
    errmsg = '';
elseif nhits==0,
    errmsg = 'MPC:object:SetNoPropertyName';
else
    errmsg = 'MPC:object:SetAmbiguousPropertyName';
end