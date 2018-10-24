function mpc_block_resize(blk)
% MPC_BLOCK_RESIZE Modify the I/O structure depending on whether MDs,
% externally supplied MV signals, time-varying LIMITS, and/or SWITCH signal 
% are present
%
% MPC_BLOCK_RESIZE is called in the mask initialization code.  The
% initialization code initializes the masked subsystem at critical times,
% such as model loading and the start of a simulation run.

%   Authors: A. Bemporad, J. Owen
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2009/07/18 15:53:00 $

%% Obtain current availability of the optional inport ports in the block
AvailableBlocks = get_param(blk,'Blocks');
type_in_block = get_type(ismember('md',AvailableBlocks),...
                        ismember('ext.mv',AvailableBlocks),...
                        ismember('umin',AvailableBlocks),...
                        ismember('switch',AvailableBlocks));

%% Obtain availability of the optional inport ports from the block dialog
% get mask dialog handle (empty if not open)
type_in_mask = get_type(strcmp(get_param(blk,'md_inport'),'on'), ...
                        strcmp(get_param(blk,'mv_inport'),'on'),...
                        strcmp(get_param(blk,'lims_inport'),'on'),...
                        strcmp(get_param(blk,'switch_inport'),'on'));
% In case of MPC blocks belonging to a Multiple MPCblock, the block
% must be always resized to full signal configuration
if str2double(get_param(blk,'is_multiple'))==1
    type_in_mask = get_type(1,1,1,1);
end

