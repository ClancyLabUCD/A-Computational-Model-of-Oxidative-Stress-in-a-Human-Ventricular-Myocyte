%% Compare baseline vs high ROS across cycle lengths
clear; clc; close all;

%% -----------------------------
% Load files
% -----------------------------
% 2000 CL
data_05Hz_base     = load('output_2000CL_base.txt');
data_05Hz_high      = load('output_2000CL_500.txt');
data_05Hz_high_200 = load('output_2000CL_200.txt');

% 1000 CL
data_1Hz_base     = load('output_1000CL_base.txt');
data_1Hz_high      = load('output_1000CL_500.txt');
data_1Hz_high_200 = load('output_1000CL_200.txt');

% 750 ms CL
data_15Hz_base     = load('output_750CL_base.txt');
data_15Hz_high      = load('output_750CL_500.txt');
data_15Hz_high_200 = load('output_750CL_200.txt');

% 500 CL
data_2Hz_base     = load('output_500CL_base.txt');
data_2Hz_high      = load('output_500CL_500.txt');
data_2Hz_high_200 = load('output_500CL_200.txt');

%% -----------------------------
% Assign variables
% Columns:
% 1 t
% 2 v
% 3 cai
% 4 ICaL
% 5 INaL
% 6 ROSi
% 7 APD
% -----------------------------

% ===== 0.5 Hz =====
t_05Hz_base   = data_05Hz_base(:,1);
v_05Hz_base   = data_05Hz_base(:,2);
cai_05Hz_base = data_05Hz_base(:,3) * 1000;   % mM -> µM

t_05Hz_high   = data_05Hz_high(:,1);
cai_05Hz_high = data_05Hz_high(:,3) * 1000;

t_05Hz_high_200 = data_05Hz_high_200(:,1);
v_05Hz_high_200 = data_05Hz_high_200(:,2);

% ===== 1 Hz =====
t_1Hz_base   = data_1Hz_base(:,1);
v_1Hz_base   = data_1Hz_base(:,2);
cai_1Hz_base = data_1Hz_base(:,3) * 1000;

t_1Hz_high   = data_1Hz_high(:,1);
cai_1Hz_high = data_1Hz_high(:,3) * 1000;

t_1Hz_high_200 = data_1Hz_high_200(:,1);
v_1Hz_high_200 = data_1Hz_high_200(:,2);

% ===== 1.5 Hz =====
t_15Hz_base   = data_15Hz_base(:,1);
v_15Hz_base   = data_15Hz_base(:,2);
cai_15Hz_base = data_15Hz_base(:,3) * 1000;

t_15Hz_high   = data_15Hz_high(:,1);
cai_15Hz_high = data_15Hz_high(:,3) * 1000;

t_15Hz_high_200 = data_15Hz_high_200(:,1);
v_15Hz_high_200 = data_15Hz_high_200(:,2);

% ===== 2 Hz =====
t_2Hz_base   = data_2Hz_base(:,1);
v_2Hz_base   = data_2Hz_base(:,2);
cai_2Hz_base = data_2Hz_base(:,3) * 1000;

t_2Hz_high   = data_2Hz_high(:,1);
cai_2Hz_high = data_2Hz_high(:,3) * 1000;

t_2Hz_high_200 = data_2Hz_high_200(:,1);
v_2Hz_high_200 = data_2Hz_high_200(:,2);

%% -----------------------------
% Calculate APD50 and basal/diastolic Cai percent increase for each CL
% -----------------------------

% Beat windows (first beat)
win_05 = [0 2000];
win_1  = [0 1000];
win_15 = [0 667];
win_2  = [0 500];

% ===== 0.5 Hz =====
idx_05_base     = t_05Hz_base     >= win_05(1) & t_05Hz_base     <= win_05(2);
idx_05_high     = t_05Hz_high     >= win_05(1) & t_05Hz_high     <= win_05(2);
idx_05_high_200 = t_05Hz_high_200 >= win_05(1) & t_05Hz_high_200 <= win_05(2);

APD50_05_base     = calc_APD50(t_05Hz_base(idx_05_base), v_05Hz_base(idx_05_base));
APD50_05_high_200 = calc_APD50(t_05Hz_high_200(idx_05_high_200), v_05Hz_high_200(idx_05_high_200));
APD50_pct_05Hz     = 100 * (APD50_05_high_200 - APD50_05_base) / APD50_05_base;

basalCai_05_base   = min(cai_05Hz_base(idx_05_base));
basalCai_05_high   = min(cai_05Hz_high(idx_05_high));
basalCai_pct_05Hz  = 100 * (basalCai_05_high - basalCai_05_base) / basalCai_05_base;

% ===== 1 Hz =====
idx_1_base     = t_1Hz_base     >= win_1(1) & t_1Hz_base     <= win_1(2);
idx_1_high     = t_1Hz_high     >= win_1(1) & t_1Hz_high     <= win_1(2);
idx_1_high_200 = t_1Hz_high_200 >= win_1(1) & t_1Hz_high_200 <= win_1(2);

