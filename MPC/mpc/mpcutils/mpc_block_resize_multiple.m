function mpc_block_resize_multiple(blk)
% MPC_BLOCK_RESIZE_MULTIPLE Modify the I/O structure depending on whether MDs,
% and time-varying LIMITS are present

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/07/18 15:53:01 $

hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>

%% Obtain current availability of the optional inport ports in the block
AvailableBlocks = get_param(blk,'Blocks');
type_in_block = get_type(ismember('md',AvailableBlocks),...
                        ismember('ext.mv',AvailableBlocks),...
                        ismember('umin',AvailableBlocks));

%% Obtain availability of the optional inport ports from the block dialog
% get mask dialog handle (empty if not open)
type_in_mask = get_type(strcmp(get_param(blk,'md_inport_multiple'),'on'), ...
                        strcmp(get_param(blk,'mv_inport_multiple'),'on'),...
                        strcmp(get_param(blk,'lims_inport_multiple'),'on'));
                    
%% update block if there is a difference
maskdisplay=get_param(blk,'MaskDisplay');
if type_in_mask~=type_in_block
    % Reset maskdisplay to display first three input ports (switch, mo, ref)
    aux='port_label(''input'', 3, ''ref'')';
    pos=findstr(maskdisplay,aux)+length(aux);
    maskdisplay=maskdisplay(1:pos-1);
    del_md(blk,AvailableBlocks);
    del_ext_mv(blk,AvailableBlocks);
    del_umin(blk,AvailableBlocks);
    del_umax(blk,AvailableBlocks);
    del_ymin(blk,AvailableBlocks);
    del_ymax(blk,AvailableBlocks);
    switch type_in_mask
        case 1
            % no optional signals
        case 2
            % MD
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''md'')'];
        case 3
            % LIMITS
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''ymax'')'];
        case 4
            % MD, LIMITS
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''md'')'];
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 8, ''ymax'')'];
        case 11
            % EXT.MV
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''ext.mv'')'];
        case 12
            % MD, EXT.MV
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''md'')'];
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''ext.mv'')'];
        case 13
            % LIMITS, EXT.MV
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''ext.mv'')'];
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 8, ''ymax'')'];
        case 14
            % MD, LIMITS, EXT.MV
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''md'')'];
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''ext.mv'')'];
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 8, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 9, ''ymax'')'];
    end
    set_param(blk,'MaskDisplay',maskdisplay);
end

%% Add or remove MPC blocks if the number of MPC controllers is changed
% Required number of MPC blocks from mask parameter
N = str2double(get_param(blk,'Nmpc'));
% Current number of MPC blocks in the block
if ismember('Sum_ground',AvailableBlocks)
    oldN = 1;
else
    oldN = length(get_param([blk '/Sum'],'Inputs'));
end
% detect whether a MPC block should be added or deleted
dN = N-oldN; 
% Because of the Add/Delete buttons, dN = N-oldN is either 0, 1 or -1. 
% The code below works for any dN, though.
if dN>0
    % add new MPC controllers to the end
    % Change number of inputs to Sum
    set_param([blk '/Sum'],'Inputs',char('+'*ones(1,N))); % N>1
    % if oldN is 1, remove the ground block
    if oldN==1,
        delete_line(blk,'Sum_ground/1','Sum/2');
        delete_block([blk '/Sum_ground']);
    end
    % Create dN new MPC controllers
    for i=oldN+1:N,
        % Copy MPC block MPC1 into a new one
        MPCname = sprintf('MPC%d',i);
        add_block([blk '/MPC1'],[blk '/' MPCname]);
        h=20*(i-1);
        set_param([blk '/' MPCname],'Position',[315+h   106+h   400+h   344+h],...
            'enable_value',num2str(i),'mpcobj','');
        % Connect MPC block to Sum
        add_line(blk,[MPCname '/1'],sprintf('Sum/%d',i));
        % Connect From to MPC block
        for j=1:9,
            add_line(blk,sprintf('From %d/1',j),[MPCname sprintf('/%d',j)]);
        end
    end
elseif dN<0,
    theMPC = str2double(get_param(blk,'theMPC'));
    if theMPC>0
        % delete from delete button
        % Delete MPC controllers indexed by 'theMPC'
        deleteBlock(blk, theMPC, N, oldN);
    else
        % delete blocks from canceling dialog
        for ct = N:-1:N+dN+1
            deleteBlock(blk, ct, N, oldN);
        end
    end
else
    % do nothing
end

