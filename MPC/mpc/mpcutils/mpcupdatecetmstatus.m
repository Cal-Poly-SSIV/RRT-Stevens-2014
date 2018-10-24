function mpcupdatecetmstatus(Root, Message)
%Check if Simulink is installed.

% Author(s): Rong Chen
% Copyright 1986-2007 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:47:25 $

if isa(Root, 'mpcnodes.MPCGUI')
    if isempty(Message) || ~ischar(Message)
        awtinvoke(Root.Frame,'clearStatus');
    else
        awtinvoke(Root.Frame,'postStatus(Ljava.lang.String;)',Message);
    end
end
