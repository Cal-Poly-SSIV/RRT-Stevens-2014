function setInitial(this)
%SETINITIAL Initializes common properties of an MPCnode object

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:43:46 $

this.Created = datestr(now);
this.Updated = this.Created;
A = ver('mpc');

if ~isempty(A)
    this.Version = A.Version;
end