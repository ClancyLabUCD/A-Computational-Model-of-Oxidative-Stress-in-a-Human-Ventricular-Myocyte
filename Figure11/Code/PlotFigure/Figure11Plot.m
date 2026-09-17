%% Figure11Plot.m
%
%   (1) Post-pause trace figure across DOX/IKr block conditions
%       (V, Cai, Cam, ROSi - one column per condition)
%   (2) Post-pause APD90 summary table (recomputed from V traces)


clear, clc, close all

%% =========================================================
%  SETTINGS - edit here only
%% =========================================================
post_pause_start = 1500;   % ms - pre_pause_ms + pause_ms (anchor for both
                           % the trace window and the post-pause APD90 window)
t_end = 2500;              % ms - end of trace plotting window
ds    = 50;                % plot every ds-th point (downsampling for speed)

%% =========================================================
%  Y-AXIS LIMITS - edit here only
%% =========================================================
ylim_V    = [-100 50];    ytick_V    = [-100 -50 0 50];
ylim_Cai  = [0 2];        ytick_Cai  = [0 1 2];
ylim_Cam  = [0.2 0.6];    ytick_Cam  = [0.2 0.4 0.6];
ylim_ROSi = [0 2.6];        ytick_ROSi = [0 1.3 2.6];

ylims       = {ylim_V,   ylim_Cai,   ylim_Cam,   ylim_ROSi};
yticks_list = {ytick_V,  ytick_Cai,  ytick_Cam,  ytick_ROSi};

%% =========================================================
%  FILES AND LABELS
%% =========================================================
files = {'outputs_pause_D0IKr0.mat', ...
         'outputs_pause_D1IKr0.mat', ...
         'outputs_pause_D1IKr30.mat', ...
         'outputs_pause_D1IKr40.mat', ...
         'outputs_pause_D0IKr40.mat'};

col_titles = {'No DOX, 0% IKr Block', 'DOX, 0% IKr Block', ...
              'DOX, 30% IKr Block', 'DOX, 40% IKr Block', ...
              'No DOX, 40% IKr Block'};

labels = col_titles;   % same condition labels used for the APD90 table

N_cols = length(files);

%% =========================================================
%  COLORS
%% =========================================================
c_V    = [0.4  0.4  0.4];
c_Cai  = [0.5  0.0  0.5];
c_Cam  = [0.85 0.1  0.5];
c_ROSi = [0.1  0.4  0.8];
alpha  = 0.5;

fields     = {'V_all', 'Cai_all', 'Cam_all', 'ROSi_all'};
colors     = {c_V, c_Cai, c_Cam, c_ROSi};
row_labels = {'V (mV)', '[Ca^{2+}]_i (\muM)', ...
              '[Ca^{2+}]_m (\muM)', 'ROS_i (\muM)'};

%% =========================================================
%  APD90 SUMMARY TABLE (printed first) + FIGURE (built in the same loop)
% =========================================================
fprintf('\nAPD90 Summary - Post-Pause Beat (recomputed from traces)\n');
fprintf('%-20s  %10s  %10s  %10s  %8s\n', ...
    'Condition', 'Mean (ms)', 'SD (ms)', 'Median (ms)', 'N cells');
fprintf('%s\n', repmat('-', 1, 65));

figure('Color', 'w', 'Position', [50 50 1800 900]);
set(0, 'DefaultAxesFontName', 'Arial', 'DefaultAxesFontSize', 11);

for col = 1:N_cols
    if ~isfile(files{col})
        fprintf('%-20s  file not found\n', labels{col});
        fprintf('Skipping %s - file not found\n', files{col});
        continue
    end

    % Load each file ONCE - used for both the APD90 table and the figure
    d = load(files{col}, 'V_all', 'Cai_all', 'Cam_all', 'ROSi_all', 't_grid');
    t = d.t_grid;

    % -----------------------------------------------------
    % (1) APD90 summary for this condition
    % -----------------------------------------------------
    post_mask = t >= post_pause_start;
    t_pp      = t(post_mask) - post_pause_start;   % reset to 0
    V_pp      = d.V_all(:, post_mask);

    N_trials  = size(V_pp, 1);
    APD90_pp  = nan(N_trials, 1);

    for ii = 1:N_trials
        v = V_pp(ii, :)';
        if all(isnan(v)), continue, end

        [~, i_peak] = max(v);
        RMP         = min(v);
        Amplitude   = max(v) - RMP;
        thresh90    = RMP + 0.10 * Amplitude;

        v_post = v(i_peak:end);
        t_post = t_pp(i_peak:end);

        idx90 = find(v_post <= thresh90, 1, 'first');
        if ~isempty(idx90) && idx90 > 1
            t1 = t_post(idx90-1); v1 = v_post(idx90-1);
            t2 = t_post(idx90);   v2 = v_post(idx90);
            t_cross      = t1 + (thresh90-v1)*(t2-t1)/(v2-v1);
            APD90_pp(ii) = t_cross - t_pp(i_peak);
        end
    end

    valid      = ~isnan(APD90_pp);
    apd_valid  = APD90_pp(valid);
    fprintf('%-20s  %10.1f  %10.1f  %10.1f  %8d\n', ...
        labels{col}, mean(apd_valid), std(apd_valid), ...
        median(apd_valid), sum(valid));

    % -----------------------------------------------------
    % (2) Trace figure for this condition (one column, 4 rows)
    % -----------------------------------------------------
    t_mask = t >= post_pause_start & t <= t_end;
    t_plot = t(t_mask) - post_pause_start;

    ok  = ~all(isnan(d.V_all), 2);
    idx = find(ok)';
    fprintf('  (%d valid trials for trace plot)\n', sum(ok));

    for row = 1:4
        subplot(4, N_cols, (row-1)*N_cols + col);
        hold on;

        mat = d.(fields{row});
        c   = colors{row};

        for ii = idx
            trace = mat(ii, t_mask);
            if ~all(isnan(trace))
                plot(t_plot(1:ds:end), trace(1:ds:end), 'Color', [c, alpha], 'LineWidth', 0.5);
            end
        end

        hold off;
        ylim(ylims{row});
        set(gca, 'YTick', yticks_list{row});
        set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11);
        set(gca, 'XTick', [0 500 1000]);

        if row == 1
            title(col_titles{col}, 'FontSize', 11, 'FontWeight', 'bold');
        end

        if col == 1
            ylabel(row_labels{row});
        end

        if row == 4
            xlabel('Time (ms)');
        else
            set(gca, 'XTickLabel', []);
        end
    end
end

fprintf('\n');
