function newmodel = mpc_chkoutdistmodel(model,ny,ts,type)
%MPC_CHKOUTDISTMODEL Check output or input disturbance model 
%   and convert it to discrete-time, state-space, delay-free form

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date:   

verbose = mpccheckverbose;

if isa(model,'double'),
    % Static gain, convert to LTI
    model=tf(model);
end

if isa(model,'idmodel'),
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertIDToSS'));
    end
    % Convert model to SS:
    model=mpc_id2ss(model);
end

if ~isa(model,'lti'),
    ctrlMsgUtils.error('MPC:utility:InvalidDistModel',type,ny);        
end

outnum=size(model,1);
if outnum~=ny,
    ctrlMsgUtils.error('MPC:utility:InvalidDistModel',type,ny);        
end

% convert to ss form
if ~isa(model,'ss'),
    model=ss(model);
    if ~isempty(model),
        % Use DARE to test detectability
        if ~mpc_chkdetectability(model.A,model.C,model.ts), % System is not detectable
            model=minreal(model);
        end
    end
end

nts=model.Ts;
if nts==0,
    % Note: UserData field is lost during conversion !!!
    model=c2d(model,ts);  
elseif abs(ts-nts)>1e-10, 
    % ts is different from nts
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ResampleUMDModel',type,ts));
    end
    try
        model=d2d(model,ts);
    catch ME
        ctrlMsgUtils.error('MPC:utility:InvalidDistModelD2D',ME.message);        
    end
    %takes out possible imaginary parts
    set(model,'a',real(model.a),'b',real(model.b));
end

if hasdelay(model),
    if verbose,        
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:ConvertDelayToSS',type));
    end
    model=delay2z(model);
end   

newmodel=model;
% end of mpc_chkoutdistmodel
