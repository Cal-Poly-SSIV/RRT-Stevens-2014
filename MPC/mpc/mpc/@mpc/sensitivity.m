function [J, sens] = sensitivity(MPCobj, PerfFunc, varargin)
%SENSITIVITY computes the closed-loop cumulative performance index and its
% numerical derivatives with respect to the weights of a MPC controller.  
%
%   J = SENSITIVITY(MPCobj, PerfFunc, PerfWeights, Tstop, r, v, simopt, utarget)
%   returns the closed-loop cumulative performance index J for controller
%   MPCobj. 
%
%   "PerfFunc" and "PerfWeights" are used jointly to define a built-in
%   performance evaluation function.  "PerfFunc" has to be one of the
%   following strings: 
%
%   (1) "ISE" (integral of square error)
%
%                 Tstop
%                 ---
%   J(Wy,Wu,Wdu)= \   [Wy * (y(k)-r(k))]^2 + [Wu * (u(k)-utarget)]^2 + [Wdu * du(k)]^2
%                 /
%                 ---
%                 k=0
%
%   (2) "IAE"  (integral of absolute error)
%
%                 Tstop
%                 ---
%   J(Wy,Wu,Wdu)= \   |Wy * (y(k)-r(k))| + |Wu * (u(k)-utarget)| + |Wdu * du(k)|
%                 /
%                 ---
%                 k=0
%
%   (3) "ITSE"  (integral of time-weighted square error)
%
%                 Tstop
%                 ---
%   J(Wy,Wu,Wdu)= \   [Wy * (y(k)-r(k)) * t(k)]^2 + [Wu * (u(k)-utarget) * t(k)]^2 + [Wdu * du(k) * t(k)]^2
%                 /
%                 ---
%                 k=0
%
%   (4) "ITAE" (integral of time-weighted absolute error)
%
%                 Tstop
%                 ---
%   J(Wy,Wu,Wdu)= \   |Wy * (y(k)-r(k))| * t(k) + |Wu * (u(k)-utarget)| * t(k) + |Wdu * du(k)| * t(k)
%                 /
%                 ---
%                 k=0
%
%   "PerfWeights" (performance weights) defines desired performance.  It
%   has to a structure with the following fields: 
%       'OutputVariables' (Wy):             1-by-ny vector  
%       'ManipulatedVariables' (Wu):        1-by-nu vector 
%       'ManipulatedVariablesRate (Wdu):    1-by-nu vector 
%   When "PerfWeights" is not specified, default value is MPCobj.Weights. 
%
%   The closed-loop cumulative performance is computed under the simulation
%   scenario defined by Tstop , r, v, simopt, utarget.  
%       Tstop is the number of simulation steps. 
%       r is the reference signal with as many columns as the number of output variables.
%       v is the measured disturbance signal with as many columns as the number of measured disturbances.
%       simopt specifies the simulation options such as initial states, input/output noise and unmeasured disturbances, plant mismatch, etc. Type HELP MPCSIMOPT for details.
%       utarget is a vector of setpoints for manipulated variables. By default, it is inherited from MPCobj.
%
%   [J SENS] = SENSITIVITY(MPCobj, PerfFunc, PerfWeights, Tstop, r, v, simopt, utarget)
%   also performs a sensitivity analysis with respect to weights of MPCobj.
%   The numerical derivatives are returned into the structure SENS with
%   fields  
%
%       OutputVariables:          ny-by-1 vector, derivatives w.r.t. output weights in MPCobj
%       ManipulatedVariables:     nu-by-1 vector, derivatives w.r.t. input weights in MPCobj
%       ManipulatedVariablesRate: nu-by-1 vector, derivatives w.r.t. weights on input rates in MPCobj
%
%   [J, SENS] = SENSITIVITY(MPCobj,'perf_fun',param1,param2,...) allows to
%   specify any user-defined performance evaluation function "perf_fun.m".
%   The header of such a function must be of the following form
%
%       function J = perf_fun(MPCobj, param1, param2, ...)
%
%   and the function has to be on the MATLAB path.
%
%   Type DEMO MPCSENSITIVITY to see an example on using sensitivity
%   analysis to facilitate MPC tuning and how to implement a custom
%   performance evaluation function.
%
%   Note: when MPCobj contains time-varying or nondiagonal weights they are
%   ignored in the sensitivity analisys.  The weight on the ECR slack
%   variable is also ignored. 
%
%   See also SIM, MPCSIMOPT