%% Update mask parameters for each MPC block based on mmpc values
% we only loop through minimum of N, length of mpcobjs and length of x0s to
% avoid set_param failure (which does not generate hard error).  In normal
% cases these values are the same.  When 'add' button is clicked, N is
% updated first, then mocobjs, then x0s so at different moments the values
% are different.  In the end they will be the same after all the set_param
% references are executed in the 'add' button callback.
currmpcobjs = eval(get_param(blk,'mpcobjs'));
currmpcx0s = eval(get_param(blk,'x0s'));
currmpcnmv = eval(get_param(blk,'nmv'));
for ct = 1:min(min(N,length(currmpcobjs)),length(currmpcx0s))
    mpcblk = [blk '/MPC' num2str(ct)];
    % mpc object
    set_param(mpcblk,'mpcobj',currmpcobjs{ct});
    % x0
    if ischar(currmpcx0s{ct})
        set_param(mpcblk,'x0',currmpcx0s{ct});
    else
        set_param(mpcblk,'x0','[]');
        set_param(blk,'x0s','{''[]''}');
    end
    % number of mv
    set_param(mpcblk,'n_mv',num2str(currmpcnmv));
end
% Fill in parameters in MPC blocks related to ref and MD signals
mpc_fillblocks_multiple(blk,N);
% Make sure the manual switch is at the right position
set_param([blk '/Manual Switch'],'sw',get_param(blk,'linswitch'));

%% Local Function
function type=get_type(md_inport_multiple,mv_inport_multiple,lims_inport_multiple)
type=1*(~md_inport_multiple & ~lims_inport_multiple) + ...% MO and REF
    2*(md_inport_multiple & ~lims_inport_multiple) + ...  % MD, MO, and REF
    3*(~md_inport_multiple & lims_inport_multiple) + ...  % LIMS, MO and REF
    4*(md_inport_multiple & lims_inport_multiple);        % MD, LIMS, MO, and REF
if mv_inport_multiple,
    type=type+10;
end

%---------------
function del_md(blk,AvailableBlocks)
if ismember('md',AvailableBlocks)
    delete_line(blk,'md/1','Goto 3/1');
    delete_block([blk '/md']);
    add_block('built-in/Ground',[blk '/md_ground']);
    add_line(blk,'md_ground/1','Goto 3/1');
    set_param([blk '/md_ground'],'position',[755   168   785   182]);
    set_param([blk '/md_ground'],'orientation','left');
end

%---------------
function add_md(blk)
delete_line(blk,'md_ground/1','Goto 3/1');
delete_block([blk '/md_ground']);
add_block([blk '/mo'],[blk '/md']);
add_line(blk,'md/1','Goto 3/1');
set_param([blk '/md'],'position',[755   168   785   182]);
set_param([blk '/md'],'orientation','left');

%---------------
function del_umin(blk,AvailableBlocks)
if ismember('umin',AvailableBlocks)
    delete_line(blk,'umin/1','Goto 5/1');
    delete_block([blk '/umin']);
    add_block('built-in/Ground',[blk '/umin_ground']);
    add_line(blk,'umin_ground/1','Goto 5/1');
    set_param([blk '/umin_ground'],'position',[755   218   785   232]);
    set_param([blk '/umin_ground'],'orientation','left');
end

%---------------
function add_umin(blk)
delete_line(blk,'umin_ground/1','Goto 5/1');
delete_block([blk '/umin_ground']);
add_block([blk '/mo'],[blk '/umin']);
add_line(blk,'umin/1','Goto 5/1');
set_param([blk '/umin'],'position',[755   218   785   232]);
set_param([blk '/umin'],'orientation','left');

%---------------
function del_umax(blk,AvailableBlocks)
if ismember('umax',AvailableBlocks)
    delete_line(blk,'umax/1','Goto 6/1');
    delete_block([blk '/umax']);
    add_block('built-in/Ground',[blk '/umax_ground']);
    add_line(blk,'umax_ground/1','Goto 6/1');
    set_param([blk '/umax_ground'],'position',[705   243   735   257]);
    set_param([blk '/umax_ground'],'orientation','left');
end

%---------------
function add_umax(blk)
delete_line(blk,'umax_ground/1','Goto 6/1');
delete_block([blk '/umax_ground']);
add_block([blk '/mo'],[blk '/umax']);
add_line(blk,'umax/1','Goto 6/1');
set_param([blk '/umax'],'position',[705   243   735   257]);
set_param([blk '/umax'],'orientation','left');

