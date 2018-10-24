function newOffsets=mpc_chkoffsets(model,Offsets)
%MPC_CHKOFFSETS Check if Offset structure is ok

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2007/11/09 20:46:49 $

[ny, nutot] = size(model);
if isa(model,'ss'),
    [nx, nutot] = size(model.B);
end

x=[];
dx=[];
u=[];
y=[];

if ~isempty(Offsets),
    if ~isa(Offsets,'struct'),
        ctrlMsgUtils.error('MPC:utility:InvalidNominalStructure');
    end
    s=fieldnames(Offsets);
    for i=1:length(s),
        switch lower(s{i})
            case 'x'
                if ~isa(model,'ss'),
                    aux=Offsets.(s{i});
                    if ~isempty(aux),
                        ctrlMsgUtils.error('MPC:utility:InvalidNominalState',class(model));                        
                    end
                else
                    x=off_check(Offsets,s{i},nx);
                end
            case 'dx'
                if ~isa(model,'ss'),
                    aux=Offsets.(s{i});
                    if ~isempty(aux),
                        ctrlMsgUtils.error('MPC:utility:InvalidNominalStateUpdate',class(model));                                                
                    end
                else
                    dx=off_check(Offsets,s{i},nx);
                end
            case 'u'
                u=off_check(Offsets,s{i},nutot);
            case 'y'
                y=off_check(Offsets,s{i},ny);
            otherwise
                ctrlMsgUtils.error('MPC:utility:InvalidNominalStructureField',s{i});
        end
    end
end

if isa(model,'ss'),
    if isempty(x),
        x=zeros(nx,1);
    end
    if isempty(dx),
        dx=zeros(nx,1);
    end
end

if isempty(u),
    u=zeros(nutot,1);
end
if isempty(y),
    y=zeros(ny,1);
end

newOffsets=struct('X',x,'DX',dx,'U',u,'Y',y);

% end mpc_chkoffsets

function a=off_check(Offsets,field,na)
a=Offsets.(field);
err=0;
if norm(a)==0, % This handles both empty 'a' and a=zeros(nb,1) with nb~=na
    a=zeros(na,1);
elseif isa(a,'double')
    [r,c]=size(a);
    if r*c~=na,
        err=1;
    end
else
    err=1;
end
if err,
    ctrlMsgUtils.error('MPC:utility:InvalidNominalStructureData',upper(field),na);
else
    a=a(:);
    if any(isnan(a))|| any(isinf(a))
        ctrlMsgUtils.error('MPC:utility:InvalidNominalStructureData',upper(field),na);
    end
end

