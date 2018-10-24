function setCellDataAt(this, javaObj, row, col)
% Callback executes when a TableObject cell has been edited.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2008/05/19 23:19:15 $

[Rows,Cols] = size(this.CellData);

if (row > 0 && row <= Rows) && ...
        (col > 0 && col <= Cols)
    
    % However, if dataObj.class is Boolean, assume that
    % validation isn't needed.
    if isjava(javaObj)
        objClass = javaObj.class;
    else
        objClass = 'none';
    end
    if ~this.isString(col)
        try
            if isjava(javaObj)
                CellData = javaObj.booleanValue;
            else
                CellData = javaObj;
            end
            if isempty(this.DataCheckArgs)
                OK = feval(this.DataCheckFcn, CellData, row, col);
            else
                OK = feval(this.DataCheckFcn, CellData, row, col, ...
                                this.DataCheckArgs);
            end
        catch ME
            disp(sprintf('Updating cell [%i,%i]. Cell class is java.lang.Boolean, but object supplied is "%s".',row,col,objClass));
            OK = 0;            
        end
    else
        try
            CellData = char(javaObj);
            if isempty(this.DataCheckArgs)
                funcstruct = functions(this.DataCheckFcn);
                if strcmp(funcstruct.function,'InOutCheckFcn')
                    [OK CellData] = feval(this.DataCheckFcn, CellData, row, col);
                    awtinvoke(this.Table.getModel,'setCellDataAt(Ljava.lang.Object;II)', CellData, row-1, col-1);
                else
                    OK = feval(this.DataCheckFcn, CellData, row, col);
                end
            else
                OK = feval(this.DataCheckFcn, CellData, row, col, this.DataCheckArgs);
            end
        catch ME
            OK = 0;
            disp(ME.message);
            disp(sprintf('Updating cell [%i,%i]. Cell class is java.lang.String, but object supplied is "%s".',row,col,objClass));            
        end
    end
    if OK
        % Valid data, so store in UDD table object
        this.ListenerEnabled = false;
        this.CellData{row,col} = CellData;
    else
        % Invalid data, so reset java table data
        awtinvoke(this.Table.getModel,'setCellDataAt(Ljava.lang.Object;II)', this.CellData{row,col}, row-1, col-1);
    end
else
    % Outside table dimensions.
    disp(sprintf('Requested cell [%i,%i] is outside of table dimensions [%i,%i].',row,col,Rows,Cols));
end
