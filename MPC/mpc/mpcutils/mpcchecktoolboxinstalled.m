function boo = mpcchecktoolboxinstalled(Toolbox)
%Check if Simulink is installed.

% Author(s): Rong Chen
% Copyright 1986-2007 The MathWorks, Inc. 
% $Revision: 1.1.8.2 $ $Date: 2009/06/11 16:02:05 $

switch lower(Toolbox)
    case 'simulink'
        boo = license('test', 'Simulink') && ~isempty(ver('simulink'));
    case 'scd'        
        boo = license('test', 'Simulink_Control_Design') && ~isempty(ver('slcontrol'));
    case 'optim'        
        boo = license('test','Optimization_Toolbox') && ~isempty(ver('optim'));
    case 'opc'
        boo = license('test','OPC_Toolbox') && ~isempty(ver('opc'));
    case 'rtw'
        boo = license('test','real-time_workshop') && ~isempty(ver('rtw'));
    otherwise
        boo = false;
end
