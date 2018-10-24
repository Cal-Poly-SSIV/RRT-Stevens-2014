function setStringValue(this, javaStringIn)

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2007/11/09 20:45:49 $

this.enableListener = false;
numVal = str2double(javaStringIn);
if isempty(numVal) || ~isscalar(numVal) || isnan(numVal)
    % User entry wasn't a valid number.  Ignore it -- return
    % current value instead.
    textValue = this.getStringValue;
elseif numVal(1) < this.Minimum
    % Saturate at minimum
    this.Value = this.Minimum;
    textValue = num2str(this.Minimum);
elseif numVal(1) > this.Maximum
    % Saturate at maximum
    this.Value = this.Maximum;
    textValue = num2str(this.Maximum);
else
    this.Value = numVal(1);
    textValue = num2str(this.Value);
end

intValue = this.getIntegerValue;
awtinvoke(this.Panel,'UDDupdateSlider(ILjava.lang.String;)',intValue, textValue);
this.enableListener = true;