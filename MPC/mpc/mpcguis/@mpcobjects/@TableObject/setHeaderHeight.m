function setHeaderHeight(this, Height)
% Set table's header height.  Only works if the table has already been written.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2007/11/09 20:45:59 $

import javax.swing.*;
import com.mathworks.toolbox.mpc.*;

Header = this.Table.getTableHeader;
if isempty(Header)
    % Can come here if header hasn't been created yet
    return
end
HeaderSize = Header.getSize;
if round(HeaderSize.height) ~= Height
    this.Table.setHeaderHeight(java.awt.Dimension(HeaderSize.width, Height));
end