%   Author: A. Bemporad
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/12/29 02:12:11 $

error(nargchk(2,inf,nargin));

if isempty(MPCobj),
    ctrlMsgUtils.error('MPC:general:EmptyMPCObject','sensitivity');
end

if ~ischar(PerfFunc)
    ctrlMsgUtils.error('MPC:analysis:InvalidPerfFunc');
end

%% Initialize MPCData if necessary
InitFlag=MPCobj.MPCData.Init;
save_flag='mpcloop';

if ~isfield(MPCobj.MPCData,'MPCstruct'),
    InitFlag=0;
else
    if ~isfield(MPCobj.MPCData.MPCstruct,'Bup'),
        InitFlag=0;
    end
end

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer)
    try
        MPCstruct=mpc_struct(MPCobj,[],save_flag); %x0,u0 are not checked by MPC_CHKX0U1
    catch ME
        throw(ME);
    end
    % Update MPC object in the workspace
    MPCData=MPCobj.MPCData;
    MPCData.MPCstruct=MPCstruct;
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
    MPCobj.MPCData=MPCData;
    try %#ok<TRYNC>
        assignin('caller',inputname(1),MPCobj);
    end
end

%% process inputs
nu=MPCobj.MPCData.nu;
ny=MPCobj.MPCData.ny;
nv=MPCobj.MPCData.MPCstruct.nv;
switch upper(PerfFunc)
    case {'ISE', 'IAE', 'ITSE', 'ITAE'}
        user_defined = false;
        %% process performance weights
        if nargin<3 || isempty(varargin{1})
            PerformanceWeights=MPCobj.Weights;
            ctrlMsgUtils.warning('MPC:analysis:SensitivityDefault');
        else
            PerformanceWeights=varargin{1};
        end
        % Do this to check 'weights' and fill in defaults
        try
            mpc2=MPCobj;
            set(mpc2,'Weights',PerformanceWeights); 
            PerformanceWeights=mpc2.Weights;
        catch ME
            throw(ME);
        end
        if (mpc2.MPCData.nu~=nu) || (mpc2.MPCData.ny~=ny),
            ctrlMsgUtils.error('MPC:analysis:SensitivityInvalidWeights');
        end
        %% process Tstop
        if nargin<4
            Tstop=[];
        else
            Tstop=varargin{2};
        end
        %% process r
        if nargin<5 || isempty(varargin{3}),
            r = MPCobj.MPCData.MPCstruct.yoff(:)';
        else
            r = varargin{3};
        end
        % Check correctness of reference signal
        [n_r,m] = size(r);
        if ~isa(r,'double') || any(isinf(r(:))) || ~isreal(r) || m~=ny
            ctrlMsgUtils.error('MPC:computation:InvalidSetpointSize','sensitivity',ny);
        end
        %% process v
        if nargin<6 || isempty(varargin{4}),
            v = MPCobj.MPCData.MPCstruct.voff(:)';
        else
            v = varargin{4};
        end
        % Check correctness of reference signal
        [n_v,m] = size(v);
        if ~isa(v,'double') || any(isinf(v(:))) || ~isreal(v) || m~=nv-1
            ctrlMsgUtils.error('MPC:computation:InvalidMeasuredDisturbanceSize','sensitivity',nv-1);
        end
        %% refine signal r and v
        if isempty(Tstop),
            Tstop = max([n_r,n_v,MPCobj.PredictionHorizon,10]);
        else
            if isa(Tstop,'double') && numel(Tstop)==1 && isfinite(Tstop),
                Tstop = round(Tstop);
            else
                ctrlMsgUtils.error('MPC:computation:InvalidTf','sensitivity');    
            end
        end
        if n_r>0, 
            r = [r; ones(Tstop-n_r,1)*r(n_r,:)]; 
        end;        
        if n_v>0, 
            v = [v; ones(Tstop-n_v,1)*v(n_v,:)]; 
        end;
        %% process simopt
        if nargin<7
            simopt = [];
        else
            simopt = varargin{5};
            if ~isa(simopt,'mpcsimopt'),
                simopt = [];
            end
        end
        %% process perfutarget
        if nargin<8 || isempty(varargin{6}),
            % Get utarget from MPCobj
            mvindex=MPCobj.MPCData.mvindex; % indices of MV's
            % Ignores time-varying utarget
            perfutarget=zeros(nu,1);
            for i=1:nu,
                if ischar(MPCobj.ManipulatedVariables(i).Target), % Target='nominal'
                    % Must inherit target from off=Model.Nominal.U(mvindex)
                    if isa(MPCobj.Model,'cell'),
                        perfutarget(i)=MPCobj.Model{1}.Nominal.U(mvindex(i));
                    else
                        perfutarget(i)=MPCobj.Model.Nominal.U(mvindex(i));
                    end                
                else
                    perfutarget(i)=MPCobj.ManipulatedVariables(i).Target;
                end
            end
        else
            perfutarget=varargin{6};
            if ~isa(perfutarget,'double') || any(isinf(perfutarget(:))) || ~isreal(perfutarget) || ~isvector(perfutarget) || numel(perfutarget)~=nu
                ctrlMsgUtils.error('MPC:computation:InvalidManipulatedVariableSize','sensitivity',nu);
            end
            perfutarget = perfutarget(:);
        end
    otherwise
        % User defined performance function
        user_defined=true;
