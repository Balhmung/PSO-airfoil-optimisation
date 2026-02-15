% == == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == % PSO_Airfoil_Optimisation.m %
                    Particle Swarm Optimisation coupled with XFOIL %
                    Saves results to : PSO_XFOIL_Results.mat %
    == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == == clc;
clear;
close all;

% -- -- -- -- -- -- -- -- -- -- -- -- -- --% PSO parameters %
    -- -- -- -- -- -- -- -- -- -- -- -- -- --nVar = 6;
% 6 CST weights(3 upper, 3 lower) VarMin = -0.2;
% Lower bound VarMax = 0.2;
% Upper bound

        MaxIter = 100;
% Max iterations nPop = 20;
% Swarm size

        w0 = 1;
% Initial inertia weight w = w0;
d = 0.99;
% Inertia damping c1 = 2;
% Cognitive coefficient c2 = 2;
% Social coefficient

    % -- -- -- -- -- -- -- -- -- -- -- -- -- --% Particle template %
    -- -- -- -- -- -- -- -- -- -- -- -- -- --x0.position = [];
x0.velocity = [];
x0.fitness = [];
x0.cl = [];
x0.cd = [];
x0.best.position = [];
x0.best.fitness = [];
x0.best.cl = [];
x0.best.cd = [];

x = repmat(x0, nPop, 1);

% -- -- -- -- -- -- -- -- -- -- -- -- -- --% Global best template %
    -- -- -- -- -- -- -- -- -- -- -- -- -- --global_best.position = [];
global_best.fitness = inf;
global_best.cl = NaN;
global_best.cd = NaN;

% -- -- -- -- -- -- -- -- -- -- -- -- -- --% History arrays %
    -- -- -- -- -- -- -- -- -- -- -- -- -- --B = zeros(MaxIter, 1);
% Best fitness history(CD / CL) C = zeros(MaxIter, nVar);
% Best position history CL = zeros(MaxIter, 1);
% Best CL history CD = zeros(MaxIter, 1);        % Best CD history

% ============================================================
% Initial population
% ============================================================
for i = 1:nPop
    if i == 1
        % Seed particle with a safe baseline geometry
        x(i).position = [0.15, 0.15, 0.15, -0.15, -0.15, -0.15];
else x(i).position = unifrnd(VarMin, VarMax, [1 nVar]);
end

    x(i)
        .velocity = zeros(1, nVar);

disp(['Evaluating particle ' num2str(i) ' / ' num2str(nPop)]);

[ x(i).fitness, x(i).cl, x(i).cd ] = objective_function(x(i).position);

x(i).best.position = x(i).position;
x(i).best.fitness = x(i).fitness;
x(i).best.cl = x(i).cl;
x(i).best.cd = x(i).cd;

if x (i)
  .best.fitness < global_best.fitness global_best = x(i).best;
end end

        %
    == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == == % Plot settings % == == == == == == == == == == == == == ==
    == == == == == == == == == == == == == == == == fig =
    figure('Name', 'PSO Convergence of Cd/Cl ratio', 'NumberTitle', 'off');

% ============================================================
% Main PSO loop
% ============================================================
for j = 1:MaxIter
    for i = 1:nPop
        % Velocity update
        x(i).velocity = w*x(i).velocity ...
            + c1*rand(1,nVar).*(x(i).best.position - x(i).position) ...
            + c2*rand(1,nVar).*(global_best.position - x(i).position);

% Position update x(i).position = x(i).position + x(i).velocity;

% Clamp to bounds x(i).position = max(x(i).position, VarMin);
x(i).position = min(x(i).position, VarMax);

% Evaluate[x(i).fitness, x(i).cl, x(i).cd] = objective_function(x(i).position);

% Personal best update if x (i).fitness <
    x(i).best.fitness x(i).best.position = x(i).position;
x(i).best.fitness = x(i).fitness;
x(i).best.cl = x(i).cl;
x(i).best.cd = x(i).cd;

% Global best update if x (i).best.fitness < global_best.fitness global_best =
    x(i).best;
end end end

    % Inertia damping w = w * d;

% Save histories B(j) = global_best.fitness;
C(j, :) = global_best.position;
CL(j) = global_best.cl;
CD(j) = global_best.cd;

disp(['Iteration ' num2str(j)... ': Best fitness = ' num2str(
    B(j))... '; Best CL = ' num2str(CL(j))... '; Best CD = ' num2str(CD(j))]);

% -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --%
    Plot(same style as your desired output) %
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --subplot(
        2, 1, 1);
plot(1 : j, B(1 : j), 'r.-', 'LineWidth', 1);
grid on;
xlabel('Iteration');
ylabel('Cd/Cl ratio');
title('PSO Convergence of Cd/Cl ratio');

subplot(2, 1, 2);
yyaxis left;
plot(1 : j, CL(1 : j), 'b.-', 'LineWidth', 1);
ylabel('Best $C_L$', 'Interpreter', 'latex');

yyaxis right;
plot(1 : j, CD(1 : j), 'k.-', 'LineWidth', 1);
ylabel('Best $C_D$', 'Interpreter', 'latex');

grid on;
xlabel('Iteration');
title('Best $C_L$ and Best $C_D$ vs Iteration', 'Interpreter', 'latex');

drawnow;
end

        %
    == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == == % Save results to MAT file % == == == == == == == == == == ==
    == == == == == == == == == == == == == == == == == == ==
    results.bestFitnessHistory = B;
results.bestPositionHistory = C;
results.bestCLHistory = CL;
results.bestCDHistory = CD;
results.global_best = global_best;

results.PSO.nVar = nVar;
results.PSO.VarMin = VarMin;
results.PSO.VarMax = VarMax;
results.PSO.MaxIter = MaxIter;
results.PSO.nPop = nPop;
results.PSO.w0 = w0;
results.PSO.d = d;
results.PSO.c1 = c1;
results.PSO.c2 = c2;

save('PSO_XFOIL_Results.mat', 'results');
fprintf('Saved results to PSO_XFOIL_Results.mat\n');

% Optional: save plot for Overleaf
saveas(fig,'ConvergencePlot.png');

% == == == == == == == == == == == == == == == == == == == == == == == == == ==
    == == == == % Objective function(CD / CL) with guards % == == == == == == ==
    == == == == == == == == == == == == == == == == == == == == == ==
    == function[f, cl, cd] = objective_function(x)

    cl = NaN;
cd = NaN;

% Geometry validity checks wu = [ x(1), x(2), x(3) ];
wl = [ x(4), x(5), x(6) ];

if any (wu <= wl)
  f = 100;
% penalty return;
end

    % Minimum thickness check(10 % chord) N_check = 100;
dz = 0;
coord = CST_airfoil(wl, wu, dz, N_check);
y_coord = coord( :, 2);

max_t = 0;
    for
      k = 1 : 50 t_k = y_coord(102 - k) - y_coord(k);
    if t_k
      > max_t max_t = t_k;
    end end if max_t < 0.10 f = 100;
    return;
    end

        % XFOIL call res = xfoil(x);
    cl = res(1);
    cd = res(2);

    % Guards CL_min = 0.05;
    CD_min = 1e-4;
    CL_max = 2.5;
    CD_max = 1.0;

    if any (~isfinite([cl cd]))
      f = 100;
    return;
    end

        if cd > 1000 f = cd;
    return;
    end

        if (cl < CL_min) ||
        (cl > CL_max) || (cd < CD_min) || (cd > CD_max) f = 100;
    return;
    end

        % Objective f = cd / cl;
    end
