function setEnabled(this,State)

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2007/11/09 20:45:46 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

if xor(this.isEnabled, State)
    awtinvoke(this.Slider,'setEnabled(Z)',State);
    awtinvoke(this.TextField,'setEnabled(Z)',State);
end
this.isEnabled = State;