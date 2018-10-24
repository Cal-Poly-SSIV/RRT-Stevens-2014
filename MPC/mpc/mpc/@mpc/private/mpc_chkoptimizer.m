function newOptimizer=mpc_chkoptimizer(Optimizer)
%MPC_CHKOPTIMIZER Check if Optimizer structure is ok and define defaults

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date:

default=mpc_defaults;
verbose = mpccheckverbose;

if isempty(Optimizer),
    Optimizer.MaxIter=default.optimizer.maxiter;
end

if ~isa(Optimizer,'struct'),
    ctrlMsgUtils.error('MPC:utility:InvalidOptimizerInput');
end

fields={'MaxIter','Trace','Solver','MinOutputECR'};

s=fieldnames(Optimizer);

% Check for wrong or ambiguous fields
for i=1:length(s),
    name=s{i};
    j=strmatch(lower(name),lower(fields));
    if isempty(j), % field inexistent
        ctrlMsgUtils.error('MPC:utility:InvalidOptimizerField',name);
    end
    if numel(j)>1,
        ctrlMsgUtils.error('MPC:utility:AmbiguousOptimizerField');        
    end
    % Correct the name
    s{i}=fields{j};
end

for j=1:length(fields),
    aux=fields{j};
    i=find(ismember(lower(s),lower(aux))); % locate fields{j} within s
    if isempty(i),
        % Define missing field
        field=[];
        %eval(sprintf('Optimizer.%s=field;',aux));
        Optimizer.(aux)=field;
    else
        % In case of duplicate names because of different case, the last
        % element i(end) is the one supplied as latest (through SET)
        s=fieldnames(Optimizer); % retrieve original names
        aux=s{i(end)};
        %eval(sprintf('field=Optimizer.%s;',aux));
        %eval(sprintf('Optimizer=rmfield(Optimizer,''%s'');',aux));
        %eval(sprintf('Optimizer.%s=field;',fields{j}));
        field=Optimizer.(aux);            % retrieve value
        Optimizer=rmfield(Optimizer,aux); % remove duplicated field
        Optimizer.(fields{j})=field;      % update field
    end

    switch lower(aux)

        case 'maxiter'
            errid='MPC:utility:InvalidOptimizerMaxIter';
            errflag=1;
            if isempty(field),
                field=default.optimizer.maxiter;
                errflag=0;
            elseif isa(field,'double') && numel(field)==1 && field>0 && isfinite(field),
                errflag=0;
                if round(field)~=field,
                    field=round(field);
                    if verbose,
                        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:OptimizerMaxIterRounded',field));
                    end
                end
            end

        case 'trace'
            errid='MPC:utility:InvalidOptimizerTrace';
            errflag=1;
            if isempty(field),
                field=default.optimizer.trace;
                errflag=0;
            elseif isa(field,'char') && (strcmpi(field,'on') || strcmpi(field,'off')),
                errflag=0;
            end

        case 'solver'
            errid='MPC:utility:InvalidOptimizerSolver';
            errflag=1;
            if isempty(field),
                field=default.optimizer.solver;
                errflag=0;
            elseif isa(field,'char') && strcmpi(field,'activeset'),
                errflag=0;
            end

        case 'minoutputecr'
            errid='MPC:utility:InvalidOptimizerECR';
            errflag=1;
            if isempty(field),
                field=default.optimizer.minoutputecr;
                errflag=0;
            elseif isa(field,'double') && numel(field)==1 && field>0 && isfinite(field),
                errflag=0;
                if field<default.optimizer.minoutputecr,
                    if verbose,
                        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:OptimizerMinOutputECRTooSmall',default.optim.minoutputecr));
                    end
                end
            end
    end

    if errflag,
        ctrlMsgUtils.error(errid);                
    end
    %eval(['Optimizer.' aux '=field;']);
    Optimizer.(aux)=field;
end

newOptimizer=Optimizer;