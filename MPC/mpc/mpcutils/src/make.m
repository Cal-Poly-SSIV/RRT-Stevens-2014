function make(file,verbose)
%MAKE Creates Mex files for MPC Toolbox
%
%   MAKE                builds all DLL's (MPCSFUN, QPSOLVER, MPCLOOP_ENGINE)
%   MAKE file           only build DLL 'file'
%   MAKE file verbose   verbose == true: display warning messages

%   Author: A. Bemporad
%   Revised by: R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2008/01/29 15:35:14 $

if nargin<1,
    file='';
    makeall=true;
    verbose=false;
elseif nargin<2,
    file=lower(file);
    makeall=strcmp(file,'');
    verbose=false;
else
    file=lower(file);
    makeall=strcmp(file,'');
end

if makeall || strcmp(file,'mpc_sfun'),
    fprintf('Compiling MPC_SFUN ...');
    if verbose
        mex -v -g mpc_sfun.c
    else
        mex mpc_sfun.c
    end
    !move mpc_sfun.mexw32 ..
    fprintf('Done!\n');
end

if makeall || strcmp(file,'mpcloop_engine'),
    fprintf('Compiling MPCLOOP_ENGINE ...');
    if verbose
        mex -v -g mpcloop_engine.c
    else
        mex mpcloop_engine.c
    end
    !move mpcloop_engine.mexw32 ..
    fprintf('Done!\n');
end

if makeall || strcmp(file,'qpsolver'),
    fprintf('Compiling QPSOLVER ...');
    if verbose
        mex -v -g qpsolver.c
    else
        mex qpsolver.c
    end
    !move qpsolver.mexw32 ..
    fprintf('Done!\n');
end

disp(' ')
disp('NOTE: To build RTW files, you must copy MPC_SFUN.C, MPC_SFUN.H, MPC_COMMON.C, MAT_MACROS.H, DANTZGMP_SOLVER.C, DANTZGMP.H')
disp('      to $matlabroot\toolbox\mpc\mpcutils\src\')
