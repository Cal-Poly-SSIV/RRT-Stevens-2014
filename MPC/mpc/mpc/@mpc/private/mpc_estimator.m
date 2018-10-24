function M=mpc_estimator(mpcobj,model,Bmn,Dmn,S13,S2,mvindex,mdindex,myindex,nnUMDtot)
%MPC_ESTIMATOR Design default Kalman filter

%   Author: A. Bemporad
%   Copyright 2001-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/19 23:18:47 $


%NOTE: what is called M here is also called M in KALMAN's help file

%Bmn=MNmodel.b and Dmn=MNmodel.d are needed to rescale covariance matrices

Q=blkdiag(S13,Bmn*S2*Bmn');
R=Dmn*S2*Dmn';
N=[zeros(nnUMDtot+length(mvindex)+length(mdindex),length(myindex));Bmn*S2*Dmn'];

% Model is already in the A,[B G],C,[D H] format.
try
    [dummy1,dummy2,dummy3,M]=kalman(model,Q,R,N,myindex,[mvindex;mdindex]);
catch ME
    % customize kalman filter errors
    errmsg = '';
    if isa(mpcobj.Model.Plant,'ss') && ~mpc_chkdetectability(mpcobj.Model.Plant.A,mpcobj.Model.Plant.C(myindex,:),mpcobj.Model.Plant.Ts),
        errmsg = sprintf('%s\n%s\n%s\n',errmsg,ctrlMsgUtils.message('MPC:utility:Kalman2'),ctrlMsgUtils.message('MPC:utility:Kalman3'));
    else
        % Check if overall model is not detectable
        if ~mpc_chkdetectability(model.A,model.C(myindex,:),1),
            errmsg = sprintf('%s\n%s\n                   %s\n                   %s\n                   %s\n',...
                errmsg,ctrlMsgUtils.message('MPC:utility:Kalman4'),ctrlMsgUtils.message('MPC:utility:Kalman5'),...
                ctrlMsgUtils.message('MPC:utility:Kalman6'),ctrlMsgUtils.message('MPC:utility:Kalman7'));
            if mpcobj.MPCData.OutDistFlag,
                errmsg = sprintf('%s\n                   %s\n',errmsg,ctrlMsgUtils.message('MPC:utility:Kalman8'));
            end
        end
    end
    nx=size(model.A,1);
    if rank([eye(nx)-model.A;model.C(myindex,:)])<nx,
        errmsg = sprintf('%s\n%s\n',errmsg,ctrlMsgUtils.message('MPC:utility:Kalman9'));
    end
    % throw error as mpc error
    ctrlMsgUtils.error('MPC:utility:Kalman1',errmsg);
end
