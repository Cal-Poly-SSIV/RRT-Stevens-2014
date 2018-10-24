function h = newMPCproject(ProjectName)
% NEWMPCPROJECT
%
% Utility function to create a new MPC project node, add it to
% the MPC gui workspace, and return the node's handle.
%
% ProjectName  is an optional project name (string).  If not assigned,
%              a default name is created.

%	Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.9 $  $Date: 2008/12/04 22:43:56 $

% Workspace and tree manager handles.  Should have been created previously.
[hJava,MPC_WSh,MPC_MANh] = slctrlexplorer('initialize');

%% Get MPC projects
WorkspaceProjects = [];
SimulinkProjects = [];
Projects = MPC_WSh.find('-class','mpcnodes.MPCGUI');
for k=1:length(Projects)
    if ~isempty(Projects(k).up) && MPC_WSh==Projects(k).up
        WorkspaceProjects = [WorkspaceProjects; Projects(k)];
    elseif isa(Projects(k).up,'explorer.projectnode')
        SimulinkProjects = [SimulinkProjects; Projects(k)];
    end
end
        
if nargin < 1 || isempty(deblank(ProjectName))
    % Create a uniqe project name
    ProjectName = 'MPCdesign';
    % If project with default name exists and hasn't been used yet, return
    % its handle.
    if ~isempty(WorkspaceProjects)
        h = WorkspaceProjects.find('Label', ProjectName);
        if ~isempty(h) && ~h.ModelImported
            mpcupdatecetmtext(h, ctrlMsgUtils.message('MPC:designtool:OverwriteProject', ProjectName, ProjectName));
            return
        end
    end
    if ~isempty(WorkspaceProjects)
        i=0;
        while  ~isempty(WorkspaceProjects.find('Label', ProjectName))
            i = i + 1;
            ProjectName = sprintf('MPCdesign%i', i);
        end
    end
else
    % If specified project name is in use, ask if it should be replaced
    if ~isempty(WorkspaceProjects)
        h = WorkspaceProjects.find('Label', ProjectName);
        if ~isempty(h)
            if h.ModelImported
                Msg = ctrlMsgUtils.message('MPC:designtool:OverwriteProjectQuestion', ProjectName);        
                Button = questdlg(Msg, ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 'Yes', 'No', 'No');
                if strcmpi(Button, 'No')
                    mpcupdatecetmtext(h, ctrlMsgUtils.message('MPC:designtool:CreateNewProjectCancel'));
                    h = [];
                    return
                else
                    mpcupdatecetmtext(h, ctrlMsgUtils.message('MPC:designtool:DeletingProject',ProjectName));
                    MPC_WSh.removeNode(h);
                end
            else
                % Project name refers to an existing empty project.
                % Return this project's handle
                mpcupdatecetmtext(h, ctrlMsgUtils.message('MPC:designtool:OverwriteProject', ProjectName, ProjectName));
                return
            end
        end
    end
end
Frame = MPC_MANh.Explorer;
mpcCursor(Frame, 'wait');
% Create the GUI project node
h = mpcnodes.MPCGUI(ProjectName);
% Add this project to the workspace and select it
h.Frame = Frame;
h.getDialogInterface(MPC_MANh);
MPC_WSh.addNode(h); 
mpcupdatecetmtext(h, ctrlMsgUtils.message('MPC:designtool:CreatedProject', h.Label));

% (jgo) The following line has been commented out because the combination
% of node selection and collapsing creates a race condition in the
% explorer. So far a solution to this has not been found.
%MPC_MANh.Explorer.setSelected(h.getTreeNodeInterface);
MPC_MANh.Explorer.collapseNode(h.TreeNode);
mpcCursor(Frame, 'default');

