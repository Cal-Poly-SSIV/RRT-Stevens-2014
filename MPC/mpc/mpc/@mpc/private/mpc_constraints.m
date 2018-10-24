function varargout=mpc_constraints(Specs,p,n,deftype,off)
% MPC_CONSTRAINTS Given the array of structures Specs (already checked by MPC_SPECS), 
%    convert data to matrix format
%
%    ManipulatedVariables:  varargout=[umin,umax,Vumin,Vumax,dumin,dumax,utarget,Vdumin,Vdumax]
%    OutputVariables: varargout=[ymin,ymax,Vymin,Vymax]

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2007/11/09 20:40:25 $  

amin=zeros(p,n);
amax=zeros(p,n);
Vmin=zeros(p,n);
Vmax=zeros(p,n);
if deftype=='u', 
   dumin=zeros(p,n);
   dumax=zeros(p,n);
   Vdumin=zeros(p,n);
   Vdumax=zeros(p,n);
   utarget=zeros(p,n);
end

for i=1:n,
   amin(:,i)=augment(Specs(i).Min,p);
   amax(:,i)=augment(Specs(i).Max,p);
   Vmin(:,i)=augment(Specs(i).MinECR,p);
   Vmax(:,i)=augment(Specs(i).MaxECR,p);
   
   if deftype=='u', 
      dumin(:,i)=augment(Specs(i).RateMin,p);
      dumax(:,i)=augment(Specs(i).RateMax,p);
      Vdumin(:,i)=augment(Specs(i).RateMinECR,p);
      Vdumax(:,i)=augment(Specs(i).RateMaxECR,p);
      if ischar(Specs(i).Target), % Target='nominal'
          % Must inherit target from off=Model.Nominal.U(mvindex)
          utarget(:,i)=augment(off(i),p);
      else
          utarget(:,i)=augment(Specs(i).Target,p);
      end
   end
   
end

% ECRs corresponding to unconstrained vars are zeroed
Vmin(~isfinite(amin))=0;
Vmax(~isfinite(amax))=0;
if deftype=='u',
   Vdumin(~isfinite(dumin))=0;
   Vdumax(~isfinite(dumax))=0;
   utarget=utarget'-kron(ones(p,1),off(:)')';    % utarget must be p-by-nu
   utarget=utarget(:);  % put utarget in one column      
end   

% InputSpecs:  varargout=[umin,umax,Vumin,Vumax,dumin,dumax,utarget,Vdumin,Vdumax]
off=kron(ones(p,1),off(:)');

switch deftype
case 'u'
   varargout={amin-off,amax-off,Vmin,Vmax,dumin,dumax,Vdumin,Vdumax,utarget}; 
case 'y'   
   % OutputSpecs: varargout=[ymin,ymax,Vymin,Vymax]
   varargout={amin-off,amax-off,Vmin,Vmax}; 
end


function b=augment(a,p)

% Possibly augment to size=p by copying the last entry
a=a(:);
nrow=length(a);

%newamin=[amin;kron(ones(p-nrow,1),amin(nrow,:))];    
b=[a;ones(p-nrow,1)*a(nrow)];    

