function status = mpc_nmvquest(mpcblock) 
% MPC_NMVQUEST  Queries the user for the number of MVs
%
 
% Author(s): Rong Chen 28-Apr-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:19:26 $

status = true;
if ~isempty(mpcblock) && isempty(get_param(mpcblock,'mpcobj'))
    prompt= {ctrlMsgUtils.message('MPC:designtool:MVQuestionDialogMessage')};
    n_mv = str2double(get_param(mpcblock,'n_mv'));
    options.Resize = 'on';
    if isempty(n_mv)
        answer = inputdlg(prompt,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 1, {'1'}, options);
    else
        answer = inputdlg(prompt,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'), 1, {sprintf('%d',max(1,n_mv))}, options);
    end
    if isempty(answer)
        status = false;
        return
    else
        try
            nu = str2double(answer{1});
        catch ME
            errordlg(ctrlMsgUtils.message('MPC:designtool:MVErrorDialogMessage'),...
                ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal')
            status = false;            
            return
        end
        if ~isscalar(nu) || nu<1
            errordlg(ctrlMsgUtils.message('MPC:designtool:MVErrorDialogMessage'),...
                ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal')
            status = false;
            return
        end
    end
    set_param(mpcblock,'n_mv',sprintf('%d',nu));
end

