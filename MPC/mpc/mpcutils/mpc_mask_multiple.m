function mpc_mask_multiple(varargin)
% MPC_MASK_MULTIPLE Mask for multiple MPC block

%   Authors: A. Bemporad, R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2009/07/18 15:53:04 $

% Syntax with input args is:
%
% Case 1: mpc_mask_multiple()
% open from double-clicking Multiple MPC block mask dialog
%
% Case 2: mpc_mask_multiple('refresh') just refreshes controller table
%
% Case 3: mpc_mask_multiple('load', blksystem, '', mpc_block, hGUI)
% an saved Multiple MPC block design task has been loaded from a CETM project (called by postLoad) 
%
% Case 4: mpc_mask_multiple('open_by_cetm', blksystem, proj)
% start a new design task from CETM's new project and new task dialogs
%

%% Quantity to automatically enlarge and vertically shift all items in mask
persistent hTable
voffset=1.7;
EditHeight=1.54;

%% Initialization
if nargin==0
    % Case 1
    blksystem = bdroot(gcs);
    proj = [];
    blk = gcb;
    blkh = gcbh;
else
    option=varargin{1};
    switch option
        case 'refresh'
            blksystem = bdroot(gcs);
            proj = [];
            blk = gcb;
            blkh = gcbh;
        case 'load'
            % Case 2
            blksystem = varargin{2};
            if isempty(find_system('Name',blksystem))
                open_system(blksystem)
            end
            proj = varargin{3};            
            blk = varargin{4};
            if isempty(blk)
                % Select the right mpc block
                blk = mpc_getblockpath(blksystem,'Multiple MPC'); 
            end
            if isempty(blk)
                return % There is no MPC block in the model
            end
            blkh = get_param(blk,'Handle');
            task_name = varargin{5};
        case 'open_by_cetm'
            % Case 4
            blksystem = varargin{2};
            proj = varargin{3};            
            % Select the right block automatically and manually
            blk = mpc_getblockpath(blksystem,'Multiple MPC'); 
            if isempty(blk)
                return % There is no MPC block in the model
            end
            blkh = get_param(blk,'Handle');
        otherwise
            ctrlMsgUtils.error('Controllib:general:UnexpectedError','wrong syntax when using "slmpctool" command');
    end
end

