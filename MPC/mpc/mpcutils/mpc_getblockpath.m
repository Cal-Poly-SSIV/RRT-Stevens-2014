function fullblockname = mpc_getblockpath(model,type)
%MPC_GETBLOCKPATH Get the full block path/name of an MPC block given a
%model. If there is more than one MPC block this function prompts the user
%to select which one will be used

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.5 $  $Date: 2008/05/31 23:21:55 $

fullblockname = '';
mpcblocks = find_system(model,'MaskType',type);
if isempty(mpcblocks)
    errordlg(ctrlMsgUtils.message('MPC:designtool:NoMPCBlock'),...
        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
    return
elseif length(mpcblocks)==1
     fullblockname = mpcblocks{1};
else % Ask the user which block
     fullblockname = mpcdlg(mpcblocks);
end


function thisblock = mpcdlg(blocknames)

f = figure('MenuBar','none','NumberTitle','off','Units','Characters',...
            'Position',[103.8 50.69 59.2 9.76],'Resize','off',...
            'NumberTitle','off','Name',ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'));
blockpopup = uicontrol('style','popup','Units','Characters','Position',[25.2 5 30.2 2.30],...
    'String', blocknames,'Parent',f,'BackgroundColor',[1 1 1]);
blocklabel = uicontrol('style','text','Units','Characters','Position',[3.8 5.846 21.2 1.154],...
    'String', 'Select a MPC block:', 'Parent',f,'Backgroundcolor',get(f,'Color'));
okbtn = uicontrol('style','pushbutton','Units','Characters','String','OK','Position',...
    [25.2 2 13.2 1.769], 'Callback', {@localOK f},'Parent',f);
cancelbtn = uicontrol('style','pushbutton','Units','Characters','String','Cancel','Position',...
    [41.2 1.923 13.2 1.769], 'Callback', {@localCancel f},'Parent',f);

% Wait for response 
uiwait(f)

% Return selected blocks
button = get(f,'Userdata');
if strcmp(button,'OK')
    thisblock = blocknames{get(blockpopup,'Value')};
else
    thisblock = '';
end
close(f)

function localOK(es,ed,f)

set(f,'Userdata','OK')
uiresume(f)

function localCancel(es,ed,f)

set(f,'Userdata','Cancel')
uiresume(f)


