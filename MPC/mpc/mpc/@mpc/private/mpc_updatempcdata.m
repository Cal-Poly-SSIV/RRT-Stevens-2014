function MPCobj = mpc_updatempcdata(MPCobj,MPCstruct,InitValue,QPReady,LReady) 
% MPC_UPDATEWORKSPACE
%
 
% Author(s): Rong Chen 19-Sep-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:40:32 $

MPCData = MPCobj.MPCData;
MPCData.MPCstruct = MPCstruct;
MPCData.Init = InitValue;
MPCData.QP_ready = QPReady;
MPCData.L_ready = LReady;
MPCobj.MPCData = MPCData;