% are any masks already open?
oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag', 'MPC_mask_multiple');
set(0,'ShowHiddenHandles',oldsh');
f = findobj(fig, 'flat', 'UserData', blkh);

%% Get values from MPC block
mask_names = get_param(blkh,'MaskNames');
mask_values = get_param(blkh,'MaskValues');
saved_mask = cell2struct(mask_values,mask_names);

%% Create mask dialog when not exisitng
if isempty(f)
    %% Get values from MPC block
    Nmpc = get_param(blkh,'Nmpc');                                          %1
    
    ref_from_ws_multiple = get_param(blkh,'ref_from_ws_multiple');          %'off'
    ref_signal_name_multiple = get_param(blkh,'ref_signal_name_multiple');  %'[]'
    ref_preview_multiple = get_param(blkh,'ref_preview_multiple');          %'on'
    
    md_from_ws_multiple = get_param(blkh,'md_from_ws_multiple');            %'off'
    md_signal_name_multiple = get_param(blkh,'md_signal_name_multiple');    %'[]'
    md_preview_multiple = get_param(blkh,'md_preview_multiple');            %'on'
    
    md_inport_multiple= get_param(blkh,'md_inport_multiple');               %'on'
    mv_inport_multiple= get_param(blkh,'mv_inport_multiple');               %'off'
    lims_inport_multiple= get_param(blkh,'lims_inport_multiple');           %'off'

    %% UICONTROL wants 0 or 1, not 'on' or 'off' as the checkbox variable
    ref_from_ws_multiple=~strcmp(ref_from_ws_multiple,'off');
    ref_preview_multiple=~strcmp(ref_preview_multiple,'off');
    md_from_ws_multiple=~strcmp(md_from_ws_multiple,'off');
    md_preview_multiple=~strcmp(md_preview_multiple,'off');
    md_inport_multiple=~strcmp(md_inport_multiple,'off');
    mv_inport_multiple=~strcmp(mv_inport_multiple,'off');
    lims_inport_multiple=~strcmp(lims_inport_multiple,'off');

    % Gray out everything if the mask is invoked from the MPC Library
    ref_enabled = 'off';
    md_enabled = 'off';
    if strcmp(blk,'mpclib/Multiple MPC Controllers'),
        enabled = 'off'; 
    else
        enabled = 'on';
        if ref_from_ws_multiple,
            ref_enabled = 'on';
        end
        if md_from_ws_multiple,
            md_enabled = 'on';
        end
    end

    %% Create Mask Figure
    f = figure('Visible','off');
    set(f, 'Tag', 'MPC_mask_multiple', 'UserData',blkh, 'units', 'characters',...
        'numbertitle','off','name','Block Parameters: Multiple MPC','Dockcontrols','off',...
        'position',[73.8 16 92 41.7+voffset],'MenuBar','none','Resize','off',...
        'NumberTitle','off','PaperPosition',get(0,'defaultfigurePaperPosition'),...
        'Color',get(0,'DefaultUIcontrolBackgroundColor'),'HandleVisibility','off');

    % top box
    frame1 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 28+voffset 88 13],...
        'String',{ 'Frame' },...
        'Style','frame',...
        'Tag','frame1','Enable',enabled); 

    % top box title
    text1 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[3.2 40+voffset 35 1.3],...
        'String','Multiple MPC block (mask) (link)',...
        'Style','text',...
        'Tag','text1','Enable',enabled); 

    % top box text
    msg = sprintf('%s\n%s%s%s\n%s%s%s%s\n%s%s%s',...
        'The Multiple MPC block lets you design switched model predictive controllers. ',...
        'Click "Add" to insert a new controller and define its properties. ',...
        'Click "Design" to change the properties of the selected MPC controllers. ',...
        'Click "Delete" to remove the selected MPC controllers. ',...
        'The external switching signal decides in real-time which MPC block should ',...
        'compute the manipulated variable. The switching signal must be ',...
        'a scalar between 1 (first MPC block) and N. The number associated to each ',...
        'MPC controller is the one shown in the controller list.',...
        'While only the triggered controller solves its QP optimization, ',...
        'all controllers update their internal state observers, to smooth ',...
        'out controller transitions.' ...
    );

    h101 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[2.6 28.43+voffset 80 1.2*9],...
        'String',msg,...
        'Style','text',...
        'Tag','text101','Enable',enabled); 

    % middle box
    frame2 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 16+voffset 88.2 11],...
        'String',{ 'Frame' },...
        'Style','frame',...
        'Tag','frame2','Enable',enabled); 

    % mpc table in the middle box
    colnames = {'Name', 'MPC Object', 'Initial States', 'Delete it?', 'Design it?'};
    columnformat = {'char', 'char', 'char', 'logical' 'logical'};
    columneditable =  [false true true true true]; 
    hTable = uitable('Parent', f, 'Data', cell(0,5), 'ColumnName', colnames, ...
                     'ColumnFormat', columnformat, 'ColumnEditable', columneditable);
    set(hTable,'ColumnWidth','auto');
    set(hTable,'Units','characters');
    set(hTable,'Position',[4,18.5+voffset,84,7.5]); % [left bottom width height]
    set(hTable,'Tag', 'MPCUITable');
    set(hTable,'RowName',[]);
    set(hTable,'Enable','on');
    % populate table based on saved data
    populateTable(hTable,blkh);
    
    % buttons in the middle box    
    btnADD = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[36 16.3+voffset 16 1.77],...
        'String','Add','TooltipString','Add a new MPC controller',...
        'Tag','pushbuttonADD','Enable',enabled);
    btnDELETE = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[54 16.3+voffset 16 1.77],...
        'String','Delete','TooltipString','Delete selected MPC controllers',...
        'Tag','pushbuttonDELETE','Enable',enabled);
    btnSET = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[72 16.3+voffset 16 1.77],...
        'String','Design','TooltipString','Design/Edit selected MPC controllers in the MPC Design Tool',...
        'Tag','pushbuttonSET','Enable',enabled);

    % Number of mpc text (read only) in the middle box
    textNmpc = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[4.4 16.5+voffset 27 1.15],...
        'String','Number of MPC controllers:',...
        'Style','text',...
        'Tag','text16','Enable',enabled); %#ok<NASGU>
    TextBoxObj = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[32 16.5+voffset 4 1.15],...
        'String', Nmpc,...
        'Style','text',...
        'Tag','number_of_mpc','Enable',enabled,'Visible','on');

    % Common signal properties
    chkMDInputPort = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 7.0+voffset 47.4 1.15],...
        'String','Enable input port for measured disturbance',...
        'Value',md_inport_multiple,...
        'Style','checkbox',...
        'TooltipString','Apply feed-forward control on measured disturbances',...        
        'Tag','checkbox_md','Enable',enabled);
    
    chkMVInputPort = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 5.4+voffset 120 1.15],...
        'String','Enable input port for externally supplied manipulated variables to plant',...
        'Value',mv_inport_multiple,...
        'Style','checkbox',...
        'TooltipString','Update the internal MPC state estimate through the externally supplied signal',...
        'Tag','checkbox_mv','Enable',enabled);

    chkLIMSInputPort = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 3.8+voffset 47.4 1.15],...
        'String','Enable input port for input and output limits',...
        'Value',lims_inport_multiple,...
        'Style','checkbox',...
        'TooltipString','Apply run-time limits on inputs and outputs',...        
        'Tag','checkbox_lims','Enable',enabled);

    % bottom buttons
    % ok
    btnOK = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[22.8 0.615 15 1.77],...
        'String','OK','TooltipString','Apply latest changes and close the dialog',...
        'Tag','pushbutton3','Enable',enabled);
    % cancel
    btnCancel = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[40 0.615 15 1.769],...
        'String','Cancel','TooltipString','Close the dialog without applying latest changes',...
        'Tag','pushbutton6','Enable','on');       
    % help
    btnHelp = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[57.6 0.615 15 1.769],...
        'String','Help','TooltipString','Open the content sensitive help window',...
        'Tag','pushbutton7','Enable',enabled);
    % apply
    btnApply = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[75 0.615 15 1.769],...
        'String','Apply','TooltipString','Apply latest changes and leave the dialog open',...
        'Tag','pushbutton8','Enable',enabled); 
    
    % Reference and MD signals
    frameRefMD = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 9.20+voffset 88.2 5.7],...
        'String',{ 'Frame' },...
        'Style','frame',...
        'Tag','framerefMD','Enable',enabled);

    h13 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[5.6 14.2+voffset 12.5 1.15],...
        'String','Input signals',...
        'Style','text',...
        'Tag','text4','Enable',enabled);

    h18 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[3.6 12.8+voffset 12.4 1.15],...
        'String','Use custom',...
        'Style','text',...
        'Tag','text5','Enable',enabled);
    
    editBoxRef = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left',...
        'Position',[31.8 11.5+voffset 33.2 EditHeight],...
        'String',ref_signal_name_multiple,...
        'TooltipString','Output reference signal (structure with fields ''time'' and ''signals'' -- See ''To Workspace'' block)',...
        'Style','edit',...
        'Tag','edit1','Enable',ref_enabled);

    editBoxMD = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left',...
        'Position',[31.8 9.6+voffset 33.2 EditHeight],...
        'String',md_signal_name_multiple,...
        'Style','edit',...
        'TooltipString','Measured disturbance signal (structure with fields ''time'' and ''signals'' -- See ''To Workspace'' block)',...
        'Tag','edit4','Enable',md_enabled);

    chkref_preview = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[69.8 11.4+voffset 17.2 1.61538461538462],...
        'String','Look ahead',...
        'TooltipString','Use future samples of reference signals (anticipative action)',...
        'Style','checkbox',...
        'Tag','checkbox4','Enable',ref_enabled,'Value',ref_preview_multiple);

    chkMD_preview = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[69.8 9.5+voffset 17.2 1.61538461538462],...
        'String','Look ahead',...
        'Style','checkbox',...
        'TooltipString','Use future samples of measured disturbance signals (anticipative action)',...
        'Tag','checkbox5','Enable',md_enabled,'Value',md_preview_multiple);

    refuis=[editBoxRef chkref_preview];
    chkref_from_ws = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[3 11.3+voffset 25 1.15],...
        'String','Reference signal',...
        'callback',{@ChkCallBack refuis blkh},...
        'Style','checkbox',...
        'Value',ref_from_ws_multiple,...
        'TooltipString','Load reference signal from workspace','value',strcmp(ref_enabled,'on'),...
        'Tag','checkbox3','Enable',enabled);

    MDuis=[editBoxMD chkMD_preview];
    chkMD_from_ws = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[3 9.7+voffset 28 1.15],...
        'String','Measured disturbance',...
        'callback',{@ChkCallBack MDuis blkh},...
        'Style','checkbox',...
        'Value',md_from_ws_multiple,...
        'TooltipString','Load measured disturbance signal from workspace',...
        'Tag','checkbox6','Enable',enabled);

    %% Callbacks
    % Fields in multi-MPC mask that store all parameters of underlying MPC
    % blocks and corresponding default values
    fields={'mpcobj','x0'};
    defaults={'','[]'};
    set(hTable,'CellEditCallback',{@TableDataChangedCallBack blkh});
    set(btnADD,'callback',{@ADDCallBack f TextBoxObj hTable blkh fields defaults});
    set(btnDELETE,'callback',{@DELETECallBack f TextBoxObj hTable blkh fields});
    set(btnSET,'callback',{@SETCallBack f hTable blkh blksystem proj});
    set(btnOK,'callback',{@OKCallBack f enabled blkh chkMDInputPort chkMVInputPort chkLIMSInputPort fields ...
        chkref_from_ws editBoxRef chkref_preview chkMD_from_ws editBoxMD chkMD_preview saved_mask btnCancel});
    set(btnCancel,'callback',{@CancelCallBack f blkh saved_mask});
    set(btnHelp,'callback',{@mpcCSHelp, 'MPCmaskMultiple'});
    set(btnApply,'callback',{@ApplyCallBack blkh f chkMDInputPort chkMVInputPort chkLIMSInputPort fields ...
        chkref_from_ws editBoxRef chkref_preview chkMD_from_ws editBoxMD chkMD_preview saved_mask btnCancel});
    set(chkMDInputPort,'callback',{@MDInportCallBack blkh});
    set(chkMVInputPort,'callback',{@MVInportCallBack blkh});
    set(chkLIMSInputPort,'callback',{@LIMSInportCallBack blkh});

