function h = mpcExporter
% MPCEXPORTER object constructor

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2008/10/31 06:21:50 $

h = mpcobjects.mpcExporter;
h.Handles = [];

% persistent hMPCExporter
% if isempty(hMPCExporter)
%    % Create and target prop editor if it does not yet exist
%    hMPCExporter = mpcobjects.mpcExporter;
%    hMPCExporter.Handles = [];
% end
% h = hMPCExporter;