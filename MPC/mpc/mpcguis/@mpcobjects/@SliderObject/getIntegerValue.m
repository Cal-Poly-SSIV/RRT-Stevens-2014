function intVal = getIntegerValue(this)

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2007/11/09 20:45:41 $

javaSlider = this.Panel.Slider;
intMin = javaSlider.getMinimum;
intMax = javaSlider.getMaximum;

if this.isLog
    % Log scaling
    intVal = intMin + round((intMax - intMin)*(log(this.Value/this.Minimum)/ ...
        log(this.Maximum/this.Minimum)));
else
    intVal = intMin + round((intMax - intMin)*(this.Value - this.Minimum)/ ...
        (this.Maximum - this.Minimum));
end
