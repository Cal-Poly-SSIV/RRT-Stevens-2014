function hide(this)
% HIDE Hide the mpcExporter dialog

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:46:10 $

if ~isempty(this.Handles)
    % Dialog panel needs to be created
    awtinvoke(this.Handles.Dialog,'setVisible',false);
end
