function openvar(name, obj)
%OPENVAR is a utility function

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/09 20:39:31 $   

if isa(obj, 'mpc')
    try
        mpctool(obj)
    catch ME
        throw(ME)
    end
end

