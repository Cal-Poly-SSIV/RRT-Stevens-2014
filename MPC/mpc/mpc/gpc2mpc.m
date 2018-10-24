function MPC = gpc2mpc(G, Options)
% GPC2MPC Generate a SISO MPC that is equivalent to a generalized 
% predictive controller (GPC).
%
% MPC = gpc2mpc(G)
% This option creates an MPC object based on the LTI plant, G, using the
% default GPC options.  Model G must define nout = 1 output and nin >= 1
% inputs.  If nin > 1, by default the first input is assumed to be the manipulated
% variable and all other inputs are assumed to be measured
% disturbances (to be used in feedforward compensation).  G must be
% discrete-time with G.Ts > 0.  This sampling period is used in the
% controller.
%
% MPC = gpc2mpc(G, Options)
% As above but allows you to modify the default GPC settings:
% Options.N1 = starting interval in prediction horizon (default = 1)
%        .N2 = last interval in prediction horizon (default = 10)
%        .NU = control horizon (default = 1)
%        .Lam = penalty weight on changes in manipulated variable
%               (default = 0).  Must be >= 0.
%        .T = Row vector of polynomial coefficients in the numerator of the
%             GPC disturbance model.  Must have all roots within the unit
%             circle.  (Default = [1]).
%        .MVindex = integer corresponding to the index of the manipulated
%                   variable when nin > 1.  (Default = 1).
%
% Options = gpc2mpc
% Defines structure 'Options' containing default values for all the GPC
% settings.
%
% Method:  G is used to create a non-minimal state-space representation as
% described by J. M. Maciejowski, "Predictive Control with Constraints",
% Pearson Education Ltd., 2002, pp. 133-142.

%   Author: N. L. Ricker
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/07/18 15:52:54 $

% Default options
OptDef = struct('T', 1, 'N1', 1, 'NU', 1, 'N2', 10, ...
    'Lam', 0, 'MVindex', 1);
OptDef = orderfields(OptDef);
if nargin == 0
    MPC = OptDef;
    return
elseif nargin == 1
    Options = OptDef;
elseif nargin == 2
    LocalCompareFields(Options, OptDef);
else
    ctrlMsgUtils.error('MPC:computation:GpcSyntaxError');        
end
T = Options.T;
if isempty(T) || ~ isvector(T)
    ctrlMsgUtils.error('MPC:computation:GpcInvalidOptionT');        
elseif T(1) == 0
    ctrlMsgUtils.error('MPC:computation:GpcInvalidOptionTcoeff');        
