function [mvindex,mdindex,unindex,myindex,uyindex,IG]=mpc_chkindex(model,IG)
%MPC_CHKINDEX Extract indices of MVs,MDs,UDs,MYs,UYs from Model

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.12 $  $Date: 2008/04/28 03:24:12 $

verbose = mpccheckverbose;

ingroup=model.InputGroup;
outgroup=model.OutputGroup;

% Model already include the additional measured disturbance which models offsets
[ny,nutot]=size(model);

mvindex=[];
mdindex=[];
myindex=[];
unindex=[];
uyindex=[];

% Convert possible old 6.xx cell format to structure, using mpc_getgroup
ingroup=mpc_getgroup(ingroup);
outgroup=mpc_getgroup(outgroup);

s=fieldnames(ingroup);

% For models obtained by converting an IDMODEL to LTI, all inputs are
% labeled as Noise or Measured
is_maybeID=~isempty(s);
for i=1:length(s),
    if ~strcmpi(s{i},'measured') && ~strcmpi(s{i},'noise'),
        is_maybeID=0;
    end
end

if is_maybeID,
    % Are all indices covered ?
    allindex=[];
    if isfield(ingroup,'Measured'),
        allindex=[allindex;ingroup.Measured(:)];
    end
    if isfield(ingroup,'Noise'),
        allindex=[allindex;ingroup.Noise(:)];
    end
    if length(allindex)<nutot,
        is_maybeID=0;
    end
end

if is_maybeID,
    msg1 = ctrlMsgUtils.message('MPC:object:SignalFromSysID1');
    msg2 = ctrlMsgUtils.message('MPC:object:SignalFromSysID2');
    msg3 = ctrlMsgUtils.message('MPC:object:SignalFromSysID2');
    fprintf('-->%s\n   %s\n   %s\n',msg1,msg2,msg3);
    if isfield(ingroup,'Measured'),
        ingroup.MV=ingroup.Measured;
        ingroup=rmfield(ingroup,'Measured');
        IG=rmfield(IG,'Measured');
    end
    if isfield(ingroup,'Noise'),
        ingroup.UD=ingroup.Noise;
        ingroup=rmfield(ingroup,'Noise');
        IG=rmfield(IG,'Noise');
        IG.UnmeasuredDisturbance=ingroup.UD;
    end
    s=fieldnames(ingroup);
end

for i=1:length(s),
    aux=s{i};
    ind=ingroup.(aux);
    switch lower(aux)
        case {'manipulatedvariable','manipulatedvariables','mv','manipulated','input'},
            mvindex=[mvindex;ind(:)];
        case {'measureddisturbance','measureddisturbances','md','measured'},
            mdindex=[mdindex;ind(:)];
        case {'unmeasureddisturbance','unmeasureddisturbances','ud','unmeasured'},
            unindex=[unindex;ind(:)];
        otherwise
            ctrlMsgUtils.error('MPC:utility:InvalidModelInputSignalType',aux);
    end
end

s=fieldnames(outgroup);
for i=1:length(s),
    aux=s{i};
    %eval(sprintf('ind=outgroup.%s;',aux));
    ind=outgroup.(aux);
    switch lower(aux)
        case {'measuredoutputs','measuredoutput','mo','measured'},
            myindex=[myindex;ind(:)];
        case {'unmeasuredoutput','unmeasuredoutputs','uo','unmeasured'},
            uyindex=[uyindex;ind(:)];
        otherwise
            ctrlMsgUtils.error('MPC:utility:InvalidModelOutputSignalType',aux);
    end
end

% If some input is not specified, then it is assumed to be a manipulated variable
aux=[mvindex;mdindex;unindex];
aux2=setdiff(1:nutot,aux);
if ~isempty(aux2),
    if verbose && ~isempty(aux),
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:AssumeUnspecifiedMV'));
    end
    mvindex=[mvindex;aux2(:)];
end

% If some output is not specified, then it is assumed to be a measured output
aux=[myindex;uyindex];
aux2=setdiff(1:ny,aux);
if ~isempty(aux2),
    if verbose && ~isempty(aux),
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:AssumeUnspecifiedMO'));
    end
    myindex=[myindex;aux2(:)];
end

if ~isempty(intersect(mvindex,mdindex)),
    ctrlMsgUtils.error('MPC:utility:IntersectMVMD');
end
if ~isempty(intersect(mvindex,unindex)),
    ctrlMsgUtils.error('MPC:utility:IntersectMVUMD');
end
if ~isempty(intersect(mdindex,unindex)),
    ctrlMsgUtils.error('MPC:utility:IntersectMDUMD');
end
if ~isempty(intersect(myindex,uyindex)),
    ctrlMsgUtils.error('MPC:utility:IntersectMOUMO');
end

% if isempty(myindex),
%     error('mpc:mpc_chkindex:nomy','No measured output was specified.')
% end

mvindex=sort(mvindex);
mdindex=sort(mdindex);
unindex=sort(unindex);
myindex=sort(myindex);

% end of mpc_chkindex
