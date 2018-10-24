function sizes = size(MPCobj,type) 
%SIZE  Size and order of MPC objects.
%
%   D = SIZE(MPCOBJ) returns the row vector D = [NU NYM] for an MPC object MPCOBJ 
%   with NU manipulated input variables and NYM measured controlled outputs.
%
%   D = SIZE(MPCOBJ,TYPE) returns the number of signals of type TYPE, where TYPE
%   is one of the following:
%
%       'uo'  unmeasured controlled outputs
%       'md'  measured disturbances
%       'ud'  unmeasured disturbances
%       'mv'  manipulated variables
%       'mo'  measured controlled outputs
%
%   SIZE(MPCOBJ) by itself makes a nice display.
%
%   See also DISPLAY

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2007/11/09 20:39:53 $   

% Get sizes
if ~isempty(MPCobj),
    nym=length(MPCobj.MPCData.myindex);
    nyu=MPCobj.MPCData.ny-nym;
    nu=MPCobj.MPCData.nu;
    nv=length(MPCobj.MPCData.mdindex);
    nd=length(MPCobj.MPCData.unindex);
else
    nym=0;
    nyu=0;
    nu=0;
    nv=0;
    nd=0;
end

if nargin<2,
    if nargout==0
        disp([ctrlMsgUtils.message('MPC:object:Size1',nym,nyu) ...
            '\n' ctrlMsgUtils.message('MPC:object:Size2',nu,nv,nd)])
    else
        sizes =[nu nym];
    end        
else
    switch lower(type)
        case 'mv'
            sizes=nu;
        case 'mo'
            sizes=nym;
        case 'md'
            sizes=nv;
        case 'ud'
            sizes=nd;
        case 'uo'
            sizes=nyu;
        otherwise
            ctrlMsgUtils.error('MPC:object:SizeInvalidType');
    end
end