else
    [nT, T] = LocalLength(T(:)');
end
T = T/T(1);
N1 = ceil(Options.N1);
NU = ceil(Options.NU);
N2 = ceil(Options.N2);
Lam = Options.Lam;
MVindex = ceil(Options.MVindex);
if any([N1 NU N2] < 1)
    ctrlMsgUtils.error('MPC:computation:GpcInvalidOptionN1NUN2');        
elseif Lam < 0
    ctrlMsgUtils.error('MPC:computation:GpcInvalidOptionLam');        
end

if ~isobject(G)
    ctrlMsgUtils.error('MPC:computation:GpcInvalidG');        
else
    Gclass = class(G);
    if ~any(strcmp(Gclass,{'tf', 'ss', 'zpk'}))
        ctrlMsgUtils.error('MPC:computation:GpcInvalidG');        
    else
        Ts = G.Ts;
    end
end

[ny, nin] = size(G);
if ny ~= 1
    ctrlMsgUtils.error('MPC:computation:GpcInvalidGSO');        
elseif ~isscalar(MVindex)
    ctrlMsgUtils.error('MPC:computation:GpcInvalidMVIndex1');        
elseif MVindex < 0 || MVindex > nin
    ctrlMsgUtils.error('MPC:computation:GpcInvalidMVIndex2');        
elseif Ts <= 0
    ctrlMsgUtils.error('MPC:computation:GpcInvalidGTs');        
end

G = tf(G);  % Force to tf form
G = ss(G, 'min');   % Try to delete unobservable/uncontrollable states
Gu = tf(G(MVindex));
set(Gu, 'variable', 'z^-1');
Gu = delay2z(Gu);
if Gu.num{1}(1)
    ctrlMsgUtils.error('MPC:computation:GpcInvalidGFeedThrough');        
end

% Build the model using the non-minimal state-space realization
% described by J. M. Maciejowski, "Predictive Control with Constraints",
% Pearson Education, 2002, pp. 133-142.  This is for the response to the MV
% only.

A = Gu.den{1};
A1 = A(1);
A = A/A1;     % Set leading coefficient of A to unity
nA = length(A);
B = Gu.num{1}(2:end)/A1;
nB = length(B);
q = nT - 1;
nx = nA + nB + q;
a = zeros(nx,nx);
b = zeros(nx,nin+1);
c = [1 zeros(1,nx-1)];
d = zeros(1,nin+1);
a(1,1:nA) = A - [A(2:end) 0];
a(2:nA,1:nA-1) = eye(nA-1);
a(1, nA+1:nA+nB) = [B(1, 2:end) 0] - B;
if nB > 1
    a(nA+2:nA+nB, nA+1:nA+nB-1) = eye(nB-1);
end
b(1, MVindex) = B(1);
b(nA+1, MVindex) = 1;
irow = nA + nB + 1;
if q >= 1
    a(1, irow:irow+q-1) = T(2:end);
    if q > 1
        a(irow+1:irow+q-1, irow:irow+q-2) = eye(q-1);
    end
    b(irow, nin+1) = 1;
end
b(1,nin+1) = 1;
M = zeros(nx,1);
M(1,1) = 1;
if q >= 1
    M(nA+nB+1) = 1;
end

% If there are measured disturbances, add the models for these in parallel.
if nin > 1
    MDindex = 1:nin;
    MDindex(MVindex) = [];
    Gv = delay2z(ss(G(MDindex), 'min'));
    nv = size(Gv.a, 1);
    a = [a zeros(nx,nv); zeros(nv,nx) Gv.a];
    b = [b; zeros(nv, nin+1)];
    b(nx+1:end, MDindex) = Gv.b;
    c = [c Gv.c];
    d(1, MDindex) = Gv.d;
    M = [M; zeros(nv,1)];
end

Plant = ss(a, b, c, d, Ts);
Plant.InputGroup.MV = MVindex;
if nin > 1
    Plant.InputGroup.MD = MDindex;
end
Plant.InputGroup.UD = nin + 1;
Model.Plant = Plant;
Model.Disturbance = ss([], [], [], 1, Ts);
Model.Noise = ss([], [], [], 1, Ts);
    
% Define weights
if N1 > N2
    N1 = N2;
end
if NU > N2
    NU = N2;
end
Ywt = ones(N2,1);
if N1 > 1
    Ywt(1:N1-1,1)=0;
end
Weights.MVRate = Lam;
Weights.ManipulatedVariables = 0;
Weights.OV = Ywt;

% Obtain MPC object from GPC specifications
MPC = mpc(Model, Ts, N2, NU, Weights);

% Specify observer gain
setestim(MPC, M);

function Opts = LocalCompareFields(Options, OptDef)

Opts = OptDef;
% Compare user-supplied options structure to the default structure to
% verify the field names match.  If matched, replace default with
% user-supplied value.

if ~isstruct(Options)
    ctrlMsgUtils.error('MPC:computation:GpcInvalidOptionStructure');        
else
    OptNames = fieldnames(orderfields(Options));
end
DefNames = fieldnames(OptDef);
nD = length(DefNames);
nO = length(OptNames);
for i = 1:nO
    Match = false;
    for j = 1:nD
        if strcmp(DefNames{j},OptNames{i})
            Match = true;
            Opts.(DefNames{j}) = Options.(DefNames{j});
            break
        end
    end
    if ~Match
    	ctrlMsgUtils.error('MPC:computation:GpcInvalidOptionField2',OptNames{i});        
    end
end

function [n, As] = LocalLength(A)

% Determine length of A not counting trailing zero elements;
% Also return an A with trailing zeros stripped off.

ix = find(A ~= 0);
if isempty(ix)
    n = 1;
    As = 0;
else
    n = ix(end);
    As = A(1:ix(end));
end
        