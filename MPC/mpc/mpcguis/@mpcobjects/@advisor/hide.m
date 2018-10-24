function hide(this)
% HIDE hide the tuning advisor dialog

%  Author:  Rong Chen
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:21:43 $

if ~isempty(this.Handles)
    % Dialog panel needs to be created
    awtinvoke(this.Handles.Dialog,'setVisible',false);
end