end

%% Bring up mask dialog
if nargin==0
%     if ~isempty(hTable)
%         populateTable(hTable,blkh);
%     end
    set(f, 'Visible','on');
    figure(f); 
else
    switch option
        case 'refresh'
            TextBoxObj = findobj(f,'Tag','text5');
            set(TextBoxObj,'String',get_param(blkh,'Nmpc'));
            populateTable(hTable,blkh);
            set(f, 'Visible','on');
            figure(f); % Bring it to front
        case 'load'
            [hJava,hUDD,M] = slctrlexplorer('initialize');
            M.ExplorerPanel.setSelected(hUDD.getTreeNodeInterface);
            [project, FRAME] = getvalidproject(blksystem,true);
            project_name=project.Label;
            setappdata(f,'project_name',project_name);
            setappdata(f,'task_name',task_name);
%             MPCNodes = hGUI.getMPCControllers.getChildren;
%             for ct = 1:length(MPCNodes)
%                 MPCNode=MPCNodes(ct);
%                 Ldestroy(ct) = handle.listener(MPCNode, 'ObjectBeingDestroyed', {@mpc_guimask 'destroy_mmpc' ct});
%             end
%             % Move listener to ApplicationData, so it's always in scope
%             setappdata(f,'ExportController',Ldestroy);
        case 'open_by_cetm'
            % If this mask has been opened from the New Task menu - check that it
            % doesn't already exist
            if ~isempty(proj) && ~isempty(proj.find('-class','mpcnodes.MPCGUI','Block',blk))
                errordlg(ctrlMsgUtils.message('MPC:designtool:MPCTaskExisting',blk),...
                    ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
                return
            end
            feval(@SETCallBack, [], [], f, hTable, blkh, blksystem, proj);
    end
end


%-------------------------------------------------------------------
% CALLBACKS
%-------------------------------------------------------------------
function ADDCallBack(eventSrc, eventData, f, TextBoxObj, hTable, blkh, fields, defaults)
% current design: add to the end of the table
blk=[get(blkh,'Parent') '/' get_param(blkh,'Name')];
% update Nmpc
Nmpc = str2double(get_param(blkh,'Nmpc')) + 1;
set_param(blkh,'Nmpc',num2str(Nmpc));
set(TextBoxObj,'string',num2str(Nmpc));

% Add new default value in all fields of multiMPC mask related to
% underlying MPC mask

for i=1:length(fields)
    field=fields{i};
    default_value=['''' defaults{i} ''''];
    % update field
    aux = get_param(blkh,[field 's']);
    aux = strrep(aux,'}',[',' default_value '}']);
    set_param(blkh,[field 's'],aux);
end

% refresh table
populateTable(hTable,blkh);

%-------------------------------------------------------------------
function DELETECallBack(eventSrc, eventData, f, TextBoxObj, hTable, blkh, fields)
% check how many MPC are selected
Data = get(hTable,'Data');
for ct = 1:size(Data,1)
    checkedvalue(ct) = Data{ct,4};
end
deleted_block = find(checkedvalue);
% if no row is selected, remind user
if isempty(deleted_block)
    uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:NoMPCSelected'),...
        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'))
% if all the rows are selected, remind user
elseif length(deleted_block)==str2double(get_param(blkh,'Nmpc'))
    uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:UnableToDeleteMPC'),...
        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'))
else
    for ct = 1:length(deleted_block)
        % set block to be deleted 
        set_param(blkh,'theMPC',num2str(deleted_block(ct)));
        % update Nmpc
        Nmpc = str2double(get_param(blkh,'Nmpc')) - 1;
        % calling set_param will remove the MPC block
        set_param(blkh,'Nmpc',num2str(Nmpc));
        set(TextBoxObj,'string',num2str(Nmpc));
        % update multiMPC mask's fields
        for i=1:length(fields),
            field=[fields{i} 's'];
            aux = eval(get_param(blkh,field));
            aux(deleted_block(ct)) = [];
            str = '{''';
            for j=1:length(aux)-1
                str = [str aux{j} ''','''];
            end
            str = [str aux{end} '''}'];
            set_param(blkh,field,str);
        end
        % adjust remaining blocks indices 
        deleted_block = deleted_block - 1;
        % reset theMPC
        set_param(blkh,'theMPC','0');
    end        
    % refresh table
    populateTable(hTable,blkh);
end

%-------------------------------------------------------------------
function SETCallBack(eventSrc, eventData, f, hTable, blkh, blksystem, proj)

% check how many MPC are selected
Data = get(hTable,'Data');
for ct = 1:size(Data,1)
    checkedvalue(ct) = Data{ct,5};
end
mpcidx = find(checkedvalue);
% if no row is selected, skip
if isempty(mpcidx)
    errordlg(ctrlMsgUtils.message('MPC:designtool:NoMPCSelected'),...
        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal')
else
    for ct = 1:length(mpcidx)
        % get mpc object in the table
        mpcobj = Data{mpcidx(ct),2};
        % if no mpc object specified and it is the first one to design with,
        % ask for number of Mv
        if isempty(mpcobj) && mpcidx(ct)==1
            prompt= {ctrlMsgUtils.message('MPC:designtool:MVQuestionDialogMessage')};
            options.Resize = 'on';
            nmv = str2double(get_param(blkh,'nmv'));
            if nmv==0
                answer = inputdlg(prompt,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 1, {'1'}, options);
            else
                answer = inputdlg(prompt,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 1, {sprintf('%d',max(1,nmv))}, options);
            end
            if isempty(answer)
                return
            else
                try
                    nu = str2double(answer{1});
                catch ME
                    errordlg(ctrlMsgUtils.message('MPC:designtool:MVErrorDialogMessage'),...
                        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal')
                    return
                end
                if ~isscalar(nu) || nu<1
                    errordlg(ctrlMsgUtils.message('MPC:designtool:MVErrorDialogMessage'),...
                        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal')
                    return
                end
            end
            nu = sprintf('%d',nu);
            % set_param will update 'n_mv' field in all the inner mpc blocks
            set_param(blkh,'nmv',nu);
        end
        % call mpc_mask to design this block
        blkm = getfullname(blkh);
        blk=[blkm '/MPC' num2str(mpcidx(ct))];
        mpc_mask('open_by_mmpc', blksystem, proj, blk);
        % if design from scratch, set the new @mpc name in the table
        if isempty(mpcobj)
            % obtain hidden GUI handle
            oldsh = get(0,'ShowHiddenHandles');
            set(0,'ShowHiddenHandles','on');
            fig = findobj('Type','figure', 'Tag', 'MPC_mask');
            set(0,'ShowHiddenHandles',oldsh');
            hGUI = getappdata(fig(1),'hGUI');
            % obtain node name
            MPCNode = hGUI.getMPCControllers.getChildren;
            newmpcname = MPCNode(end).Label;
            % update mpcobjs
            currmpcobjs = eval(get_param(blkh,'mpcobjs'));
            currmpcobjs(mpcidx(ct)) = {newmpcname};
            str = '{''';
            for i=1:length(currmpcobjs)-1
                str = [str currmpcobjs{i} ''','''];
            end
            str = [str currmpcobjs{end} '''}'];    
            set_param(blkh,'mpcobjs',str);
            % refresh table
            populateTable(hTable,blkh);
        end
    end
end

function TableDataChangedCallBack(eventSrc, eventData, blkh)
row = eventData.Indices(1);
col = eventData.Indices(2);
switch col
    case 2
        strvalue = eventData.NewData;
        % initialize nmv if necessary
        if strcmp(get_param(blkh,'nmv'),'0')
            if evalin('base',sprintf('exist(''%s'', ''var'')',strvalue)) == 1
                mpcobj = evalin('base',strvalue);
                if isa(mpcobj,'mpc')
                    nmv = length(mpcobj.ManipulatedVariables);
                    set_param(blkh,'nmv',num2str(nmv));
                end
            end
        end
        % update mpcobjs
        currmpcobjs = eval(get_param(blkh,'mpcobjs'));
        currmpcobjs(row) = {strvalue};
        str = '{''';
        for ct=1:length(currmpcobjs)-1
            str = [str currmpcobjs{ct} ''','''];
        end
        str = [str currmpcobjs{end} '''}'];    
        set_param(blkh,'mpcobjs',str);
    case 3
        % update x0s
        currmpcx0s = eval(get_param(blkh,'x0s'));
        currmpcx0s(row) = {eventData.NewData};
        str = '{''';
        for ct=1:length(currmpcx0s)-1
            str = [str currmpcx0s{ct} ''','''];
        end
        str = [str currmpcx0s{end} '''}'];    
        set_param(blkh,'x0s',str);
end

%-------------------------------------------------------------------
function ApplyCallBack(eventSrc, eventData, blkh, hfig, chkMDInputPort,...
    chkMVInputPort,chkLIMSInputPort, fields, chkref_from_ws, editBoxRef, ...
    chkref_preview, chkMD_from_ws, editBoxMD, chkMD_preview, saved_mask, btnCancel)

md_inport_multiple=get(chkMDInputPort,'Value');
mv_inport_multiple=get(chkMVInputPort,'Value');
lims_inport_multiple=get(chkLIMSInputPort,'Value');

ref_from_ws = onoff(get(chkref_from_ws,'value'));
ref_signal_name = get(editBoxRef,'string');
ref_preview = onoff(get(chkref_preview,'value'));
md_from_ws = onoff(get(chkMD_from_ws,'value'));
md_signal_name = get(editBoxMD,'string');
md_preview = onoff(get(chkMD_preview,'value'));

% Collects MPC parameters from the blocks underneath and store them in
% multiMPC mask parameters as a cell array of strings

N=eval(get_param(blkh,'Nmpc'));
blk=[get(blkh,'Parent') '/' get_param(blkh,'Name')];

for j=1:length(fields),
    field=fields{j};
    eval(sprintf('%ss=''{'';',field)); % Initialize string to contain list of fields
    for i=1:N,
        MPCname=sprintf('MPC%d',i); % block to be renamed
        blki=[blk '/' MPCname];
        eval(sprintf('aux=get_param(blki,''%s'');',field));
        eval(sprintf('%ss=[%ss ''''''%s'''',''];',field,field,aux)); 
    end
    eval(sprintf('%ss(end)=''}'';',field,field)); 
end
    
% Fill in parameters in MPC blocks underlying the multi-MPC block
% related to ref and MD signals
% mpc_fillblocks_multiple(blkh,N);

% NOTE: SET_PARAM also invokes the Initializand commands defined
% in the mask editor, namely MPC_GET_PARAM_SIM, MPC_BLOCK_RESIZE_MULTIPLE
set_param(blkh,'md_inport_multiple',onoff(md_inport_multiple),...
    'mv_inport_multiple',onoff(mv_inport_multiple),...
    'lims_inport_multiple',onoff(lims_inport_multiple),...
    'mpcobjs',mpcobjs,'x0s',x0s,...
    'ref_from_ws_multiple',ref_from_ws,'ref_signal_name_multiple',ref_signal_name,'ref_preview_multiple',ref_preview,...
    'md_from_ws_multiple',md_from_ws,'md_signal_name_multiple',md_signal_name,'md_preview_multiple',md_preview);

% Must refresh structure 'saved_mask'
thefields=fieldnames(saved_mask);
for i=1:length(thefields),
    saved_mask.(thefields{i})=get_param(blkh,thefields{i});
end

set(btnCancel,'callback',{@CancelCallBack hfig blkh saved_mask});

%-------------------------------------------------------------------
function OKCallBack(eventSrc, eventData,f, enabled ,blkh, chkMDInputPort,chkMVInputPort,chkLIMSInputPort, fields,...
    chkref_from_ws, editBoxRef, chkref_preview, chkMD_from_ws, editBoxMD, chkMD_preview, saved_mask, btnCancel)

if strcmp(enabled,'on'),
    ApplyCallBack(eventSrc, eventData, blkh, f, chkMDInputPort,chkMVInputPort,chkLIMSInputPort, fields,...
        chkref_from_ws, editBoxRef, chkref_preview, chkMD_from_ws, editBoxMD, chkMD_preview, saved_mask, btnCancel);
end

CloseMask(f,blkh);

%-------------------------------------------------------------------
function CancelCallBack(eventSrc, eventData,f,blkh,saved_mask)

blk=[get(blkh,'Parent') '/' get_param(blkh,'Name')];
if ~strcmp(blk,'mpclib/Multiple MPC Controllers'),
    thefields=fieldnames(saved_mask);
    for i=1:length(thefields),
        set_param(blkh,thefields{i},saved_mask.(thefields{i}));
    end
end
% completely close the mask, not just make it invisible, so that next time the
% mask is opened again all items in the maske are restored to their original values.
close(f); 

%-------------------------------------------------------------------
function CloseMask(f,blkh)

fclosemask=1;

if fclosemask,
    set(f,'visible','off');
end

%-------------------------------------------------------------------
function MDInportCallBack(eventSrc, eventData, blkh)
newstatus=get(eventSrc,'value');
set_param(blkh,'md_inport_multiple',onoff(newstatus));


%-------------------------------------------------------------------
function MVInportCallBack(eventSrc, eventData, blkh)
newstatus=get(eventSrc,'value');
set_param(blkh,'mv_inport_multiple',onoff(newstatus));

%-------------------------------------------------------------------
function LIMSInportCallBack(eventSrc, eventData, blkh)
newstatus=get(eventSrc,'value');
set_param(blkh,'lims_inport_multiple',onoff(newstatus));

%-------------------------------------------------------------------
function str=onoff(value)
% Converts 1/0 to 'on'/'off', to avoid the following Matlab message:
% 'Specifying an enumerated value by its corresponding integer value is being phased out'
if value,
    str='on';
else
    str='off';
end

%-------------------------------------------------------------------
function populateTable(hTable,blkh)
% construct table data
Nmpc = str2double(get_param(blkh,'Nmpc'));
dataObj = cell(Nmpc,5);
mpcobjs = eval(get_param(blkh,'mpcobjs'));
x0s = eval(get_param(blkh,'x0s'));
for ct = 1:Nmpc
    dataObj{ct,1} = ['MPC #' num2str(ct)];
    dataObj{ct,2} = mpcobjs{ct};
    dataObj{ct,3} = x0s{ct};
    dataObj{ct,4} = false;
    dataObj{ct,5} = false;
end
% set table data
set(hTable,'Data',dataObj);

%-------------------------------------------------------------------
function ChkCallBack(eventSrc, eventData, uis, blkh)
% Change Enable property
newstatus=get(eventSrc,'value');
for i=1:length(uis),
    set(uis(i),'Enable',onoff(newstatus));
end
