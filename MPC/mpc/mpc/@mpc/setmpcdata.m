function setmpcdata(MPCobj,MPCData)
%SETMPCDATA  Set private MPCDATA structure.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2007/11/09 20:39:46 $   

MPCobj.MPCData=MPCData;
% Assign MPCobj in caller's workspace
if ~isempty(inputname(1))
    assignin('caller',inputname(1),MPCobj);
end
