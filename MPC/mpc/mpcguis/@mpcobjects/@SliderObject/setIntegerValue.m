function setIntegerValue(this, javaInteger)

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2007/11/09 20:45:47 $

javaSlider = this.Panel.Slider;
intMin = javaSlider.getMinimum;
intMax = javaSlider.getMaximum;

this.enableListener = false;
if this.isLog
    % Log scaling
    logVal = log(this.Minimum) + log(this.Maximum/this.Minimum) * ...
        (double(javaInteger) - intMin)/(intMax - intMin);
    this.Value = exp(logVal);
else
    this.Value = this.Minimum + (this.Maximum - this.Minimum) * ...
        (double(javaInteger) - intMin)/(intMax - intMin);
end
this.enableListener = true;

intValue = this.getIntegerValue;
textValue = this.getStringValue;
awtinvoke(this.Panel,'UDDupdateSlider(ILjava.lang.String;)', intValue, textValue);
