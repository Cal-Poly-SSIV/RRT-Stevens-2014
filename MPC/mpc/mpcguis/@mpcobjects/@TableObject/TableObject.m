function this = TableObject(Header, isEditable, javaClass, ...
                    CellData, DataCheckFcn, varargin)
% Class constructor

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2007/11/09 20:45:51 $

this=mpcobjects.TableObject;
% if nargin == 0, creating object from a saved state.
if nargin > 0
    this.Header = Header;
    this.isEditable = isEditable;
    this.isString = javaClass;
    this.setCellData(CellData);
    this.DataCheckFcn = {DataCheckFcn};
    this.DataCheckArgs = varargin;
    this.selectedRow = -1;
    this.DataListener = handle.listener(this, this.findprop('CellData'), ...
        'PropertyPostSet', {@LocalDataListener, this});
    this.EditListener = handle.listener(this, this.findprop('isEditable'), ...
        'PropertyPostSet', {@LocalDataListener, this});
    this.SelectionListener = handle.listener(this, this.findprop('selectedRow'), ...
        'PropertyPostSet', {@LocalRowListener, this});
    this.ListenerEnabled = true;
    this.CellEditor = [];
end

% -------------------------------------------------------------- %

function LocalDataListener(eventSrc, eventData, this)
% Responds to change in CellData and/or isEditable property.  Updates 
% data in the java table.

%disp('In LocalDataListener')
if this.ListenerEnabled
    this.Table.getModel.updateTableData(this.Table, this, ...
        this.isEditable', this.CellData');
else
    % If not enabled, turn back on for next event
    this.ListenerEnabled = true;
end
% Make sure cell activation selects contents
if isempty(this.CellEditor)
    Editable = find(this.isEditable); % Look for an editable column
    if ~isempty(Editable)
        awtinvoke(this.Table,'editCellAt(II)',0,Editable(1)-1);
        this.CellEditor = awtinvoke(this.Table,'getCellEditor()');
        if ~isempty(this.CellEditor)
            awtinvoke(this.CellEditor,'setClickCountToStart(I)',1);
        end
    end
end


% -------------------------------------------------------------- %

function LocalRowListener(eventSrc, eventData, this)
% Responds to change in selectedRow property.  
% Selects the row in the java table.

%disp('In LocalRowListener')
if this.ListenerEnabled
    awtinvoke(this.Table,'updateSelectedRow(I)',this.selectedRow-1);
end
