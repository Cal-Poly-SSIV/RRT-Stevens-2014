function MPCobj = subsasgn(MPCobj,Struct,rhs)
%SUBSREF  MPC property management in assignment operation
%
%   MPCOBJ.Field = Value sets the 'Field' property of the MPC object MPCOBJ
%   to the value Value. Is equivalent to SET(MPCOBJ,'Field',Value)
%

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2007/11/09 20:39:57 $

if nargin==1,
    return
end

StructLength = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form MPCobj.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructLength==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(MPCobj,FieldName),Struct(2:end),rhs);
            end
            set(MPCobj,FieldName,FieldValue);
        catch ME
            throw(ME);
        end
    otherwise
         ctrlMsgUtils.error('MPC:object:InvalidSubs');        
end

% Note: possible fields having wrong case are appended anyways below.
% For the structure Model, duplicates are correctly handled by
% MPC_PRECHKMODEL, in particular the last appended field dominates over
% duplicates.