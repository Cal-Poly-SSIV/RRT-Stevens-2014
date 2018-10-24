function boo = isempty(MPCobj)
%ISEMPTY  True for empty MPC objects.
% 
%   ISEMPTY(MPCOBJ) returns 1 (true) if the MPC object MPCOBJ is empty
%    

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.5 $  $Date: 2007/11/09 20:39:25 $   

boo = logical(MPCobj.MPCData.isempty);
