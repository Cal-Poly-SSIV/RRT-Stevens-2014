function z=mpc_chk_ext_signal(signal,name,nn,ts,offset,t0)
% MPC_CHK_EXT_SIGNAL Take signal_name from MPC Simulink mask, extract a
% signal structure in the 'To Workspace' format and returns a discrete-time
% signal. 

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2007/11/09 20:47:29 $

if isempty(signal),
    signal=struct('time',0,'signals',struct('values',zeros(1,nn)));
end

if isa(signal,'double')
    if all(isfinite(signal(:))),
        [n,m]=size(signal);
        err=0;
        if n*m==1,
            signal=signal*ones(1,nn);
        elseif min(m,n)==1,
            if max(m,n)==nn,
                signal=signal(:)';
            else
                err=1;
            end
        else
            err=1;
        end
        if err,
            ctrlMsgUtils.error('MPC:designtool:InvalidSignalVectorSize',name,nn);
        end
        signal=struct('time',0,'signals',struct('values',signal));
    else
        ctrlMsgUtils.error('MPC:designtool:InvalidSignalVectorReal',name);        
    end
end

% Now left with a structure
if ~isfield(signal,'time'),
    ctrlMsgUtils.error('MPC:designtool:InvalidSignalFieldTime',name);
end
time=signal.time;
if ~isa(time,'double'),
    ctrlMsgUtils.error('MPC:designtool:InvalidSignalValueTime',name);
end

if ~isfield(signal,'signals'),
    ctrlMsgUtils.error('MPC:designtool:InvalidSignalFieldSignal',name);
end

if ~isfield(signal.signals,'values'),
    ctrlMsgUtils.error('MPC:designtool:InvalidSignalFieldSignalValues',name);    
end
values = signal.signals.values;
if ~isa(time,'double'),
    ctrlMsgUtils.error('MPC:designtool:InvalidSignalValueSignal',name);    
end
if size(values,2)~=nn,
    ctrlMsgUtils.error('MPC:designtool:InvalidSignalDimensionSize',name,nn);
end

if isfield(signal.signals,'dimensions'),
    dims=signal.signals.dimensions;
    if dims~=nn,
        ctrlMsgUtils.error('MPC:designtool:InvalidSignalDimensionSize',name,nn);
    end
end

clear signal

% Resample
zorig=values';
clear values

z=[];
lastt=t0;
i=1;
t2=time(1);
t1=t2;
z2=zorig(:,1)-offset;

% Fill t up to time(1) (included)
while lastt<=time(1),
    z=[z,z2];
    lastt=lastt+ts;
end

lent=length(time);

while i<=lent-1 && lastt<time(lent),
    while t2<lastt,
        t1=t2;
        z1=z2;
        t2=time(i+1);
        i=i+1; % takes next sample
    end
    z2=zorig(:,i)-offset;
    z1=zorig(:,i-1)-offset;
    while lastt<=t2,
        znew=z2+(z1-z2)/(t1-t2)*(lastt-t2); % Linear interpolation
        z=[z,znew];
        lastt=lastt+ts;
    end
end

if lastt-1<time(lent),
    z1=zorig(:,lent-1)-offset;
    z2=zorig(:,lent)-offset;
    t1=time(lent-1);
    t2=time(lent);
    znew=z2+(z1-z2)/(t1-t2)*(lastt-t2); % Linear interpolation
    z=[z,znew];
end

%end mpc_chk_ext_signal
