function Groups = mpc_getgroup(Groups)
%MPC_GETGROUP  Retrieves group info.

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2007/11/09 20:47:01 $

% Formats group info as a structure whose fields are the group names
if isa(Groups,'cell')
   % Read pre-R14 cell-based format {Channels Name}
   Groups = Groups(:,[2 1]).';
   Groups = struct(Groups{:});
end
