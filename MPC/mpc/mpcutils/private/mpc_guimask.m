function mpc_guimask(eventSrc, eventData, action, param1, param2)
% MPC_GUIMASK Manages GUI/Mask interaction through listeners

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/05/31 23:22:06 $

switch action

    case 'update'
        try
            mpcobjlist = eventData.NewValue;
            % Here param1=popBoxObj
            set(param1,'String',mpcobjlist);
        catch ME            
        end

    case 'destroy'
        % Listener when MPC object from the editBox is edited in the GUI
        try
            % get mpc object name from GUI
            mpc2=eventSrc.getController;

            % get mpc object name from workspace
            mpcname = get_param(eventSrc.getRoot.Block,'mpcobj');
            if ~isempty(mpcname)
                yesno = questdlg(ctrlMsgUtils.message('MPC:designtool:InfoGUIDestroy', eventSrc.getRoot.Block, mpcname), ...
                    ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'Yes', 'No', 'Yes');
                if strcmp(yesno,'Yes'),
                    assignin('base', mpcname, mpc2);
                end
            end
        catch ME
        end
        
    case 'lin_destroy'
        % Listener when MPC object created from linearization and stored in
        % the editBox is edited in the GUI
        try
            % get mpc object name from GUI
            mpc2=eventSrc.getController;

            % get mpc object name from workspace
            mpcname = get_param(eventSrc.getRoot.Block,'mpcobj');
            
            yesno = questdlg(ctrlMsgUtils.message('MPC:designtool:InfoGUIDestroy', eventSrc.getRoot.Block, mpcname), ...
                ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'Yes', 'No', 'Yes');
            if strcmp(yesno,'Yes'),
                assignin('base', mpcname, mpc2);
            else
                % Return to previous state
                set(param1,'String','');
            end
        catch ME
        end
        
end
