function xoverKids  = crossoverintermediate_zahra(parents,options,GenomeLength,~,~,thisPopulation,ratio)
%CROSSOVERINTERMEDIATE Weighted average of the parents.
%   XOVERKIDS = CROSSOVERINTERMEDIATE(PARENTS,OPTIONS,GENOMELENGTH, ...
%   FITNESSFCN,UNUSED,THISPOPULATION,RATIO) creates the crossover children
%   XOVERKIDS of the given population THISPOPULATION using the available
%   PARENTS. This kind of recombination can only work for real valued
%   genomes. A point is chosen partway between the two parents.
%
%   RATIO controls the range over which the children can occur.
%   A scalar ratio will generate children on the line between the parents.
%   A vector ratio (length = GenomeLength) can produce children anywhere in
%   the hypercube with the parents at opposite corners.
%
%   Example:
%    Create an options structure using CROSSOVERINTERMEDIATE as the crossover
%    function with default ratio = ones(1,GenomeLength)
%     options = optimoptions('ga', 'CrossoverFcn', @crossoverintermediate);
%
%   Create an options structure using CROSSOVERINTERMEDIATE as the crossover
%    function with RATIO of .5
%     ratio = 0.5
%     options = optimoptions('ga', 'CrossoverFcn', {@crossoverintermediate, ratio});
%
%    (Note: If calling gamultiobj, replace 'ga' with 'gamultiobj') 

%   Copyright 2003-2015 The MathWorks, Inc.

% here's the default if nothing is passed in.
if nargin < 7 || isempty(ratio)
    ratio = ones(1,GenomeLength);
end

% How many children to produce?
nKids = length(parents)/2;
% Extract information about linear constraints, if any
linCon = options.LinearConstr;
constr = ~isequal(linCon.type,'unconstrained');
% Allocate space for the kids
xoverKids = zeros(nKids,GenomeLength);

% To move through the parents twice as fast as thekids are
% being produced, a separate index for the parents is needed
index = 1;

for i=1:nKids
    % get parents
    parent1 = thisPopulation(parents(index),:);
    index = index + 1;
    parent2 = thisPopulation(parents(index),:);
    index = index + 1;

    % a random number (or vector) on the interval [0,ratio]
    scale = ratio .* rand(1,length(ratio));

    % a child gets half from each parent
    xoverKids(i,:) = round(parent1 + scale .* (parent2 - parent1),1);
    % Make sure that offspring are feasible w.r.t. linear constraints
    if constr
        feasible = isTrialFeasible(xoverKids(i,:)',linCon.Aineq,linCon.bineq,linCon.Aeq, ...
                            linCon.beq,linCon.lb,linCon.ub,options.TolCon);
        if ~feasible % Kid is not feasible
            % Children are arithmetic mean of two parents (feasible w.r.t
            % linear constraints)
            alpha = rand;
            xoverKids(i,:) = round(alpha*parent1 + (1-alpha)*parent2,1);
        end
    end
end