%---------------
function del_ymin(blk,AvailableBlocks)
if ismember('ymin',AvailableBlocks)
    delete_line(blk,'ymin/1','Goto 7/1');
    delete_block([blk '/ymin']);
    add_block('built-in/Ground',[blk '/ymin_ground']);
    add_line(blk,'ymin_ground/1','Goto 7/1');
    set_param([blk '/ymin_ground'],'position',[755   268   785   282]);
    set_param([blk '/ymin_ground'],'orientation','left');
end

%---------------
function add_ymin(blk)
delete_line(blk,'ymin_ground/1','Goto 7/1');
delete_block([blk '/ymin_ground']);
add_block([blk '/mo'],[blk '/ymin']);
add_line(blk,'ymin/1','Goto 7/1');
set_param([blk '/ymin'],'position',[755   268   785   282]);
set_param([blk '/ymin'],'orientation','left');

%---------------
function del_ymax(blk,AvailableBlocks)
if ismember('ymax',AvailableBlocks)
    delete_line(blk,'ymax/1','Goto 8/1');
    delete_block([blk '/ymax']);
    add_block('built-in/Ground',[blk '/ymax_ground']);
    add_line(blk,'ymax_ground/1','Goto 8/1');
    set_param([blk '/ymax_ground'],'position',[705   293   735   307]);
    set_param([blk '/ymax_ground'],'orientation','left');
end

%---------------
function add_ymax(blk)
delete_line(blk,'ymax_ground/1','Goto 8/1');
delete_block([blk '/ymax_ground']);
add_block([blk '/mo'],[blk '/ymax']);
add_line(blk,'ymax/1','Goto 8/1');
set_param([blk '/ymax'],'position',[705   293   735   307]);
set_param([blk '/ymax'],'orientation','left');

%---------------
function del_ext_mv(blk,AvailableBlocks)
if ismember('ext.mv',AvailableBlocks)
    delete_line(blk,'ext.mv/1','Goto 4/1');
    delete_block([blk '/ext.mv']);
    add_line(blk,'Sum/1','Goto 4/1');
end

%---------------
function add_ext_mv(blk)
delete_line(blk,'Sum/1','Goto 4/1');
add_block([blk '/mo'],[blk '/ext.mv']);
add_line(blk,'ext.mv/1','Goto 4/1');
set_param([blk '/ext.mv'],'position',[640   193   670   207]);
set_param([blk '/ext.mv'],'orientation','left');

%---------------
function deleteBlock(blk, theMPC, N, oldN)
% which block
MPCname = sprintf('MPC%d',theMPC);
% Disconnect 'From' from MPC block
for j=1:9,
    delete_line(blk,sprintf('From %d/1',j),[MPCname sprintf('/%d',j)]);
end
% Delete connection from MPC block to Sum
delete_line(blk,[MPCname '/1'],sprintf('Sum/%d',theMPC));
% Delete MPC block
delete_block([blk '/' MPCname]);
% Rename MPC blocks from theMPC+1 to the last one and remove connection
% to Sum
for i=theMPC+1:oldN,
    MPCname=sprintf('MPC%d',i); % block to be renamed
    delete_line(blk,[MPCname '/1'],sprintf('Sum/%d',i));
    newMPCname=sprintf('MPC%d',i-1); % new name
    set_param([blk '/' MPCname],'Name',newMPCname);
end
% Change number of inputs to Sum
set_param([blk '/Sum'],'Inputs',char('+'*ones(1,max(N,2))));
% Reconnect remaining MPC blocks from theMPC+1 to the last one. 
% Parameter 'enable_value' is updated by the mask function
for i=theMPC:N,
    MPCname=sprintf('MPC%d',i); % block to be reconnected
    add_line(blk,[MPCname '/1'],sprintf('Sum/%d',i));
end
% In case N=1, grounds second dummy input to Sum
if N==1,
    add_block('built-in/Ground',[blk '/Sum_ground']);
    add_line(blk,'Sum_ground/1','Sum/2');
    set_param([blk '/Sum_ground'],'position',[230   348   260   362]);
    set_param([blk '/Sum_ground'],'orientation','left');
end
% Adjust position of all MPC blocks + Sum in diagram
for i=1:N,
    MPCname=sprintf('MPC%d',i);
    h=20*(i-1);
    set_param([blk '/' MPCname],'Position',[315+h   106+h   400+h   344+h]);
end
set_param([blk '/Sum'],'Position',[175   161   200   419]);

