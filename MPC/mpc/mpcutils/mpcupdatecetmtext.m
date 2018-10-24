function mpcupdatecetmtext(Root, Message)
%Check if Simulink is installed.

% Author(s): Rong Chen
% Copyright 1986-2007 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:47:27 $

if isa(Root, 'mpcnodes.MPCGUI')
    if isempty(Message) || ~ischar(Message)
        awtinvoke(Root.Frame,'clearText');
    else
        awtinvoke(Root.Frame,'postText(Ljava.lang.String;)',Message);
    end
end
