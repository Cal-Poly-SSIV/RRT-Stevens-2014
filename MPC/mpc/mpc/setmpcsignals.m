function P=setmpcsignals(P,varargin)
%SETMPCSIGNALS Set signal types in MPC plant model
%
%   P=setmpcsignals(P,SignalType1,Channels1,SignalType2,Channels2,...) set I/O
%   channels of the MPC plant model P (LTI object).
%
%   Valid signal types are:
%
%   MV, Manipulated:              manipulated variables (input channels)
%   MD, MeasuredDisturbances:     measured disturbances (input channels)
%   UD, UnmeasuredDisturbances:   unmeasured disturbances (input channels)
%   MO, MeasuredOutputs:          manipulated variables (output channels)
%   UO, UnmeasuredOutputs:        manipulated variables (output channels)
%
%   Unambiguous abbreviations are accepted.
%
%   P=setmpcsignals(P) set channel assignments to default: all inputs are
%   manipulated variables, all outputs are measured outputs.
%
%   Example. We want to define an MPC object based on the LTI discrete-time
%   plant model P with 4 inputs and 3 outputs. The first and second input
%   as measured disturbances, the third input as unmeasured disturbance,
%   the fourth input as manipulated variable (default), the second output
%   as unmeasured, all other outputs as measured:
% 
%   P=setmpcsignals(P,'MD',[1 2],'UD',[3],'UO',[2]);
%   mpc1=mpc(P);
%
%   NOTE: when using SETMPCSIGNALS to modify an existing MPC object, be
%   sure that the fields Weights, MV, OV, DV, Model.Noise, and
%   Model.Disturbance are consistent with the new I/O signal types.
%
%   See also MPC, SET.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/11/09 20:39:02 $

if nargin<1 || ~isa(P,'lti') || isempty(P)
    ctrlMsgUtils.error('MPC:object:InvalidPlantModel','setmpcsignals');    
else
    [ny,nu]=size(P);    
end

ni=nargin;

% Delete existing channel assignments
IG=struct;
OG=struct;
if ni==1,
    IG.Manipulated=(1:nu);
    OG.Measured=(1:ny);
    set(P,'InputGroup',IG,'OutputGroup',OG);
    return
end

% check pv pair
if round((ni-1)/2)~=(ni-1)/2,
    ctrlMsgUtils.error('MPC:object:InvalidSignalPair');    
end

for i=1:2:ni-1,
    % Set each SV pair in turn
    PropStr = varargin{i};
    if ~ischar(PropStr),
        ctrlMsgUtils.error('MPC:object:InvalidSignalString','setmpcsignals');    
    end

    propstr=lower(PropStr);

    % Handle multiple names

    ismv=~isempty(strfind(propstr,'mv'))||~isempty(strfind(propstr,'man'))||~isempty(strfind(propstr,'inp'));
    ismd=~isempty(strfind(propstr,'md'))||~isempty(strfind(propstr,'dis'));
    isud=~isempty(strfind(propstr,'ud'))||(~isempty(strfind(propstr,'dis'))&&~isempty(strfind(propstr,'un')));
    ismo=~isempty(strfind(propstr,'mo'))||(~isempty(strfind(propstr,'ou'))&&~isempty(strfind(propstr,'meas'))&&isempty(strfind(propstr,'un')));
    isuo=~isempty(strfind(propstr,'uo'))||~isempty(strfind(propstr,'umo'))||(~isempty(strfind(propstr,'ou'))&&~isempty(strfind(propstr,'unmeas')));

    if ~(ismv||ismd||isud||ismo||isuo),
        ctrlMsgUtils.error('MPC:object:InvalidSignalType','setmpcsignals');    
    end

    channels = varargin{i+1};
    if ~isnumeric(channels) || ~all(round(channels)==channels)
        ctrlMsgUtils.error('MPC:object:InvalidChannelType','setmpcsignals');            
    end
    channels=channels(:)';

    try
        if ismv,
            if ~isempty(channels),
                IG.Manipulated=channels;
            elseif isfield(IG,'Manipulated')
                IG = rmfield(IG,'Manipulated');
            end
        end
        if ismd,
            if ~isempty(channels),
                IG.Measured=channels;
            elseif isfield(IG,'Measured')
                IG = rmfield(IG,'Measured');
            end
        end
        if isud,
            if ~isempty(channels),
                IG.Unmeasured=channels;
            elseif isfield(IG,'Unmeasured')
                IG = rmfield(IG,'Unmeasured');
            end
        end
        if ismo,
            if ~isempty(channels),
                OG.Measured=channels;
            elseif isfield(OG,'Measured')
                OG = rmfield(OG,'Measured');
            end
        end
        if isuo,
            if ~isempty(channels),
                OG.Unmeasured=channels;
            elseif isfield(OG,'Unmeasured')
                OG = rmfield(OG,'Unmeasured');
            end
        end
    catch ME
        throw(ME);
    end
end
set(P,'InputGroup',IG,'OutputGroup',OG);

% Assign default groups if there is some channel left unassigned
[mvindex,mdindex,unindex,myindex,uyindex,IG] = mpc_chkindex(P,IG);
IG.Manipulated=mvindex';
OG.Measured=myindex';
set(P,'InputGroup',IG,'OutputGroup',OG);
