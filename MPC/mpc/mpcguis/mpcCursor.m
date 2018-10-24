function mpcCursor(Frame, Type)
% MPCCURSOR  Sets a "wait" or "default" cursor on a gui frame.
%            Uses a thread-safe approach.

%	Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.5 $  $Date: 2007/11/09 20:42:12 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
import java.awt.*;

if isempty(Frame)
    return
end

switch Type
    case 'wait'
        NewCursor = java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.WAIT_CURSOR);
    case 'default'
        NewCursor = java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.DEFAULT_CURSOR);
end

awtinvoke(Frame,'setCursor(Ljava.awt.Cursor;)',NewCursor);
