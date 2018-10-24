function mpcdesign_callback(model, varargin)

% Callback for the 'openfcn' of the double click start button on 
% each MPC Simulink demo

% Copyright 1990-2007 The MathWorks, Inc.
% $Revision: 1.1.6.10 $  $Date: 2008/05/31 23:21:35 $

if strcmp(get_param(gcs, 'SimulationStatus'),'stopped')
    blk = [model '/MPC Controller'];
    switch model
        case 'mpclinearization'
            if mpcchecktoolboxinstalled('scd')
                mpc_mask('open_by_cetm',gcs,'',blk);
            else  
                model = ss(0,1,1,0);
                mpcobj = mpc(model,1);
                assignin('base','mpcobj',mpcobj);
                set_param(blk,'mpcobj','mpcobj');
                mpc_mask('load',gcs,'',blk,'MPC Task - MPC Controller');
            end
        case 'TMPdemo'
            load MPCtmpdemo;
            assignin('base','MPC1',MPC1);
            mpctmpinit;
            set_param(blk,'mpcobj','MPC1');
            mpc_mask('load',gcs,'',blk,'MPC Task - MPC Controller');
    end
end





