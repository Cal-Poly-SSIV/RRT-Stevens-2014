function javasend(h,eventname,eventData)

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:46:23 $

% (hack) fire event with an eventData object set to the java String eventData
eventDatain = ctrluis.dataevent(h,eventname,eventData);
h.send(eventname,eventDatain);