%% update block if there is a difference
maskdisplay=get_param(blk,'MaskDisplay');
if type_in_mask~=type_in_block
    % Reset maskdisplay to display first two input ports (mo, ref)
    aux='port_label(''input'', 2, ''ref'')';
    pos=findstr(maskdisplay,aux)+length(aux);
    maskdisplay=maskdisplay(1:pos-1);
    del_md(blk,AvailableBlocks);
    del_ext_mv(blk,AvailableBlocks);
    del_umin(blk,AvailableBlocks);
    del_umax(blk,AvailableBlocks);
    del_ymin(blk,AvailableBlocks);
    del_ymax(blk,AvailableBlocks);
    del_switch(blk,AvailableBlocks);
    switch type_in_mask
        case 2
            % no optional signals
        case 3.1
            % MD
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
        case 3.2
            % EXT.MV 
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''ext.mv'')'];
        case 4
            % MD, EXT.MV 
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''ext.mv'')'];
        case 12
            % LIMITS
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''ymax'')'];
        case 13.1
            % MD, LIMITS
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''ymax'')'];
        case 13.2
            % EXT.MV, LIMITS
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''ext.mv'')'];
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''ymax'')'];
        case 14
            % MD, EXT.MV, LIMITS
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
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
        case 102
            % SWITCH
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''QP switch'')'];
        case 103.1
            % MD, SWITCH
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''QP switch'')'];
        case 103.2
            % EXT.MV, SWITCH
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''ext.mv'')'];
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''QP switch'')'];
        case 104
            % MD, EXT.MV, SWITCH
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''ext.mv'')'];
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''QP switch'')'];
        case 112
            % LIMITS, SWITCH
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''ymax'')'];
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''QP switch'')'];
        case 113.1
            % MD, LIMITS, SWITCH
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''ymax'')'];
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 8, ''QP switch'')'];
        case 113.2
            % EXT.MV, LIMITS, SWITCH
            add_ext_mv(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''ext.mv'')'];
            add_umin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 4, ''umin'')'];
            add_umax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 5, ''umax'')'];
            add_ymin(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 6, ''ymin'')'];
            add_ymax(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 7, ''ymax'')'];
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 8, ''QP switch'')'];
        case 114
            % MD, EXT.MV, LIMITS, SWITCH
            add_md(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
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
            add_switch(blk);
            maskdisplay=[maskdisplay char(10) 'port_label(''input'', 9, ''QP switch'')'];
    end
    set_param(blk,'MaskDisplay',maskdisplay);
end


%% Local Function
function type=get_type(MDenabled,MVenabled,LIMSenabled,SWITCHenabled)
type=2*(~MDenabled & ~MVenabled) + ...% just MO and REF
    3.1*(MDenabled & ~MVenabled) + ... % MO, MD and REF
    3.2*(~MDenabled & MVenabled) + ... % MO, EXT.MV and REF
    4*(MDenabled & MVenabled);         % MO, MD, EXT.MV and REF
type=type+10*LIMSenabled;
type=type+100*SWITCHenabled;

%---------------
function del_md(blk,AvailableBlocks)
if ismember('md',AvailableBlocks)
    delete_line(blk,'md/1','sfunction/3');
    delete_block([blk '/md']);
    add_block('built-in/Ground',[blk '/md_ground']);
    add_line(blk,'md_ground/1','sfunction/3');
    set_param([blk '/md_ground'],'position',[230    83   260    97]);
    set_param([blk '/md_ground'],'orientation','left');
end
set_param(blk,'md_inport','off')

%---------------
function add_md(blk)
delete_line(blk,'md_ground/1','sfunction/3');
delete_block([blk '/md_ground']);
add_block([blk '/mo'],[blk '/md']);
add_line(blk,'md/1','sfunction/3');
set_param([blk '/md'],'position',[230    83   260    97]);
set_param([blk '/md'],'orientation','left');
set_param(blk,'md_inport','on');

%---------------
function del_ext_mv(blk,AvailableBlocks)
if ismember('ext.mv',AvailableBlocks)
    delete_line(blk,'ext.mv/1','sfunction/4');
    delete_block([blk '/ext.mv']);
    add_block('built-in/Ground',[blk '/mv_ground']);
    add_line(blk,'mv_ground/1','sfunction/4');
    set_param([blk '/mv_ground'],'position',[185   108   215   122]);
    set_param([blk '/mv_ground'],'orientation','left');
end
set_param(blk,'mv_inport','off')

%---------------
function add_ext_mv(blk)
delete_line(blk,'mv_ground/1','sfunction/4');
delete_block([blk '/mv_ground']);
add_block([blk '/mo'],[blk '/ext.mv']);
add_line(blk,'ext.mv/1','sfunction/4');
set_param([blk '/ext.mv'],'position',[185   108   215   122]);
set_param([blk '/ext.mv'],'orientation','left');
set_param(blk,'mv_inport','on');

%---------------
function del_umin(blk,AvailableBlocks)
if ismember('umin',AvailableBlocks)
    delete_line(blk,'umin/1','sfunction/5');
    delete_block([blk '/umin']);
    add_block('built-in/Ground',[blk '/umin_ground']);
    add_line(blk,'umin_ground/1','sfunction/5');
    set_param([blk '/umin_ground'],'position',[265   133   295   147]);
    set_param([blk '/umin_ground'],'orientation','left');
end
set_param(blk,'lims_inport','off')

%---------------
function add_umin(blk)
delete_line(blk,'umin_ground/1','sfunction/5');
delete_block([blk '/umin_ground']);
add_block([blk '/mo'],[blk '/umin']);
add_line(blk,'umin/1','sfunction/5');
set_param([blk '/umin'],'position',[265   133   295   147]);
set_param([blk '/umin'],'orientation','left');
set_param(blk,'lims_inport','on');

%---------------
function del_umax(blk,AvailableBlocks)
if ismember('umax',AvailableBlocks)
    delete_line(blk,'umax/1','sfunction/6');
    delete_block([blk '/umax']);
    add_block('built-in/Ground',[blk '/umax_ground']);
    add_line(blk,'umax_ground/1','sfunction/6');
    set_param([blk '/umax_ground'],'position',[205   158   235   172]);
    set_param([blk '/umax_ground'],'orientation','left');
end
set_param(blk,'lims_inport','off')

%---------------
function add_umax(blk)
delete_line(blk,'umax_ground/1','sfunction/6');
delete_block([blk '/umax_ground']);
add_block([blk '/mo'],[blk '/umax']);
add_line(blk,'umax/1','sfunction/6');
set_param([blk '/umax'],'position',[205   158   235   172]);
set_param([blk '/umax'],'orientation','left');
set_param(blk,'lims_inport','on');

%---------------
function del_ymin(blk,AvailableBlocks)
if ismember('ymin',AvailableBlocks)
    delete_line(blk,'ymin/1','sfunction/7');
    delete_block([blk '/ymin']);
    add_block('built-in/Ground',[blk '/ymin_ground']);
    add_line(blk,'ymin_ground/1','sfunction/7');
    set_param([blk '/ymin_ground'],'position',[265   183   295   197]);
    set_param([blk '/ymin_ground'],'orientation','left');
end
set_param(blk,'lims_inport','off')

%---------------
function add_ymin(blk)
delete_line(blk,'ymin_ground/1','sfunction/7');
delete_block([blk '/ymin_ground']);
add_block([blk '/mo'],[blk '/ymin']);
add_line(blk,'ymin/1','sfunction/7');
set_param([blk '/ymin'],'position',[265   183   295   197]);
set_param([blk '/ymin'],'orientation','left');
set_param(blk,'lims_inport','on');

%---------------
function del_ymax(blk,AvailableBlocks)
if ismember('ymax',AvailableBlocks)
    delete_line(blk,'ymax/1','sfunction/8');
    delete_block([blk '/ymax']);
    add_block('built-in/Ground',[blk '/ymax_ground']);
    add_line(blk,'ymax_ground/1','sfunction/8');
    set_param([blk '/ymax_ground'],'position',[205   208   235   222]);
    set_param([blk '/ymax_ground'],'orientation','left');
end
set_param(blk,'lims_inport','off')

%---------------
function add_ymax(blk)
delete_line(blk,'ymax_ground/1','sfunction/8');
delete_block([blk '/ymax_ground']);
add_block([blk '/mo'],[blk '/ymax']);
add_line(blk,'ymax/1','sfunction/8');
set_param([blk '/ymax'],'position',[205   208   235   222]);
set_param([blk '/ymax'],'orientation','left');
set_param(blk,'lims_inport','on');

%---------------
function del_switch(blk,AvailableBlocks)
if ismember('switch',AvailableBlocks)
    delete_line(blk,'switch/1','sfunction/9');
    delete_block([blk '/switch']);
    add_block('built-in/Ground',[blk '/switch_ground']);
    add_line(blk,'switch_ground/1','sfunction/9');
    set_param([blk '/switch_ground'],'position',[270   230   290   250]);
    set_param([blk '/switch_ground'],'orientation','left');
end
set_param(blk,'switch_inport','off')

%---------------
function add_switch(blk)
delete_line(blk,'switch_ground/1','sfunction/9');
delete_block([blk '/switch_ground']);
add_block([blk '/mo'],[blk '/switch']);
add_line(blk,'switch/1','sfunction/9');
set_param([blk '/switch'],'position',[265   233   295   247])
set_param([blk '/switch'],'orientation','left');
set_param(blk,'switch_inport','on');
