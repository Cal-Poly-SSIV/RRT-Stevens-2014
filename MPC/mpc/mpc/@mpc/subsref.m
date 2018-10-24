function result = subsref(MPCobj,Struct)
%SUBSREF  Subscripted reference for MPC objects.
%
%   The following reference operation can be applied to any
%   MPC controller MPCOBJ:
%      MPCOBJ.Fieldname  equivalent to GET(MPCOBJ,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%
%   See also GET.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2007/11/09 20:39:59 $

% Effect on MPC properties: all inherited
ni = nargin;
if ni==1,
    result = sys;
    return
end
StructLength = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
    case '.'
        % The first subreference is of the form sys.fieldname
        % The output is a piece of one of the system properties
        try
            if StructLength==1,
                result = get(MPCobj,Struct(1).subs);
            else
                for j=2:length(Struct),
                    if isa(Struct(j).subs,'char')
                        % Handle multiple names for 'Weight' structure
                        aux=lower(Struct(j).subs);
                        if strcmp(aux,'mv') || strcmp(aux,'input'),
                            Struct(j).subs='ManipulatedVariables';
                        elseif strcmp(aux,'ov') || strcmp(aux,'controlled'),
                            Struct(j).subs='OutputVariables';
                        elseif strcmp(aux,'mvrate') || strcmp(aux,'inputrate'),
                            Struct(j).subs='ManipulatedVariablesRate';
                        end
                    end
                end
                result = subsref(get(MPCobj,Struct(1).subs),Struct(2:end));
            end
        catch ME
            throw(ME);
        end
    otherwise
         ctrlMsgUtils.error('MPC:object:InvalidSubs',Struct(1).type);        
end
