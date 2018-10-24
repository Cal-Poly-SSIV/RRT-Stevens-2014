function [dumin2,PTYPE]=mpc_chkunconstr(umin,umax,dumin,dumax,ymin,ymax,...
   Vumin,Vumax,Vdumin,Vdumax,Vymin,Vymax)
%MPC_CHKUNCONSTR Check if the problem has any bounded constraint on u,du,y.
%   If it has, default lim for du is deltaumin (defined in MPC_DEFAULTS), otherwise Inf

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2007/11/09 20:40:22 $ 


default=mpc_defaults;
verbose = mpccheckverbose;

constrained=any(isfinite(umin(:))) | any(isfinite(umax(:))) | ...
    any(isfinite(dumin(:))) | any(isfinite(dumax(:))) | ...
    any(isfinite(ymin(:))) | any(isfinite(ymax(:)));

if constrained,
    big=default.deltaumin;
else
    big=Inf;
end


if constrained,
   
   % When using the DANTZGMP routine for the QP problem, we must have all
   % lower bounds on delta u finite.  
   
   ifound=find(isinf(dumin));
   if ~isempty(ifound)
       if verbose,
           msg1 = ctrlMsgUtils.message('MPC:computation:InputRateMinNotSpecified1');            
           msg2 = ctrlMsgUtils.message('MPC:computation:InputRateMinNotSpecified2',default.deltaumin);            
           fprintf('-->%s\n   %s\n',msg1,msg2);
       end
   end
   dumin(ifound)=default.deltaumin;
      
   % A bound that is finite but large can cause numerical problems. The following loop checks for this.
   
   ifound=find(dumin<default.bigdeltaumin);  % (NaN<bigdeltaumin is 0)
   if ~isempty(ifound),
       if verbose,
           msg1 = ctrlMsgUtils.message('MPC:computation:InputRateMinTooSmall1',default.bigdeltaumin,default.bigdeltaumin);            
           msg2 = ctrlMsgUtils.message('MPC:computation:InputRateMinTooSmall2');            
           fprintf('-->%s\n   %s\n',msg1,msg2);
       end
   end
   dumin(ifound)=default.bigdeltaumin;
   
   % Upper bounds on Delta u can be arbitrary large
   
     
   % Now check if there are soft constraints. ECRs corresponding to unbounded constraints
   % were zeroed in MPC_INPUTSPECS and MPC_OUTPUTSPECS
   
   if any(Vymin(:)>0) || any(Vymax(:)>0) || any(Vumin(:)>0) || any(Vumax(:)>0) || any(Vdumin(:)>0) || any(Vdumax(:)>0),
      %TYPE='Soft_Constrained';   % Constrained MPC problem + soft constraints
      % --> need QP w/ slack variable
      PTYPE=0;
   else
      %TYPE='Constrained';   % Constrained MPC problem, no soft constraints 
      % --> need QP, hard input/delta-input constraints
      PTYPE=1;
   end
else
   %TYPE='Unconstrained'; % Unconstrained MPC problem --> no need of QP
   PTYPE=2;
end


%% Convert default lower bounds on input rates from NaN to -big
%ifound=find(isnan(dumin));
%dumin(ifound)=-big;

dumin2=dumin;

%end mpc_chkunconstr