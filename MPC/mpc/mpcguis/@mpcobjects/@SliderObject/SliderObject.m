function this = SliderObject(Value,Min,Max,isLog)
% Constructor for Slider java/UDD object

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2007/11/09 20:45:40 $

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.mpc.*;

this = mpcobjects.SliderObject;
this.Panel = com.mathworks.toolbox.mpc.MPCSlider(this);
set(this,'Minimum',Min,'Maximum',Max,'isLog',isLog);
this.Slider = this.Panel.Slider;
this.TextField = this.Panel.TextField;
this.isEnabled = 1;
this.Listener = handle.listener(this, this.findprop('Value'), ...
    'PropertyPostSet', {@LocalValueListener, this});
this.enableListener = true;
this.Value = Value;

    
function LocalValueListener(eventSrc, eventData, this)

if this.enableListener
    intValue = this.getIntegerValue;
    textValue = this.getStringValue;
    awtinvoke(this.Panel,'UDDupdateSlider(ILjava.lang.String;)', intValue, textValue);
end