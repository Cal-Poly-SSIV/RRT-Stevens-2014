function setCellData(this, Data)
% Store data in table object's CellData property.
% Make sure elements are all legal java objects.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc. 
%  $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:45:54 $

[Rows,Cols] = size(Data);
for j = 1:Cols
    for i = 1:Rows
        if isempty(Data{i,j})
            if this.isString(j)
                Data{i,j} = java.lang.String('');
            else
                disp(sprintf('Unexpected null in [%i,%i]',i,j));
                return
            end
        end
    end
end
this.ListenerEnabled = true;
this.CellData = Data;