function NewText = htmlText(Text)
% Add html editing tags to beginning and end of a text string.
% This also sets the font.

%	Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.3 $  $Date: 2007/11/09 20:42:10 $

NewText = ['<html><font face="Arial" size="2">', Text, '</font>'];
