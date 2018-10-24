function setNominal(h,opreport)
% Sets nominal data in MPC GUI node to values defined in the specfied
% operating condition report object. Note that this method will always be
% called after adding a model to the MPC project so it is assumed the the
% MPC i/i table is synchronized with the linearization i/o.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.7 $ $Date: 2008/05/31 23:21:49 $

%% Get the table data and io data
outtabledata = h.outUDD.CellData;
intabledata = h.inUDD.CellData;
Itablemv = find(strcmp('Manipulated',intabledata(:,2)));
Itablemd = find(strcmp('Meas. disturb.',intabledata(:,2)));

%% If necessary stop the simulation
if ~strcmp(get_param(opreport.Model, 'SimulationStatus'),'stopped')
       feval(opreport.Model,[],[],[],'term')
end
    
%% Loop through each constraint in order and represent the constraint in
%% the input or output table
if strcmp(get_param(h.Block,'MaskType'),'MPC')    
    outputBlock = h.Block;
else
    outputBlock = [h.Block '/MPC1'];
end
    
for k=1:length(opreport.outputs)
    data = opreport.outputs(k).y;
    I = 1:length(data);
    if ~isempty(I)
        % Is this constraint an MV?
        if strcmp(opreport.outputs(k).Block,outputBlock)
            for j=1:length(Itablemv)
                intabledata{Itablemv(j),end} = sprintf('%0.4g',data(I(j)));             
            end
        % Is this constraint an MO
        elseif k==2
            for j=1:size(outtabledata,1)
                outtabledata{j,end} = sprintf('%0.4g',data(I(j)));
            end
        % Is this constraint an MD
        else
            for j=1:length(Itablemd)
                intabledata{Itablemd(j),end} = sprintf('%0.4g',data(I(j)));             
            end
        end
    end
end

%% Write data back to tables
h.InUDD.setCellData(intabledata);
h.OutUDD.setCellData(outtabledata);


