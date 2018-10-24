function setNewDate(this)
%  SETNEWDATE Sets "Updated" property of an MPCnode object

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc. 
%  $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:45:25 $

this.Updated = datestr(now);
