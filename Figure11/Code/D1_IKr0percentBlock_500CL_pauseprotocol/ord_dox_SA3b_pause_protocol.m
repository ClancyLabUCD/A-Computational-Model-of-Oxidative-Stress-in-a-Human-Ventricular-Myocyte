% ord_dox_SA3b_pause_protocol.m
% Pause protocol: SS beats → pause → 1 post-pause beat
% Detects EADs and saves traces with downsampling
clear, clc, close all

%% =========================================================
%  SETTINGS — edit here only
%% =========================================================
extra_ms     = 1000;   % extra recording time after post-pause beat (ms)
pre_pause_ms = 500;    % recording time before pause (ms)
pause_ms     = 1000;   % pause duration (ms) — must match ord_dox_euler_step
ds           = 10;     % downsample factor (save every ds-th point)

%% =========================================================
load('parameter_ord_dox_pop.mat', 'all_parameters', 'param_names', 'p_fixed');
load('ICs_ord_dox_pop.mat',       'SS_flags', 'n_beats_SS', 'D');
[N_trials, ~] = size(all_parameters);

CL_ms       = p_fixed(104);
dt          = 0.01;
n_beats_out = 1;

% Full and downsampled step counts
n_steps_full = round((pre_pause_ms + pause_ms + CL_ms + extra_ms) / dt);
n_steps_ds   = floor(n_steps_full / ds);
t_grid       = (0:n_steps_ds-1)' * dt * ds;

%% =========================================================
%  INITIALIZE OUTPUT ARRAYS
%% =========================================================
all_APD90     = nan(N_trials, 1);
all_Peak_Cai  = nan(N_trials, 1);
all_Diast_Cai = nan(N_trials, 1);
all_EAD_flag  = zeros(N_trials, 1);
V_all         = nan(N_trials, n_steps_ds);
Cai_all       = nan(N_trials, n_steps_ds);
Cam_all       = nan(N_trials, n_steps_ds);
ROSi_all      = nan(N_trials, n_steps_ds);
ICaL_all      = nan(N_trials, n_steps_ds);

fprintf('Running pause protocol for %d trials...\n', N_trials);
tic

for ii = 1:N_trials
    if SS_flags(ii) ~= 0
        fprintf('  Trial %d skipped (SS flag)\n', ii);
        continue
    end

    sc = all_parameters(ii, :);
    try
        [~, ~, t_beat, V_trace, Cai_trace, Psi_trace, Cam_trace, ROSi_trace, ICaL_trace] = ...
            ord_dox_euler_step(sc, n_beats_SS, n_beats_out, D);

 if length(t_beat) > 100

    % --- Isolate ONLY the post-pause beat (excludes the pre-pause
    % beat and the pause itself) ---
    post_pause_start = pre_pause_ms + pause_ms;
    idx_post = find(t_beat >= post_pause_start, 1, 'first');

    V_seg = V_trace(idx_post:end);
    t_seg = t_beat(idx_post:end);

    % --- EAD detection (operates only on the isolated post-pause beat) ---
    [~, i_peak] = max(V_seg);
    [RMP, ~]    = min(V_seg);
    ead_amp_threshold = 2.0;   % mV - minimum secondary rise to count as an EAD

    search   = i_peak:length(V_seg);
    v_search = V_seg(search);

    is_min = islocalmin(v_search);
    is_max = islocalmax(v_search);

    min_idx = find(is_min);
    max_idx = find(is_max);

    EAD_flag = false;
    for m = 1:length(min_idx)
        next_max = max_idx(max_idx > min_idx(m));
        if ~isempty(next_max)
            rise = v_search(next_max(1)) - v_search(min_idx(m));
            if rise >= ead_amp_threshold && v_search(min_idx(m)) > RMP + 10
                EAD_flag = true;
                break
            end
        end
    end

    all_EAD_flag(ii) = EAD_flag;

    % --- APD90 (isolated to the post-pause beat) ---
    Amplitude = max(V_seg) - RMP;
    thresh90  = RMP + 0.10 * Amplitude;
    v_post    = V_seg(i_peak:end);
    t_post    = t_seg(i_peak:end);
    idx90     = find(v_post <= thresh90, 1, 'first');
    if ~isempty(idx90) && idx90 > 1
        t1 = t_post(idx90-1); v1 = v_post(idx90-1);
        t2 = t_post(idx90);   v2 = v_post(idx90);
        t_cross = t1 + (thresh90-v1)*(t2-t1)/(v2-v1);
        all_APD90(ii) = t_cross - t_seg(i_peak);
    end

    % --- Calcium scalars  ---
    all_Peak_Cai(ii)  = max(Cai_trace) * 1000;
    all_Diast_Cai(ii) = min(Cai_trace) * 1000;

    % --- Save downsampled traces ---
    n_full = min(length(V_trace), n_steps_full);
    n_ds   = floor(n_full / ds);

    V_all(ii, 1:n_ds)    = V_trace(1:ds:n_full);
    Cai_all(ii, 1:n_ds)  = Cai_trace(1:ds:n_full)  * 1000;
    Cam_all(ii, 1:n_ds)  = Cam_trace(1:ds:n_full)  * 1000;
    ROSi_all(ii, 1:n_ds) = ROSi_trace(1:ds:n_full) * 1000;
    ICaL_all(ii, 1:n_ds) = ICaL_trace(1:ds:n_full);
end

    catch ME
        fprintf('  Trial %d error: %s\n', ii, ME.message);
    end

    fprintf('  Trial %d / %d done\n', ii, N_trials);
end
toc

n_EAD = sum(all_EAD_flag);
fprintf('\nEADs detected in %d / %d cells (%.1f%%)\n', ...
    n_EAD, sum(SS_flags==0), 100*n_EAD/max(sum(SS_flags==0),1));

save('outputs_pause_D1Ikr0.mat', ...
    'all_APD90', 'all_Peak_Cai', 'all_Diast_Cai', 'all_EAD_flag', ...
    'V_all', 'Cai_all', 'Cam_all', 'ROSi_all', 'ICaL_all', 't_grid', '-v7.3');
fprintf('Saved outputs_pause.mat\n');

