function [Value,ValStr] = pvget(mpcsimopt,Property)
%PVGET  Get values of public MPCSIMOPT properties.
%
%   VALUES = PVGET(MPCSIMOPT) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(MPCSIMOPT,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   Author: A. Bemporad, P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/11/09 20:40:50 $

if nargin==2,
    % Value of single property: VALUE = PVGET(MPCSIMOPT,PROPERTY)
    % Public LTI properties
    Value = builtin('subsref',mpcsimopt,struct('type','.','subs',Property));

else
    % Return all public property values
    % RE: Private properties always come last in LTIPropValues
    LTIPropNames = pnames(mpcsimopt);
    LTIPropValues = struct2cell(mpcsimopt);
    Value = LTIPropValues(1:length(LTIPropNames));
    if nargout==2,
        ValStr = pvformat(Value);
    end

end