APD50_1_base     = calc_APD50(t_1Hz_base(idx_1_base), v_1Hz_base(idx_1_base));
APD50_1_high_200 = calc_APD50(t_1Hz_high_200(idx_1_high_200), v_1Hz_high_200(idx_1_high_200));
APD50_pct_1Hz     = 100 * (APD50_1_high_200 - APD50_1_base) / APD50_1_base;

basalCai_1_base   = min(cai_1Hz_base(idx_1_base));
basalCai_1_high   = min(cai_1Hz_high(idx_1_high));
basalCai_pct_1Hz  = 100 * (basalCai_1_high - basalCai_1_base) / basalCai_1_base;

% ===== 1.5 Hz =====
idx_15_base     = t_15Hz_base     >= win_15(1) & t_15Hz_base     <= win_15(2);
idx_15_high     = t_15Hz_high     >= win_15(1) & t_15Hz_high     <= win_15(2);
idx_15_high_200 = t_15Hz_high_200 >= win_15(1) & t_15Hz_high_200 <= win_15(2);

APD50_15_base     = calc_APD50(t_15Hz_base(idx_15_base), v_15Hz_base(idx_15_base));
APD50_15_high_200 = calc_APD50(t_15Hz_high_200(idx_15_high_200), v_15Hz_high_200(idx_15_high_200));
APD50_pct_15Hz     = 100 * (APD50_15_high_200 - APD50_15_base) / APD50_15_base;

basalCai_15_base   = min(cai_15Hz_base(idx_15_base));
basalCai_15_high   = min(cai_15Hz_high(idx_15_high));
basalCai_pct_15Hz  = 100 * (basalCai_15_high - basalCai_15_base) / basalCai_15_base;

% ===== 2 Hz =====
idx_2_base     = t_2Hz_base     >= win_2(1) & t_2Hz_base     <= win_2(2);
idx_2_high     = t_2Hz_high     >= win_2(1) & t_2Hz_high     <= win_2(2);
idx_2_high_200 = t_2Hz_high_200 >= win_2(1) & t_2Hz_high_200 <= win_2(2);

APD50_2_base     = calc_APD50(t_2Hz_base(idx_2_base), v_2Hz_base(idx_2_base));
APD50_2_high_200 = calc_APD50(t_2Hz_high_200(idx_2_high_200), v_2Hz_high_200(idx_2_high_200));
APD50_pct_2Hz     = 100 * (APD50_2_high_200 - APD50_2_base) / APD50_2_base;

basalCai_2_base   = min(cai_2Hz_base(idx_2_base));
basalCai_2_high   = min(cai_2Hz_high(idx_2_high));
basalCai_pct_2Hz  = 100 * (basalCai_2_high - basalCai_2_base) / basalCai_2_base;

%% -----------------------------
% Experimental comparison values
% -----------------------------

% --- Song et al., 2006: APD50 percent increase (200 uM H2O2) ---
APD50_ctl     = 204;
APD50_ctl_err = 15;
APD50_ros     = 280;
APD50_ros_err = 18;

APD50_percent_exp = 100 * (APD50_ros - APD50_ctl) / APD50_ctl;
APD50_percent_exp_err = 100 * sqrt( ...
    (APD50_ros_err / APD50_ctl)^2 + ...
    ((APD50_ros * APD50_ctl_err) / (APD50_ctl^2))^2 );

% --- Wang et al., 1999: diastolic/basal [Ca2+]i percent increase (0.5 mM H2O2) ---
diastolicCai_exp     = 52.8;
diastolicCai_exp_err = 4.7;

%% -----------------------------
% Print results
% -----------------------------

fprintf('\n===== APD50 percent increase =====\n');
fprintf('Experimental (Song et al., 2006): %.2f ± %.2f %%\n', APD50_percent_exp, APD50_percent_exp_err);
fprintf('Simulation:\n');
fprintf('  0.5 Hz: %.2f %%\n', APD50_pct_05Hz);
fprintf('  1.0 Hz: %.2f %%\n', APD50_pct_1Hz);
fprintf('  1.5 Hz: %.2f %%\n', APD50_pct_15Hz);
fprintf('  2.0 Hz: %.2f %%\n', APD50_pct_2Hz);

fprintf('\n===== Basal / Diastolic Cai percent increase =====\n');
fprintf('Simulation:\n');
fprintf('  0.5 Hz: %.2f %%\n', basalCai_pct_05Hz);
fprintf('  1.0 Hz: %.2f %%\n', basalCai_pct_1Hz);
fprintf('  1.5 Hz: %.2f %%\n', basalCai_pct_15Hz);
fprintf('  2.0 Hz: %.2f %%\n', basalCai_pct_2Hz);
fprintf('Experimental (Wang et al., 1999): %.2f ± %.2f %%\n', diastolicCai_exp, diastolicCai_exp_err);

