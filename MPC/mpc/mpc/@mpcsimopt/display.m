function display(mpcsimopt)
%DISPLAY Display an MPCSIMOPT object

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2008/07/14 17:09:54 $   

fprintf('\n%s is an MPCSIMOPT object with fields\n',inputname(1));
disp(struct(mpcsimopt))
