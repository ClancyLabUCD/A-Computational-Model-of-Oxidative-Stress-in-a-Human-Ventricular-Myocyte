%% Figure9Plot.m
%  DOX (doxorubicin) severity dose-response and experimental validation.
%  Generates TWO figures from one script -- combined for manuscript figure
%
%  Figure 1 - Dose-response across DOX severity (D = 0 to 1.0):
%    Panel A: Peak [Ca2+]i
%    Panel B: Peak [Ca2+]m
%    Panel C: Peak ROSi
%    Panel D: Min membrane potential (Psi)
%    Panel E: APD90
%
%  Figure 2 - Experimental validation:
%    Panel A: %deltaAPD90 (0.5 Hz, D=0->D=1) vs Wang & Korth, 1995
%    Panel B: %deltaAPD80 (1 Hz, D=0->D=1) vs George et al., 2026


clear; clc; close all

%% =========================================================
%  DOX SEVERITY AXIS
% =========================================================
D_vals = [0, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0];
xl_lab = {'0','0.5','0.6','0.7','','0.8','0.9','1.0'};

%% =========================================================
%  COLORS
% =========================================================
col_Cai  = [0.5  0.0  0.5 ; 0.65 0.25 0.65; 0.8  0.5  0.8 ];  % purple:  1000/750/500
col_Cam  = [0.85 0.1  0.5 ; 0.92 0.4  0.68; 0.97 0.70 0.85];  % magenta: 1000/750/500
col_ROSi = [0.1  0.4  0.8 ; 0.35 0.58 0.88; 0.6  0.75 0.95];  % blue:    1000/750/500
col_Psi  = [0.1  0.55 0.1 ; 0.35 0.72 0.35; 0.6  0.85 0.6 ];  % green:   1000/750/500
col_APD  = [0.3  0.3  0.3 ; 0.48 0.48 0.48; 0.65 0.65 0.65];  % grey:    1000/750/500

lw = 3;
ms = 8;

%% =========================================================
%  LOAD SIMULATION DATA (each file loaded exactly once)
% =========================================================
% 1000ms CL (1 Hz) - used in Fig 1 (panels A-E) AND Fig 2 panel B (APD80)
d1000 = load_dox_series("output_1000CL_D%s.txt");

% 750ms CL (1.33 Hz) - Fig 1 only
d750  = load_dox_series("output_750CL_D%s.txt");

% 500ms CL (2 Hz) - Fig 1 only
d500  = load_dox_series("output_500CL_D%s.txt");


%% =========================================================
%  FIGURE 1: DOSE-RESPONSE ACROSS DOX SEVERITY
% =========================================================
figure('Color','w','Position',[50 50 1300 980]);

panel_dose_response(1, D_vals, xl_lab, ...
    {buildvec(d1000,'cai_peak'), buildvec(d750,'cai_peak'), buildvec(d500,'cai_peak')}, ...
    col_Cai, lw, ms, 'Peak [Ca^{2+}]_i (\muM)', [0 2.2], [0 1.1 2.2]);

panel_dose_response(2, D_vals, xl_lab, ...
    {buildvec(d1000,'Cam_peak'), buildvec(d750,'Cam_peak'), buildvec(d500,'Cam_peak')}, ...
    col_Cam, lw, ms, 'Peak [Ca^{2+}]_m (\muM)', [0.1 0.7], [0.1 0.4 0.7]);

panel_dose_response(3, D_vals, xl_lab, ...
    {buildvec(d1000,'ROSi_peak'), buildvec(d750,'ROSi_peak'), buildvec(d500,'ROSi_peak')}, ...
    col_ROSi, lw, ms, 'Peak ROS_i (\muM)', [0 1.7], [0 0.85 1.7]);

panel_dose_response(4, D_vals, xl_lab, ...
    {buildvec(d1000,'Psi_min'), buildvec(d750,'Psi_min'), buildvec(d500,'Psi_min')}, ...
    col_Psi, lw, ms, 'Min \Psi (mV)', [175 189], [175 182 189]);

panel_dose_response(5, D_vals, xl_lab, ...
    {buildvec(d1000,'APD'), buildvec(d750,'APD'), buildvec(d500,'APD')}, ...
    col_APD, lw, ms, 'APD_{90} (ms)', [230 340], [230 285 340]);

