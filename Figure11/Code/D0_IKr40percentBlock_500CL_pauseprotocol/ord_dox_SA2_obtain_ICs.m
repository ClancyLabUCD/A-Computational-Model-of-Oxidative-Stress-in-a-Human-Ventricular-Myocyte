am% ord_dox_SA2_obtain_ICs.m
% Runs each virtual cell to steady state using the exact Euler loop
% from HZ_DOX_FinalCode.m. Saves convergence flags.
%
% Requires: parameter_ord_dox_pop.mat, ord_dox_euler_step.m
% Output:   ICs_ord_dox_pop.mat
clear, clc, close all
global sa2_counter

load('parameter_ord_dox_pop.mat', 'all_parameters', 'param_names', 'p_fixed');
[N_trials, N_params] = size(all_parameters);
D          = p_fixed(102);
n_beats_SS = 10;
SS_flags   = zeros(N_trials, 1);

% Explicitly create pool before parfor
if isempty(gcp('nocreate'))
    try
        parpool('local', 3);
    catch
        parpool('local', 1);
    end
end

% Progress reporter (every 50 trials)
sa2_counter = 0;
q = parallel.pool.DataQueue;
afterEach(q, @(~) sa2_progress(N_trials));

fprintf('Running SS pacing for %d trials (%d beats each)...\n', N_trials, n_beats_SS);
tic
for ii = 1:N_trials
    sc = all_parameters(ii, :);
    try
        [v_end, cai_end, ~, ~, ~, ~, ~, ~, ~] = ord_dox_euler_step(sc, n_beats_SS, 1, D);
        if cai_end < 0
        SS_flags(ii) = 1;
        fprintf('Trial %d: cai NEGATIVE = %.6f\n', ii, cai_end);
      elseif cai_end > 5.0
        SS_flags(ii) = 1;
        fprintf('Trial %d: cai TOO HIGH = %.6f\n', ii, cai_end);
      elseif ~isfinite(v_end)
        SS_flags(ii) = 1;
        fprintf('Trial %d: v_end NOT FINITE = %.6f\n', ii, v_end);
end
    catch ME
    SS_flags(ii) = 1;
    fprintf('Trial %d error: %s\n', ii, ME.message);
    end
    send(q, ii);
end
fprintf('\n');
toc

fprintf('SS complete. %d / %d trials OK.\n', sum(SS_flags==0), N_trials);
save('ICs_ord_dox_pop.mat', 'SS_flags', 'n_beats_SS', 'D');

function sa2_progress(N_trials)
    global sa2_counter
    sa2_counter = sa2_counter + 1;
    if mod(sa2_counter, 50) == 0 || sa2_counter == N_trials
        fprintf('  %d / %d trials complete (%.0f%%)\n', ...
            sa2_counter, N_trials, 100*sa2_counter/N_trials);
    end
end
