function h = mpcbrowser

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:46:24 $

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.mpc.*;

h = mpcobjects.mpcbrowser;
h.javahandle = MPCimportView(h);

