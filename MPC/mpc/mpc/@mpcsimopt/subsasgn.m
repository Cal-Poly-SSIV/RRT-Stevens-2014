function mpcsimopt = subsasgn(mpcsimopt,Struct,rhs)
%SUBSREF  MPCSIMOPT property management in assignment operation
%
%   mpcsimopt.Field = Value sets the 'Field' property of the MPCSIMOPT object mpcsimopt 
%   to the value Value. Is equivalent to SET(mpcsimopt,'Field',Value)
%

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2007/11/09 20:40:53 $   

if nargin==1,
    return
end

StructLength = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form mpcsimopt.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructLength==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(mpcsimopt,FieldName),Struct(2:end),rhs);
            end
            set(mpcsimopt,FieldName,FieldValue)
        catch ME
            throw(ME);
        end
    otherwise
        ctrlMsgUtils.error('MPC:object:InvalidSubs');        
end