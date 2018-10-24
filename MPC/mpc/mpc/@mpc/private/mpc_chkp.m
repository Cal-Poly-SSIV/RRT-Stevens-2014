function [newp,p_defaulted]=mpc_chkp(p,default,Model,Ts)
%MPC_CHKP Check correctness of prediction horizon p

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date:

verbose = mpccheckverbose;

if ~isa(p,'double'),
    ctrlMsgUtils.error('MPC:utility:InvalidPredictionHorizon');
end

if p~=round(p),
    p=round(p);
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:PredictionHorizonRounded',p));    
    end
end

p_defaulted=0;
if isempty(p),
    p_defaulted=1;
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:TryPredictionHorizon',default));
    end
    newp=default;
    return
elseif numel(p)~=1 || ~isfinite(p) || any(p<1),
    ctrlMsgUtils.error('MPC:utility:InvalidPredictionHorizon');
end

% Check if p>=maximum delay
maxdelay=max(max(totaldelay(Model.Plant)));
if maxdelay>0,
    if Model.Plant.Ts==0,
        % The following will be the delay when the model is sampled using
        % C2D
        pdelay=floor(maxdelay/Ts);
    else
        pdelay=maxdelay;
    end
    if p<=pdelay,
        if ~p_defaulted, % P was supplied by the user
            if verbose,
                fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:PredictionHorizonTooSmall',p,pdelay,p+pdelay));                
            end
        else
            p=p+pdelay;
            if verbose,
                fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:PredictionHorizonIncreased',p));                            
            end
        end
    end
end

newp=p;
% end mpc_chkp

