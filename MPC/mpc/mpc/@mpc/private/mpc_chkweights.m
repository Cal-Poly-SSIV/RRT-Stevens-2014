function newWeights=mpc_chkweights(Weights,p,nu,ny,myindex)
%MPC_CHKWEIGHTS Check Weights structure

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.7 $  $Date: 2008/06/13 15:25:48 $

verbose = mpccheckverbose;

default=mpc_defaults;

if isempty(Weights),
    % Define Weights as a structure
    def=default.weight.manipulatedvariables;
    Weights.ManipulatedVariables=def*ones(1,nu);
    if verbose,
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:NoWeightOnMV',def));
    end
end

if ~isa(Weights,'struct'),
    ctrlMsgUtils.error('MPC:utility:InvalidWeight');
end

fields={'ManipulatedVariables','ManipulatedVariablesRate','OutputVariables','ECR'};

s=fieldnames(Weights); % get field names
for i=1:length(s),
    Name=s{i};
    name=lower(Name);
    % Handle multiple names
    if strcmp(name,'mv') || strcmp(name,'manipulated') || strcmp(name,'input'),
        name='manipulatedvariables';
    elseif strcmp(name,'ov') || strcmp(name,'controlled') || strcmp(name,'output'),
        name='outputvariables';
    elseif strcmp(name,'mvrate') || strcmp(name,'manipulatedrate') || strcmp(name,'inputrate'),
        name='manipulatedvariablesrate';
    end

    j=find(ismember(lower(fields),name)); % locate name within 'fields'
    if isempty(j), % field inexistent
        ctrlMsgUtils.error('MPC:utility:InvalidWeightField',Name);
    else
        aux=fields{j};
        aux2=Weights.(Name);
        if ~isa(aux2,'double') && ~isa(aux2,'cell'),
            ctrlMsgUtils.error('MPC:utility:InvalidWeightValue');
        else
            % Check correctness of weight
            switch name
                case {'manipulatedvariables','manipulatedvariablesrate'}
                    aux2=mpc_prechkwght(['Weights.' Name],aux2,p,nu,name);
                case 'outputvariables'
                    aux2=mpc_prechkwght(['Weights.' Name],aux2,p,ny,name);
                case 'ecr'
                    aux2=mpc_prechkwght(['Weights.' Name],aux2,1,1,name);
            end
            newWeights.(aux)=aux2;
        end
    end
end


% Define missing fields
for i=1:length(fields),
    aux=fields{i};
    if ~isfield(newWeights,aux),
        %eval(['newWeights.' aux '=[];']);
        newWeights.(aux)=[];
    end
    %eval(['aux2=newWeights.' aux ';']);
    aux2=newWeights.(aux);
    if isempty(aux2),
        %eval(['def=default.weight.' lower(aux) ';']);
        def=default.weight.(lower(aux));
        switch aux
            case 'ManipulatedVariables'
                %eval(['newWeights.' aux '=def*ones(1,nu);']);
                newWeights.(aux)=def*ones(1,nu);
                if verbose,
                    fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:NoWeightOnMV',def));
                end
            case 'ManipulatedVariablesRate'
                %eval(['newWeights.' aux '=def*ones(1,nu);']);
                newWeights.(aux)=def*ones(1,nu);
                if verbose,
                    fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:NoWeightOnMVRate',def));
                end
            case 'OutputVariables',
                %eval(['newWeights.' aux '=def*ones(1,ny);']);
                newWeights.(aux)=def*ones(1,ny);
                if verbose,
                    fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:NoWeightOnMO',def));
                end
                if nu<ny,
                    % Not enough inputs, set zero weights on (some) unmeasured outputs
                    uyindex=setdiff((1:ny)',myindex(:));
                    yindex=[myindex;uyindex];
                    weightindex=yindex(1:nu);
                    unweightindex=yindex(nu+1:ny);
                    newWeights.(aux)(unweightindex)=zeros(ny-nu,1);
                    if verbose,
                        fprintf('   for output(s) %s',sprintf('y%d ',weightindex));
                        if length(weightindex)>10,
                            fprintf('\n   ')
                        end
                        fprintf('and zero weight for output(s) %s\n',sprintf('y%d ',unweightindex));
                    end
                end
            case 'ECR',
                % Now all input and output weights have been defined, because 'ECR' is the last element in fields
                newWeights.ECR=def*max([newWeights.ManipulatedVariables(:);...
                    newWeights.ManipulatedVariablesRate(:);...
                    newWeights.OutputVariables(:)]); % Weight on slack variable for ECRs
        end
    end
end

function newwt=mpc_prechkwght(a,wt,p,n,name)
newwt=wt;
weightmat=0;
if isempty(wt),
    if ~strcmp(name,'ecr'),
        %eval(['newwt=default.weight.' name '*ones(1,n);']);
        newwt=default.weight.(name)*ones(1,n);
        return
    end
end

if isa(wt,'cell'),
    % Cell containing weight matrix
    if length(wt)>1,
        ctrlMsgUtils.error('MPC:utility:InvalidWeightDiagonal',n,n);        
    end
    wt=wt{1};
    weightmat=1;
end

if any(~isfinite(wt(:)))
    ctrlMsgUtils.error('MPC:utility:InvalidWeightInfiniteNegative',a);            
end

[nrow,ncol]=size(wt);
if ~weightmat,
    if any(wt(:)< 0)
        ctrlMsgUtils.error('MPC:utility:InvalidWeightInfiniteNegative',a);            
    end
    if nrow>p         % Has the user specified a longer horizon than necessary?
        if mpccheckverbose
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:TooManyWeights',a));
        end
        newwt=wt(1:p,:);
    end
    if ncol~=n         % Has the user specified more weights than necessary?
        ctrlMsgUtils.error('MPC:utility:InvalidWeightSizeColumn',a,n);                    
    end
else
    if (nrow~=n)||(ncol~=n),
        ctrlMsgUtils.error('MPC:utility:InvalidWeightSizeFull',a,n);                    
    end
    try
        semdeftol=sqrt(eps)*max(max(abs(wt)));
        chol((wt+wt')/2+semdeftol*eye(n));
    catch ME
        ctrlMsgUtils.error('MPC:utility:InvalidWeightPSD');        
    end
    newwt={wt};
end
%end mpc_prechkwght
