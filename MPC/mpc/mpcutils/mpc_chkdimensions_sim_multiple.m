function mpc_chkdimensions_sim_multiple

%MPC_CHK_DIMENSIONS_MULTIPLE Check correct dimensions of signals to 
%Multiple MPC Simulink block

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/05/19 23:19:21 $   

blkh=gcbh;
blk=[get(blkh,'Parent') '/' get_param(blkh,'Name')];

N=str2double(get_param(blkh,'Nmpc'));
open_loop=0;
for i=1:N,
    blkMPC=sprintf('%s/MPC%d',blk,i);
    mpcobjname=get_param(blkMPC,'mpcobj');
    if isempty(mpcobjname)
        open_loop=1;
    end
end

% Run open loop when no mpcobj in some of the MPC blocks
if open_loop,
    return
end

% Retrieves MPC dimensions from first MPC block
blkMPC1=sprintf('%s/MPC%d',blk,1);
mpc1=get_param(blkMPC1,'mpcobj');
mpc1data=evalin('base',sprintf('getmpcdata(%s)',mpc1));
ny=mpc1data.ny;
nu=mpc1data.nu;
nym=length(mpc1data.myindex);
nv=length(mpc1data.mdindex)+1;

% Check that all MPC blocks share the same dimensions
for i=2:N,
    blkMPC=sprintf('%s/MPC%d',blk,i);
    mpcI=get_param(blkMPC,'mpcobj');
    mpcIdata=evalin('base',sprintf('getmpcdata(%s)',mpcI));

    wrong='';
    if ~(mpcIdata.ny==ny),
        wrong='output vectors and references';
    end
    if ~(mpcIdata.nu==nu),
        wrong='manipulated variables';
    end
    if ~(length(mpcIdata.myindex)==nym),
        wrong='measured outputs';
    end
    if ~(length(mpcIdata.mdindex)+1==nv),
        wrong='measured disturbances';
    end
    if ~isempty(wrong),
        ctrlMsgUtils.error('MPC:utility:InvalidDimension',wrong,mpc0,mpcI);
    end
end

ports=get_param(gcbh,'PortConnectivity');
widths=get_param(gcbh,'CompiledPortWidths');

err='';
if ~(ports(1).SrcBlock<0) && ... % if switching signal is connected ...
        widths.Inport(1)~=1,
   err=ctrlMsgUtils.message('MPC:utility:InvalidPort','switching signals',1,widths.Inport(1));
end

if ~(ports(2).SrcBlock<0) && ... % if output signal is connected ...
        widths.Inport(2)~=nym,
   err=[err ctrlMsgUtils.message('MPC:utility:InvalidPort','measured outputs',nym,widths.Inport(2))];
end

if ~(ports(3).SrcBlock<0) && ... % if reference signal is connected ...
        widths.Inport(3)~=ny,
   err=[err ctrlMsgUtils.message('MPC:utility:InvalidPort','reference signals',ny,widths.Inport(3))];
end

MDenabled = strcmp(get_param(gcb,'md_inport_multiple'),'on');
LIMSenabled = strcmp(get_param(gcb,'lims_inport_multiple'),'on');

if length(widths.Inport)>=4 && MDenabled,
    if ~(ports(4).SrcBlock<0) && ... % if measured dist. signal is connected ...
          widths.Inport(4)~=nv-1,
       err=[err ctrlMsgUtils.message('MPC:utility:InvalidPort','measured disturbances',nv-1,widths.Inport(4))];
    end
end

portnum=4;
if length(widths.Inport)>=5 && MDenabled,
    portnum=5;
end

if length(widths.Inport)>=portnum && LIMSenabled,
    if ~(ports(portnum).SrcBlock<0) ... % if UMIN signal is connected ...
          && widths.Inport(portnum)~=nu,
       err=[err ctrlMsgUtils.message('MPC:utility:InvalidPort','input lower bounds',nu,widths.Inport(portnum))];
    end
    if ~(ports(portnum+1).SrcBlock<0) ... % if UMAX signal is connected ...
          && widths.Inport(portnum+1)~=nu,
       err=[err ctrlMsgUtils.message('MPC:utility:InvalidPort','input upper bounds',nu,widths.Inport(portnum+1))];
    end
    if ~(ports(portnum+2).SrcBlock<0) ... % if YMIN signal is connected ...
          && widths.Inport(portnum+2)~=ny,
       err=[err ctrlMsgUtils.message('MPC:utility:InvalidPort','output lower bounds',ny,widths.Inport(portnum+2))];
    end
    if ~(ports(portnum+3).SrcBlock<0) ... % if YMAX signal is connected ...
          && widths.Inport(portnum+3)~=ny,
       err=[err ctrlMsgUtils.message('MPC:utility:InvalidPort','output upper bounds',ny,widths.Inport(portnum+3))];
    end
end

if ~isempty(err),
    ctrlMsgUtils.error('InvalidBlockSignalDimensionGeneral',err);
end