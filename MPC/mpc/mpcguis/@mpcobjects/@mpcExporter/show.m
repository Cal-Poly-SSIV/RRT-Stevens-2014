function show(this)
% SHOW Display the mpcExporter dialog

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:46:16 $

if isempty(this.Handles)
    % Dialog panel needs to be created
    this.createObjectExporter;
    this.Handles.Dialog.setLocation(java.awt.Point(20,20));
end
awtinvoke(this.Handles.Dialog,'setVisible',true);
