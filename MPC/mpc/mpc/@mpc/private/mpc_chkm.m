function newmoves=mpc_chkm(moves,p,default)
%MPC_CHKM Check control horizon

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2007/11/09 20:40:11 $

verbose = mpccheckverbose;

% checks if moves is ok.
if ~isa(moves,'double') 
    ctrlMsgUtils.error('MPC:utility:InvalidControlHorizon');
elseif isempty(moves)
    newmoves=min(default,p);
    if verbose
        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:AssumeControlHorizon',newmoves));
    end
elseif ~isvector(moves) || any(moves < 1)
    ctrlMsgUtils.error('MPC:utility:InvalidControlHorizonValue');
else
    if isscalar(moves)
        %  This section interprets "moves" as a number of moves, each
        %  of one sampling period duration.
        if moves > p %#ok<BDSCI>
            warning('MPC:object:CHGreaterThanPH',ctrlMsgUtils.message('MPC:object:CHGreaterThanPH'));    
            moves=p;
        end
    else
        % This section interprets "moves" as a vector of blocking factors.
        % make sure moves is a row vector
        moves = moves(:)';
        nb = length(moves);
        summoves=sum(moves);
        if summoves > p
            if verbose
                fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:SumCHGreaterThanPH'));
            end
            nb=find(cumsum(moves) > p);
            nb=nb(1);
            moves=moves(1,1:nb-1);
            moves(nb)=p-sum(moves);
            if nb==1,    % If the vector has only one component, than number of moves=1
                moves=1;
            end
        elseif summoves < p
            nb=nb+1;
            moves(nb)=p-summoves;
        end
        if moves(end)==0,
            moves(end)=[];
        end
    end
    newmoves=moves;
end

% end mpc_chkm