% =========================================================
% EXPERIMENTAL VALIDATION
% =========================================================
% --- Percent change, D=0 -> D=1, from simulation ---
pct_APD80 = 100 * (d1000.max.APD80  - d1000.ctrl.APD80)  / d1000.ctrl.APD80;

% --- Experimental comparison values ---

% -----------------------------
% Panel 6 (revised): APD80 percent change validation
% Simulation (D=0 -> D=1, single bar) vs. experimental data across
% 4 DOX concentrations (human ventricular slices), each its own bar/color
% -----------------------------

% --- Simulation value (already computed above) ---
% pct_APD80 = 100 * (d1000.max.APD80 - d1000.ctrl.APD80) / d1000.ctrl.APD80;

% --- Experimental values across DOX concentrations ---
dox_conc      = [0.5, 1, 5, 10];      % uM
exp_means     = [3,   2, 13, 6];       % % APD80 change
exp_sems      = [8,  20, 15, 17];      % SEM

col_sim  = [0.3  0.3  0.3 ];   % dark grey - simulation
col_dose = [0.75 0.85 0.95;    % 0.5 uM - lightest blue
            0.55 0.70 0.88;    % 1 uM
            0.30 0.50 0.78;    % 5 uM
            0.10 0.28 0.60];   % 10 uM - darkest blue

subplot(4, 2, 6); hold on;

% Simulation bar (single bar, far left)
x_sim = 1;
bar(x_sim, pct_APD80, 0.6, 'FaceColor', col_sim, 'EdgeColor', 'none');

% Experimental bars (grouped, touching, one per dose)
% Store bar handles so we can build a legend from them afterward
x_exp = [2, 3, 4, 5];
exp_bar_width = 0.6;   % touching - no gap between adjacent dose bars
b_exp = gobjects(1, length(dox_conc));
for k = 1:length(dox_conc)
    b_exp(k) = bar(x_exp(k), exp_means(k), exp_bar_width, ...
        'FaceColor', col_dose(k,:), 'EdgeColor', 'none');
    errorbar(x_exp(k), exp_means(k), 0, exp_sems(k), 'k', 'LineWidth', 1.5, 'CapSize', 6);
end

ylabel('%\DeltaAPD_{80}', 'FontSize', 12);
ylim([0 30]);
yticks([0 15 30])
yline(0, 'k-', 'LineWidth', 0.75);

xlim([0.3 5.7]);
% Single centered label under the experimental group, instead of one
% label per dose bar
xticks([x_sim, mean(x_exp)]);
xticklabels({'Simulation', 'George et al., 2026'});
xtickangle(0);

% Legend mapping each color to its DOX concentration
legend(b_exp, {'0.5\muM', '1\muM', '5\muM', '10\muM'}, ...
    'Location', 'north', 'Box', 'off', 'FontSize', 8, 'Orientation', 'vertical');

box off;
set(gca, 'TickDir', 'out', 'LineWidth', 1.0);

%% =========================================================
%  LOCAL FUNCTIONS
% =========================================================

function d = load_dox_series(filename_pattern)
    % Loads the 8-point DOX effect series (D = 0, 0.5, 0.6, 0.7, 0.75,
    % 0.8, 0.9, 1.0) for one pacing rate, given a filename pattern with a
    % single %s placeholder for the D-value suffix, e.g.
    % "output3_HZ_1Hz_D%s.txt".
    d.ctrl = extract_SS(readmatrix(sprintf(filename_pattern, '0')));
    d.d05  = extract_SS(readmatrix(sprintf(filename_pattern, '05')));
    d.d06  = extract_SS(readmatrix(sprintf(filename_pattern, '06')));
    d.d07  = extract_SS(readmatrix(sprintf(filename_pattern, '07')));
    d.d075 = extract_SS(readmatrix(sprintf(filename_pattern, '75')));
    d.d08  = extract_SS(readmatrix(sprintf(filename_pattern, '08')));
    d.d09  = extract_SS(readmatrix(sprintf(filename_pattern, '09')));
    d.max  = extract_SS(readmatrix(sprintf(filename_pattern, '1')));
end