%% -----------------------------
% Plot settings
% -----------------------------
set(groot, 'defaultLineLineWidth', 3)
set(groot, 'defaultAxesFontSize', 12)

% -----------------------------
% 2-panel figure: APD50 + Cai validation
% Simulation bars on the LEFT, experimental bar on the RIGHT
% -----------------------------
figure()
set(gcf,'color','w','Position',[100 100 900 350]);

% Colors
c_exp = [0.85 0.85 0.85];

% CL colors: darkest = 2000 ms, lightest = 500 ms
c_2000 = [0.25 0.00 0.35];
c_1000 = [0.45 0.10 0.55];
c_750  = [0.65 0.35 0.75];
c_500  = [0.80 0.60 0.90];

bar_width = 0.19;
x_sim = [1.0 1.2 1.4 1.6];   % simulation bars, left group
x_exp = 2.4;                  % experimental bar, right

% --------------------------------
% Panel A: APD50 validation
% --------------------------------
subplot(3,2,1), hold on, set(gca,'box','off','tickdir','out','fontsize',12)

% Simulation bars
b1 = bar(x_sim(1), APD50_pct_05Hz, bar_width, 'FaceColor', c_2000, 'EdgeColor', 'none');
b2 = bar(x_sim(2), APD50_pct_1Hz,  bar_width, 'FaceColor', c_1000, 'EdgeColor', 'none');
b3 = bar(x_sim(3), APD50_pct_15Hz, bar_width, 'FaceColor', c_750,  'EdgeColor', 'none');
b4 = bar(x_sim(4), APD50_pct_2Hz,  bar_width, 'FaceColor', c_500,  'EdgeColor', 'none');

% Experimental bar
bar(x_exp, APD50_percent_exp, 0.35, ...
    'FaceColor', c_exp, 'EdgeColor', 'none');
errorbar(x_exp, APD50_percent_exp, APD50_percent_exp_err, 'k', ...
    'LineStyle','none', 'LineWidth',1.5);

xlim([0.5 2.9])
xticks([1.3 2.4])
xticklabels({'Simulation','\itSong et al., 2006'})
yticks([0 30 60])
ylabel('APD50 increase from baseline (%)')

legend([b1 b2 b3 b4], ...
    {'2000 ms','1000 ms','750 ms','500 ms'}, ...
    'Box','off', 'Location','northeast', 'Orientation','vertical')

set(gca,'TickDir','out','LineWidth',1.5)

% --------------------------------
% Panel B: Cai validation (basal/diastolic)
% --------------------------------
subplot(3,2,2), hold on, set(gca,'box','off','tickdir','out','fontsize',12)

% Simulation bars
b1 = bar(x_sim(1), basalCai_pct_05Hz, bar_width, 'FaceColor', c_2000, 'EdgeColor', 'none');
b2 = bar(x_sim(2), basalCai_pct_1Hz,  bar_width, 'FaceColor', c_1000, 'EdgeColor', 'none');
b3 = bar(x_sim(3), basalCai_pct_15Hz, bar_width, 'FaceColor', c_750,  'EdgeColor', 'none');
b4 = bar(x_sim(4), basalCai_pct_2Hz,  bar_width, 'FaceColor', c_500,  'EdgeColor', 'none');

% Experimental bar
bar(x_exp, diastolicCai_exp, 0.35, ...
    'FaceColor', c_exp, 'EdgeColor', 'none');
errorbar(x_exp, diastolicCai_exp, diastolicCai_exp_err, 'k', ...
    'LineStyle','none', 'LineWidth',1.5);

xlim([0.5 2.9])
xticks([1.3 2.4])
xticklabels({'Simulation','\itWang et al., 1999'})
ylabel('Diastolic [Ca^{2+}]_i increase from baseline (%)')
ylim([0 72])
yticks([0 36 72])

set(gca,'TickDir','out','LineWidth',1.5)

subplot(3,2,3)
subplot(3,2,4)
subplot(3,2,5)
subplot(3,2,6)

%% -----------------------------
function APD50 = calc_APD50(t, v)
    % Compute APD50 from a single beat trace

    % Peak voltage and index
    [v_peak, idx_peak] = max(v);

    % Resting voltage before the peak
    v_rest = min(v(1:idx_peak));

    % 50% repolarization level
    v_50 = v_rest + 0.5 * (v_peak - v_rest);

    % Upstroke time: use max dV/dt before peak
    dvdt = diff(v) ./ diff(t);
    if idx_peak <= 2
        APD50 = NaN;
        return
    end
    [~, idx_up] = max(dvdt(1:idx_peak-1));
    t_up = t(idx_up);

    % Find first time after peak that crosses below v_50
    idx_repol_rel = find(v(idx_peak:end) <= v_50, 1, 'first');

    if isempty(idx_repol_rel)
        APD50 = NaN;
        return
    end

    idx_repol = idx_peak + idx_repol_rel - 1;
    t_repol = t(idx_repol);

    APD50 = t_repol - t_up;
end