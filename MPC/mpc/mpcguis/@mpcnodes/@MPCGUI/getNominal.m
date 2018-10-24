function opspec = getNominal(h)
% Retrieves nominal data from MPC GUI node and assigns it to the operating
% condition specification object opspec. The method also checks for the
% compatibility of the i/o tables and the operating spec object by counting
% the number of MVs and MOs in each and testing that they match

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.9 $ $Date: 2008/12/04 22:44:00 $

if strcmp(get_param(h.Block,'MaskType'),'MPC')
    mpcblock = h.Block;
else
    mpcblock = [h.Block '/MPC1'];
end
model = bdroot(mpcblock);
[nmo, nmv, nr, nmd] = mpcportsizes(mpcblock);
mv = zeros(nmv,1);
mo = zeros(nmo,1);
md = zeros(nmd,1);

%% Get the i/o table data and check for empty tables 
outtabledata = h.outUDD.CellData;
intabledata = h.inUDD.CellData;
if size(outtabledata,1)==0 || size(intabledata,1)==0 
    Message = ctrlMsgUtils.message('MPC:designtool:IOTableEmpty');
    uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    opspec = []; % Clear the returned opspec so the error can be trapped
    return
end

%% Check that the number of MO rows match the MO port width
Itablemo = find(strcmp(outtabledata(:,2),'Measured'));
if length(Itablemo)~= nmo
    Message = ctrlMsgUtils.message('MPC:designtool:IOTableMOMismatch');
    uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    return
end

%% Check that the number of MV rows match the MV port width
Itablemv = find(strcmp('Manipulated',intabledata(:,2)));
if length(Itablemv)~= nmv
    Message = ctrlMsgUtils.message('MPC:designtool:IOTableMVMismatch');
    uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
    return
end

%% Check that the number of MD rows match the MD port width
if nmd>0
    Itablemd = find(strcmp('Meas. disturb.',intabledata(:,2)));
    if length(Itablemd)~= nmd
        Message = ctrlMsgUtils.message('MPC:designtool:IOTableMDMismatch');
        uiwait(errordlg(Message, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
        return
    end
end

%% Extract the MO/MV/MD constraints from the nominal values in the i/o table
for k=1:length(Itablemo)
    if ischar(outtabledata{Itablemo(k),end})
        mo(k) = str2double(outtabledata{Itablemo(k),end});
    else
        mo(k) = outtabledata{Itablemo(k),end};
    end
end
for k=1:length(Itablemv)
    if ischar(intabledata{Itablemv(k),end})
       mv(k) = str2double(intabledata{Itablemv(k),end});
    else
       mv(k) = intabledata{Itablemv(k),end};
    end
end
if nmd>0
    for k=1:length(Itablemd)
        if ischar(intabledata{Itablemd(k),end})
           md(k) = str2double(intabledata{Itablemd(k),end});
        else
           md(k) = intabledata{Itablemd(k),end};
        end
    end
end

%% Assign controller output constraints to the MV and MO values in the
%% i/o table
opspec = mpc_linoppoints(mpcblock, model, mv, mo, md);
