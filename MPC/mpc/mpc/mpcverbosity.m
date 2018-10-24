function mpcverbosity(value)
%MPCVERBOSITY Change the level of verbosity of MPC Toolbox
%
%   MPCVERBOSITY ON enables messages displaying default operations taken by
%   MPC Toolbox during the creation and manipulation of MPC objects.
%
%   MPCVERBOSITY OFF turns messages off (default)
%
%   MPCVERBOSITY just shows the verbosity status

%   Author: A. Bemporad
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2009/07/18 15:52:56 $

persistent mpcverbosity_init

if isempty(mpcverbosity_init)
    % get default values
    default=mpc_defaults;
    % set default verbosity
    warning(default.verbosity,'mpc:verbosity');
    % set init
    mpcverbosity_init = 'done';
end

if nargin==0 || isempty(value)
    % query
    verbose=warning('query','mpc:verbosity');
    fprintf('MPC verbosity level is %s\n',verbose.state);
else
    % set
    if ~ischar(value) || ~ (strcmpi(value,'on') || strcmpi(value,'off'))
        ctrlMsgUtils.error('MPC:object:InvalidVerbosity','mpcverbosity');            
    end
    warning(lower(value),'mpc:verbosity');
end