end

%% Computation
if ~user_defined,
    % Ignores time-varying and nondiagonal weights
    perfWy=PerformanceWeights.OutputVariables(:);perfWy=perfWy(1:ny);
    perfWu=PerformanceWeights.ManipulatedVariables(:);perfWu=perfWu(1:nu);
    perfWdu=PerformanceWeights.ManipulatedVariablesRate(:);perfWdu=perfWdu(1:nu);
end

% Current set of weights for MPC1
Wy=MPCobj.Weights.OutputVariables(:);Wy=Wy(1:ny);
Wu=MPCobj.Weights.ManipulatedVariables(:);Wu=Wu(1:nu);
Wdu=MPCobj.Weights.ManipulatedVariablesRate(:);Wdu=Wdu(1:nu);
weights=[Wy;Wu;Wdu];

DiffMinChange=1e-4;
DiffMaxChange=1e-2;
Typicalweights=max(weights).*ones(size(weights));

% Weight on slack variable is ignored
if ~user_defined,
    J=mpc_costcomputation(weights,MPCobj,nu,user_defined,PerfFunc,Tstop,r,v,simopt,perfutarget,perfWy,perfWu,perfWdu);
else
    J=mpc_costcomputation(weights,MPCobj,nu,user_defined,PerfFunc,varargin{:});
    if ~(isnumeric(J) && numel(J)==1),
        ctrlMsgUtils.error('MPC:analysis:SensitivityInvalidPerfFunc');
    end
end

if nargout>=2,

    if ~user_defined,
        finitediff=mpc_fundiff(weights,'mpc_costcomputation',J,DiffMinChange,DiffMaxChange,...
            Typicalweights,user_defined,MPCobj,nu,user_defined,PerfFunc,Tstop,r,v,simopt,perfutarget,perfWy,perfWu,perfWdu);
    else
        finitediff=mpc_fundiff(weights,'mpc_costcomputation',J,DiffMinChange,DiffMaxChange,...
            Typicalweights,user_defined,MPCobj,nu,user_defined,PerfFunc,varargin{:});
    end
    sens=struct('OutputVariables',finitediff(1:end-2*nu),'ManipulatedVariables',finitediff(end-2*nu+1:end-nu),...
        'ManipulatedVariablesRate',finitediff(end-nu+1:end));

end

