% == == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == % PSO_Parameter_Study.m % == == == == == == == == == == == == ==
    == == == == == == == == == == == == == == == == == clc;
clear;
close all;

% % Problem definition nVar = 6;
VarMin = -0.2;
VarMax = 0.2;

%% Reduced budget for B4
nPop    = 10;
MaxIter = 20;

% % PSO cases cases(1).name = 'Baseline (Balanced)';
cases(1).w = 1.0;
cases(1).wdamp = 0.99;
cases(1).c1 = 2.0;
cases(1).c2 = 2.0;

cases(2).name = 'Exploitation (Social)';
cases(2).w = 0.5;
cases(2).wdamp = 1.0;
cases(2).c1 = 0.5;
cases(2).c2 = 2.5;

cases(3).name = 'Exploration (Indep.)';
cases(3).w = 0.9;
cases(3).wdamp = 1.0;
cases(3).c1 = 2.5;
cases(3).c2 = 0.5;

results = struct([]);

fprintf('Starting Parameter Study\n');
fprintf('Total planned evaluations ~ %d\n', nPop *(MaxIter + 1) * numel(cases));

%% Run cases
for c = 1:numel(cases)

    fprintf('\n--------------------------------------\n');
fprintf('Running Case %d: %s\n', c, cases(c).name);
fprintf('Params: w=%.2f, wdamp=%.2f, c1=%.2f, c2=%.2f\n', ... cases(c).w,
        cases(c).wdamp, cases(c).c1, cases(c).c2);

w = cases(c).w;
wdamp = cases(c).wdamp;
c1 = cases(c).c1;
c2 = cases(c).c2;

% Particle template p0.position = [];
p0.velocity = [];
p0.fitness = [];
p0.best.position = [];
p0.best.fitness = [];

particle = repmat(p0, nPop, 1);

global_best.position = [];
global_best.fitness = inf;

    % ----- Initialisation -----
    for i = 1:nPop
        if i == 1
            particle(i).position = [0.15, 0.15, 0.15, -0.15, -0.15, -0.15];
    else particle(i).position = unifrnd(VarMin, VarMax, [1 nVar]);
    end

        particle(i)
            .velocity = zeros(1, nVar);

    particle(i).fitness = objective_function(particle(i).position);

    particle(i).best.position = particle(i).position;
    particle(i).best.fitness = particle(i).fitness;

    if particle (i)
      .best.fitness < global_best.fitness global_best = particle(i).best;
    end end

        % -- -- -Optimisation loop-- -- -BestCost = zeros(MaxIter, 1);

    for it = 1:MaxIter
        for i = 1:nPop

            particle(i).velocity = w * particle(i).velocity ...
                + c1 * rand(1, nVar) .* (particle(i).best.position - particle(i).position) ...
                + c2 * rand(1, nVar) .* (global_best.position - particle(i).position);

    particle(i).position = particle(i).position + particle(i).velocity;

    particle(i).position = max(particle(i).position, VarMin);
    particle(i).position = min(particle(i).position, VarMax);

    particle(i).fitness = objective_function(particle(i).position);

    if particle (i)
      .fitness < particle(i).best.fitness particle(i).best.position =
          particle(i).position;
    particle(i).best.fitness = particle(i).fitness;

    if particle (i)
      .best.fitness < global_best.fitness global_best = particle(i).best;
    end end end

        w = w * wdamp;

    BestCost(it) = global_best.fitness;
    fprintf('Iter %2d/%2d: Best Cost = %.6f\n', it, MaxIter, BestCost(it));
    end

        results(c)
            .BestCost = BestCost;
    results(c).GlobalBest = global_best;
    results(c).RunParams = cases(c);
    end

        % %
        Plot comparison figure('Name', 'PSO Parameter Comparison',
                               'NumberTitle', 'off');
    hold on;
    styles = {'r-o', 'b-s', 'g-^'};
for
  c = 1 : numel(cases) plot(1 : MaxIter, results(c).BestCost, styles{c},
                            ... 'LineWidth', 1.5, 'DisplayName', cases(c).name);
end xlabel('Iteration');
ylabel('Best Fitness (CD/CL)');
title('Comparison of PSO Control Parameters');
grid on;
legend('show', 'Location', 'best');
hold off;

saveas(gcf, 'B4_Comparison_Plot.jpg');

% %
    Print summary
        fprintf('\n=======================================================\n');
fprintf('FINAL RESULTS SUMMARY\n');
fprintf('=======================================================\n');
save('PSO_Parameter_Study_Results.mat', 'results');
fprintf('Saved results to PSO_Parameter_Study_Results.mat\n');
for
  c = 1 : numel(cases) fprintf('%-25s | Final Fit = %.6f\n', cases(c).name,
                               results(c).GlobalBest.fitness);
end fprintf('=======================================================\n');
save('PSO_Parameter_Study_Results.mat', 'results');
fprintf('Saved results to PSO_Parameter_Study_Results.mat\n');

% == == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == % Objective function(robust) - USES your xfoil(x) % == == == ==
    == == == == == == == == == == == == == == == == == == == == == == == == ==
    == function f = objective_function(x) persistent callCount
    if isempty (callCount),
                callCount = 0;
end callCount = callCount + 1;

wu = x(1 : 3);
wl = x(4 : 6);

    % 1) Geometry check
    if any(wu <= wl)
        f = 100;
    return;
    end

    % 2) Thickness check (10%)
    try
        coord = CST_airfoil(wl, wu, 0, 100);
    % your CST_airfoil catch f = 100;
    return;
    end

        y = coord( :, 2);
    max_t = 0;
    for
      k = 1 : 50 t_k = y(102 - k) - y(k);
    if t_k
      > max_t, max_t = t_k;
    end end if max_t < 0.10 f = 100;
    return;
    end

    % 3) XFOIL evaluation (your proven wrapper)
    res = xfoil(x);
    cl = res(1);
    cd = res(2);

    % 4) Guards to avoid fake zeros
    CL_min = 0.05;
    CD_min = 1e-4;
    CL_max = 2.5;
    CD_max = 1.0;

    if any (~isfinite([cl cd]))
      f = 100;
    return;
    end if cd > 1000 f = 100;
    return;
    end if (cl < CL_min) || (cl > CL_max) || (cd < CD_min) || (cd > CD_max) f =
        100;
    return;
    end

        f = cd / cl;

    % Debug print for first few calls only
    if callCount <= 5
        fprintf('[DEBUG] call %d: CL=%.4f, CD=%.6f, f=%.6f\n', callCount, cl, cd, f);
    end end
