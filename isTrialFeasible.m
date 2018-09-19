function [feasible,maxconstraint] = isTrialFeasible(X,Aineq,bineq,Aeq,beq,lb,ub,tol)
%isTrialFeasible Checks if X is feasible w.r.t. linear constraints.
% This function computes the largest violation of any linear constraint
% (for a single point or a population). If this is less than the given
% tolerance (tol), the point(s) are feasible.
% 	

%   Copyright 2003-2014 The MathWorks, Inc.


argub = isfinite(ub);
arglb = isfinite(lb);
haveIneqs = ~isempty(bineq);
haveEqs = ~isempty(beq);

% This function can test feasibility for a single point or a population of
% points. Check X to see which mode we are operating in.
if ~isvector(X)
    % Convert data to double in order to make bsxfun happy.
    X = double(X);
    maxconstraint = zeros(size(X,1),1);
    % Upper bounds
    if ~isempty(argub) && any(argub)
        maxconstraint = max( max(bsxfun(@minus,X(:,argub),ub(argub)'),[],2), maxconstraint);
    end
    % Lower bounds
    if any(arglb) && ~isempty(arglb)
        maxconstraint = max( max(bsxfun(@minus,lb(arglb)',X(:,arglb)),[],2), maxconstraint);
    end
    
    % Inequality constraints
    if haveIneqs
        maxconstraint = max( max(bsxfun(@minus,Aineq*X',bineq),[],1)', maxconstraint);
    end
    
    % Equality constraints
    if haveEqs
        maxconstraint = max( max(abs(bsxfun(@minus,Aeq*X',beq)),[],1)', maxconstraint);
    end
	feasible = maxconstraint <= tol;	
else % Single point (X is a vector)
    feasible = true;
    X = double(X(:));
    maxconstraint = 0;
    
    % Upper bounds
    if ~isempty(argub) && any(argub) 
        maxconstraint = max(max(X(argub) - ub(argub)),maxconstraint);
		feasible = maxconstraint <= 0;
    end
    % Lower bounds
    if ~isempty(arglb) && any(arglb)
        maxconstraint = max(max(lb(arglb) - X(arglb)),maxconstraint);
		feasible = feasible && maxconstraint <= 0;
    end
    
    % Inequality constraints
    if haveIneqs
        constrViolation = Aineq*X-bineq;
        maxconstraint = max(max(constrViolation(~isinf(constrViolation))),maxconstraint);
		feasible = feasible && maxconstraint <= tol;
    end
    % Equality constraints
    if haveEqs
        constrViolation = (Aeq*X-beq);
        maxconstraint = max(max(abs(constrViolation(~isinf(constrViolation)))),maxconstraint);
		feasible = feasible && maxconstraint <= tol;
    end    
end