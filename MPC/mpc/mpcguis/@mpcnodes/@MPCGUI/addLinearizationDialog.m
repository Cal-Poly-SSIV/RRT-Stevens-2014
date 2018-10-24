function addLinearizationDialog(h,M)
% Create linearization dialog for current Simulink model
% TO DO: Disable this if the parent node is not a Simulink 
% project node

% Author: A. Bemporad
% Copyright 1990-2007 The MathWorks, Inc.
% $Revision: 1.1.6.14 $  $Date: 2008/12/04 22:43:59 $

import com.mathworks.toolbox.mpc.*;
import java.awt.*;

%% Cannot add without slcontrol
if ~mpcchecktoolboxinstalled('scd')
    return
end
    
%% Create IOPanel object
h.Linearization = mpcnodes.MPCLinearizationSettings(h.up.OperatingConditions);

%% Create a linearization import panel and add it to the LTI importer
h.Linearization.LinearizationDialog = MPCLinearizationPanel();
javaimporter = h.Handles.('ImportLTI');
javaimporter.javasend('Hide','OK');
javaimporter.javahandle.addLinearizationPanel(h.Linearization.LinearizationDialog);
javaimporter.javahandle.pack;

%% If an operating condition task exists, excerise the listener to its
%% children to update the linearization dialog combo. Needed for load.
opcondtask = h.up.find('-class','OperatingConditions.OperatingConditionTask');
if ~isempty(opcondtask)
    h.opCondAdded(opcondtask);
end

%% Set callbacks
set(handle(javaimporter.javahandle.jOKButton,'callbackproperties'),...
    'ActionPerformedCallback', {@localLinearize javaimporter M});
set(handle(javaimporter.javahandle.jCancelButton,'callbackproperties'),...
    'ActionPerformedCallback', {@localClose javaimporter.javahandle});

%% Callbacks --------------------------------------------------------------
function localLinearize(es,ed,javaimporter,M)

%% temporarily disable button
awtinvoke(javaimporter.javahandle.jOKButton,'setEnabled(Z)',false);
awtinvoke(javaimporter.javahandle.jCancelButton,'setEnabled(Z)',false);
awtinvoke(javaimporter.javahandle.jHelpButton,'setEnabled(Z)',false);

%% Find the right MPCGUI node and get the corresponding opcondtask
Isel = javaimporter.javahandle.jProjectCombo.getSelectedIndex + 1;
mpcnode = javaimporter.Tasks(Isel);
jframe = javaimporter.javahandle;
opcondtask = mpcnode.up.find('-class','OperatingConditions.OperatingConditionTask');

%% Only linearize if the linearization tab is active
if ~isempty(jframe.mainTabPane) && jframe.mainTabPane.getSelectedIndex==1
    if ~mpcnode.linearization.LinearizationDialog.nominalRadio.isSelected
        % Constraint node selected from drop down list
        opcondnodestr = char(...
            mpcnode.linearization.LinearizationDialog.existingOpsCombo.getSelectedItem);
        opconnodes = opcondtask.getChildren;
        I = find(strcmp(opcondnodestr,get(opconnodes,{'Label'})));
        newNodeName = mpcnode.linearize(opcondtask, M, opconnodes(I(1)));
    else % Use the mpc i/o table
        if strcmp(get_param(mpcnode.Block,'MaskType'),'MPC')            
            mpcobjname = get_param(mpcnode.Block,'mpcobj');
            if evalin('base',sprintf('exist(''%s'', ''var'')',mpcobjname)) ~= 1
                NameErrMsg = ctrlMsgUtils.message('MPC:designtool:ExportControllerRequired',mpcobjname);
                uiwait(errordlg(NameErrMsg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
                awtinvoke(javaimporter.javahandle.jOKButton,'setEnabled(Z)',true);
                awtinvoke(javaimporter.javahandle.jCancelButton,'setEnabled(Z)',true);
                awtinvoke(javaimporter.javahandle.jHelpButton,'setEnabled(Z)',true);
                return
            end
            newNodeName = mpcnode.linearize(opcondtask,M,[]);
        else
            NumObj = str2double(get_param(mpcnode.Block,'NMPC'));
            for ct = 1:NumObj
                mpcobjname = get_param([mpcnode.Block '/MPC' num2str(ct)],'mpcobj');
                if evalin('base',sprintf('exist(''%s'', ''var'')',mpcobjname)) ~= 1
                    NameErrMsg = ctrlMsgUtils.message('MPC:designtool:ExportControllerRequired',mpcobjname);
                    uiwait(errordlg(NameErrMsg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
                    awtinvoke(javaimporter.javahandle.jOKButton,'setEnabled(Z)',true);
                    awtinvoke(javaimporter.javahandle.jCancelButton,'setEnabled(Z)',true);
                    awtinvoke(javaimporter.javahandle.jHelpButton,'setEnabled(Z)',true);
                    return
                end
            end
            % make sure switch is set to 1 before linearization occurs
            set_param(mpcnode.Block, 'linswitch', '1')
            newNodeName = mpcnode.linearize(opcondtask,M,[]);
            set_param(mpcnode.Block, 'linswitch', '0')
            % make sure switch is set to 0 after linearization finishes
        end
    end
    
%% Overwrite new nominals back to the table. Must be done after the new
%% linearized model has been added to guarantee that the MPC i/o table is
%% synchronized with the linearization i/o and only if the linearization 
%% was sucessful
    if ~isempty(newNodeName) && ...
            mpcnode.linearization.LinearizationDialog.overwriteNominalChk.isSelected
       mpcnode.setNominal(mpcnode.Linearization.OPReport)
    end
end

%% reenable button
awtinvoke(javaimporter.javahandle.jOKButton,'setEnabled(Z)',true);
awtinvoke(javaimporter.javahandle.jCancelButton,'setEnabled(Z)',true);
awtinvoke(javaimporter.javahandle.jHelpButton,'setEnabled(Z)',true);

%-------------------------------------------------------------------------
function localClose(es,ed,h)

%% Cancel button callback
awtinvoke(h,'hide');

    
