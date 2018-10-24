function mpc_combo_updater(Combo,List,SelectedItem)
% MPC_COMBO_UPDATER Refresh the information displayed in a combo box.
%
% Combo = MJComboBox handle
% List = Cell array of strings containing the items to be displayed in
%        the combo box.
% SelectedItem = string specifying item to be selected.

%	Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.5 $  $Date: 2007/11/09 20:42:15 $

import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.mpc.*;

if nargin < 3
    SelectedItem = [];
end

% Clear the combo box
awtinvoke(Combo,'removeAllItems');

ItemFound = false;
for i = 1:length(List)
    % Make sure SelectedItem is in List
    if strcmp(List{i}, SelectedItem)
        ItemFound = true;
    end
    % Add item to combo box
    awtinvoke(Combo,'addItem(Ljava.lang.Object;)',java.lang.String(List{i}));
end
if isempty(SelectedItem)
    % Don't attempt to set the selected item if the input wasn't supplied
    return
end
if ~ItemFound
    disp('Item "%s" was not in ComboBox List', SelectedItem);
    return
else
    awtinvoke(Combo,'setSelectedItem(Ljava.lang.Object;)',java.lang.String(SelectedItem));
end
