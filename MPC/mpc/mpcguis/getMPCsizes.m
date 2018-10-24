function [NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S)
% Convenience function gets signal size information from MPCGUI node

%	Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.3 $  $Date: 2007/11/09 20:42:07 $

NumMV = S.Sizes(1);
NumMD = S.Sizes(2);
NumUD = S.Sizes(3);
NumMO = S.Sizes(4);
NumUO = S.Sizes(5);
NumIn = S.Sizes(6);
NumOut = S.Sizes(7);