function pack(MPCobj)
%PACK Clean up information build at initialization from object

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/11/09 20:39:33 $   

MPCobj = mpc_updatempcdata(MPCobj,[],0,0,0);        
% Assign MPCobj in caller's workspace
if ~isempty(inputname(1))
    assignin('caller',inputname(1),MPCobj);
end
