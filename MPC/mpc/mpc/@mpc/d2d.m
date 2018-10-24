function mpcnew = d2d(mpcobj,ts)
%D2D  Change MPC controller sampling time.
%
%   MPCOBJ = D2D(MPCOBJ,TS) resamples the MPC models to produce an equivalent 
%   MPC object with sampling time TS.
%
%   See also MPC.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2007/11/09 20:39:11 $   


if nargin<2 || ~isnumeric(ts)
    ctrlMsgUtils.error('MPC:object:Invalid2ndSampleTime','d2d');
end

mpcnew = mpcobj;

if isempty(mpcobj),
    return
end

try
    set(mpcnew,'ts',ts);
catch ME
    throw(ME);
end
