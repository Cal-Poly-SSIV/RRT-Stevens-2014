function newwt=mpc_chklen(wt,p)
%MPC_CHKLEN Check dimension of a matrix and possibly repeat the last row 
%   up to fill in the whole prediction horizon p, if weight is not
%   nondiagonal

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2008/04/28 03:24:02 $  

if isa(wt,'cell'),
    newwt=wt;
    return
end

[nrow, ncol] = size(wt); %#ok<NASGU>
if nrow<p 
    % If fewer rows than needed, must copy the last one
    %newamin=[amin;kron(ones(p-nrow,1),amin(nrow,:))];    
    newwt=[wt;ones(p-nrow,1)*wt(nrow,:)];    
else
    newwt=wt;
end

%end mpc_chklen
