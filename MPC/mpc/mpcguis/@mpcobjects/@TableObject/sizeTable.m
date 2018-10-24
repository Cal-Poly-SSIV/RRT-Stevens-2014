function sizeTable(this, ViewportSize, ColumnSizes, AutoResizeMode)
%SIZETABLE Size an MPCTable (mpcobjects.TableObject) table

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2007/11/09 20:46:01 $

import java.awt.*;
import javax.swing.*;

[nRows,nCols] = size(this.CellData);
Table=this.Table;
if ~isnumeric(ViewportSize) || length(ViewportSize(:)) ~= 2
    disp(sprintf(['ViewportSize must be vector, length 2,\n   but', ...
            ' size(ViewportSize) = [%i,%i].'],size(ViewportSize)))
    return
elseif ~isnumeric(ColumnSizes) || length(ColumnSizes(:)) ~= nCols
    disp(sprintf(['Expected ColumnSizes to be vector, length %i,\n', ...
            '   but size(ColumnSizes) = [%i,%i].'],nCols,size(ColumnSizes)))
    return
elseif ~ischar(AutoResizeMode)
    disp('ResizePolicy must be a string')
    return
end
Model = Table.getColumnModel;
for i=1:nCols
    Column = Model.getColumn(i-1);
    Column.setMinWidth(ColumnSizes(i));
    Column.setPreferredWidth(ColumnSizes(i));
end

Table.setPreferredScrollableViewportSize(Dimension(ViewportSize(1), ...
    ViewportSize(2)));

if strcmpi(AutoResizeMode,'off')
    Policy = JTable.AUTO_RESIZE_OFF;
elseif strcmpi(AutoResizeMode,'next_column')
    Policy = JTable.AUTO_RESIZE_NEXT_COLUMN;
elseif strcmpi(AutoResizeMode,'last_column')
    Policy = JTable.AUTO_RESIZE_LAST_COLUMN;
elseif strcmpi(AutoResizeMode,'all_columns')
    Policy = JTable.AUTO_RESIZE_ALL_COLUMNS;
else
    Policy = JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS;
end
Table.setAutoResizeMode(Policy);
        