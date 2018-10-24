function Out = set(mpcsimopt,varargin)
%SET  Set properties of mpcsimopt objects.
%
%   SET(mpcsimopt,'PropertyName',VALUE) sets the property 'PropertyName'
%   of mpcsimopt to the value VALUE.  An equivalent syntax
%   is
%       mpcsimopt.PropertyName = VALUE .
%
%   SET(mpcsimopt,'Property1',Value1,'Property2',Value2,...) sets multiple
%   property values with a single statement.
%
%   SET(mpcsimopt,'Property') displays legitimate values for the specified
%   property of mpcsimopt.
%
%   SET(mpcsimopt) displays all properties of mpcsimopt and their admissible
%   values.
%
%   See also GET.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2008/05/19 23:18:49 $

ni = nargin;
no = nargout;

% Check i/o argument
if no && ni>2,
    ctrlMsgUtils.error('MPC:object:SetInvalidOutputSize');
end

% Get properties and their admissible values when needed
if ni<=2,
    [AllProps,AsgnValues] = pnames(mpcsimopt);
else
    AllProps = pnames(mpcsimopt);
end

% SET(mpcsimopt) or S = SET(mpcsimopt)
if ni==1,
    if no,
        Out = cell2struct(AsgnValues,AllProps,1);
    else
        disp(pvformat(AllProps,AsgnValues));
    end
    return
% SET(mpcsimopt,'Property') or STR = SET(mpcsimopt,'Property')
elseif ni==2,
    Property = varargin{1};
    if ~ischar(Property),
        ctrlMsgUtils.error('MPC:object:SetInvalidPropertyName');
    end
    % Return admissible property value(s)
    imatch = strmatch(lower(Property),lower(AllProps));
    PropMatchCheck(length(imatch),Property);
    if no,
        Out = AsgnValues{imatch};
    else
        disp(AsgnValues{imatch})
    end
    return

end

% Now left with SET(mpcsimopt,'Prop1',Value1, ...)
if rem(ni-1,2)~=0,
    ctrlMsgUtils.error('MPC:object:SetInvalidPair');
end

for i=1:2:ni-1,
    % Set each PV pair in turn
    PropStr = varargin{i};
    if ~ischar(PropStr),
        ctrlMsgUtils.error('MPC:object:SetInvalidPropertyName');
    end

    propstr=lower(PropStr);

    imatch = strmatch(propstr,lower(AllProps));
    PropMatchCheck(length(imatch),PropStr);
    Property = AllProps{imatch};
    Value = varargin{i+1};

    % Just sets what was required, will check later on when all
    % properties have been set

    %eval(['mpcsimopt.' Property '=Value;']);
    mpcsimopt.(Property)=Value;
end

% Finally, assign mpcsimopt in caller's workspace
if ~isempty(inputname(1))
    assignin('caller',inputname(1),mpcsimopt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction PropMatchCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PropMatchCheck(nhits,Property)
% Issues a standardized error message when the property name
% PROPERTY is not uniquely matched.
if nhits==1,
    err = '';
elseif nhits==0
    ctrlMsgUtils.error('MPC:object:SetNoPropertyName',Property);    
else
    ctrlMsgUtils.error('MPC:object:SetAmbiguousPropertyName',Property);
end