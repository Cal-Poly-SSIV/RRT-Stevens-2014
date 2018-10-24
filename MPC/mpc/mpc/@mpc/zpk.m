function sys=zpk(MPCobj)
%ZPK  Zero-pole-gain corresponding to linearized MPC object (no constraints)
%
%   See also SS, TF

%   Author(s): A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2007/11/09 20:40:06 $

if MPCobj.MPCData.isempty,
    sys=zpk;
else
    try
        sys=zpk(ss(MPCobj));
    catch ME
        throw(ME);
    end
end