function s = extract_SS(data)
    % Extracts steady-state scalar summaries (peak/diastolic Cai, Cam,
    % ROSi, Psi, APD90, APD80) from the final beat of a DOX effect run.
    t    = data(:,1);
    CL   = t(end) - t(1);
    half = t(end) - CL/2;
    idx  = t >= half;

    s.t    = t(idx) - t(find(idx,1));
    s.v    = data(idx, 2);
    s.cai  = data(idx, 3)  * 1000;
    s.Cam  = data(idx, 33) * 1000;
    s.Psi  = data(idx, 31);
    s.ROSi = data(idx, 27) * 1000;

    % APD90 from pre-computed column
    apd_col = data(:, 26);
    apd_col = apd_col(apd_col > 0);
    s.APD   = apd_col(end);

    % APD80: compute directly from the voltage trace in this beat
    vt    = s.v;
    tt    = s.t;
    vpeak = max(vt);
    vrest = min(vt);
    v80   = vrest + 0.20 * (vpeak - vrest);   % 80% repolarization level

    up_idx = find(vt >= v80, 1, 'first');           % upstroke crossing
    [~, pk_idx] = max(vt);
    down_search = vt(pk_idx:end);
    rel_idx     = find(down_search <= v80, 1, 'first');  % repol. crossing

    if ~isempty(up_idx) && ~isempty(rel_idx)
        down_idx = pk_idx + rel_idx - 1;
        s.APD80  = tt(down_idx) - tt(up_idx);
    else
        s.APD80  = NaN;
    end

    % Scalar peak/diastolic summaries
    s.cai_diast  = min(s.cai);
    s.cai_peak   = max(s.cai);
    s.Cam_diast  = min(s.Cam);
    s.Cam_peak   = max(s.Cam);
    s.Psi_min    = min(s.Psi);
    s.Psi_max    = max(s.Psi);
    s.ROSi_diast = min(s.ROSi);
    s.ROSi_peak  = max(s.ROSi);
end

function v = buildvec(d, field)
    % Assembles the 8-point DOX effect vector for one field, in D_vals
    % order (D = 0, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0).
    v = [d.ctrl.(field), d.d05.(field), d.d06.(field), d.d07.(field), ...
         d.d075.(field), d.d08.(field), d.d09.(field), d.max.(field)];
end

function panel_dose_response(panel_idx, D_vals, xl_lab, series, colors, lw, ms, ylab, ylims, yt)
    % Plots one dose-response panel (three pacing rates: 1000/750/500ms)
    % into subplot(4,2,panel_idx).
    subplot(4,2,panel_idx); hold on
    plot(D_vals, series{1}, '-o', 'Color', colors(1,:), 'MarkerFaceColor', colors(1,:), 'LineWidth', lw, 'MarkerSize', ms)
    plot(D_vals, series{2}, '-o', 'Color', colors(2,:), 'MarkerFaceColor', colors(2,:), 'LineWidth', lw, 'MarkerSize', ms)
    plot(D_vals, series{3}, '-o', 'Color', colors(3,:), 'MarkerFaceColor', colors(3,:), 'LineWidth', lw, 'MarkerSize', ms)
    ylabel(ylab, 'FontSize', 12)
    ylim(ylims); yticks(yt)
    xlabel('DOX Effect (D)', 'FontSize', 12)
    xticks([0 0.5 0.6 0.7 0.75 0.8 0.9 1.0]); 
    %xticklabels({});
    xticklabels({'0','0.5','','','0.75','','','1.0'}); 
    xlim([-0.05 1.05])
    legend({'1000ms','750ms','500ms'}, 'Location', 'northwest', 'FontSize', 10, 'Box', 'off')
    box off
end

function panel_validation(panel_idx, sim_pct, exp_mean, exp_sem, col_sim, col_exp, ylab, exp_label)
    % Plots one two-bar validation panel (simulation vs. experimental
    % value with error bar) into subplot(4,2,panel_idx).
    subplot(4, 2, panel_idx); hold on;
    bar(1, sim_pct,  0.6, 'FaceColor', col_sim, 'EdgeColor', 'none');
    bar(2, exp_mean, 0.6, 'FaceColor', col_exp, 'EdgeColor', 'none');
    errorbar(2, exp_mean, exp_sem, 'k', 'LineWidth', 1.5, 'CapSize', 6);

    ylabel(ylab, 'FontSize', 12);
    ylim([0 50]);
    yticks([0 25 50]);
    xlim([0.3 2.7]);
    xticks([1 2]);
    xticklabels({'Simulation', exp_label});
    xtickangle(15);
    box off;
    set(gca, 'TickDir', 'out', 'LineWidth', 1.0);
end


