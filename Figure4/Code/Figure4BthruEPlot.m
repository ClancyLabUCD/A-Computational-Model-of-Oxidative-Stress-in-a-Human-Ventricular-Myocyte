%% Figure: Percent change from baseline with increased Cai input
% Files:
% baseline: output_1000CL_100perCai.txt
% +30% Cai: output_1000CL_30perCai.txt
% +50% Cai: output3_1000CL_50perCai.txt

clear; clc;

% Load data
% Columns:
% 1 t
% 2 v
% 3 cai
% 4 Psi
% 5 Cam
% 6 J_ETC
% 7 ROSi

base = load('output_1000CL_100perCai.txt');
inc30 = load('output_1000CL_30perCai.txt');
inc50 = load('output3_1000CL_50perCai.txt');

% Baseline
t_base    = base(:,1);
v_base    = base(:,2);
cai_base  = base(:,3);
Psi_base  = base(:,4);
Cam_base  = base(:,5);
JETC_base = base(:,6);
ROSi_base = base(:,7);

% +30% Cai
t_30    = inc30(:,1);
v_30    = inc30(:,2);
cai_30  = inc30(:,3);
Psi_30  = inc30(:,4);
Cam_30  = inc30(:,5);
JETC_30 = inc30(:,6);
ROSi_30 = inc30(:,7);

% +50% Cai
t_50    = inc50(:,1);
v_50    = inc50(:,2);
cai_50  = inc50(:,3);
Psi_50  = inc50(:,4);
Cam_50  = inc50(:,5);
JETC_50 = inc50(:,6);
ROSi_50 = inc50(:,7);

%% Optional unit conversions (uncomment if needed)
% If concentrations are in mM and you want uM for interpretation only,
% you do NOT need to convert for percent-change calculations.
% Percent change is unit-independent as long as both numerator and denominator
% use the same units.

%% Percent change relative to baseline
% % change = 100 * (perturbed - baseline) ./ baseline

pct_cai_30  = 100 * (cai_30  - cai_base)  ./ cai_base;
pct_cai_50  = 100 * (cai_50  - cai_base)  ./ cai_base;

pct_Psi_30  = 100 * (Psi_30  - Psi_base)  ./ Psi_base;
pct_Psi_50  = 100 * (Psi_50  - Psi_base)  ./ Psi_base;

pct_Cam_30  = 100 * (Cam_30  - Cam_base)  ./ Cam_base;
pct_Cam_50  = 100 * (Cam_50  - Cam_base)  ./ Cam_base;

pct_JETC_30 = 100 * (JETC_30 - JETC_base) ./ JETC_base;
pct_JETC_50 = 100 * (JETC_50 - JETC_base) ./ JETC_base;

pct_ROSi_30 = 100 * (ROSi_30 - ROSi_base) ./ ROSi_base;
pct_ROSi_50 = 100 * (ROSi_50 - ROSi_base) ./ ROSi_base;


% Colors
color_cai  = [0.55 0.30 0.65];   % purple
color_Psi  = [0.20 0.60 0.25];   % green
color_Cam  = [0.78 0.25 0.45];   % dark pink
color_JETC = [0.88 0.47 0.12];   % orange
color_ROSi = [0.20 0.45 0.85];   % blue
color_zero = [0.75 0.75 0.75];   % light gray baseline

%% Figure
figure()
set(gcf,'color','w','Position',[100 100 1200 900]);
set(groot, 'defaultLineLineWidth', 3)
set(groot, 'defaultAxesFontSize', 12)

xmin = 0;
xmax = 500;

% Panel A: placeholder (same as panel B for now)
subplot(4,2,1), hold on, set(gca,'box','off','tickdir','out','fontsize',12)


% Panel B: % delta Cam


yline(0, '-', 'Color', color_zero, 'LineWidth', 2, 'HandleVisibility', 'off')
plot(t_30, pct_cai_30, '--', 'Color', color_cai, 'LineWidth', 3, 'DisplayName', '+37% [Ca^{2+}]_i')
plot(t_50, pct_cai_50, '-',  'Color', color_cai, 'LineWidth', 3, 'DisplayName', '+62% [Ca^{2+}]_i')

ylabel('%\Delta [Ca^{2+}]_i')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
legend('Location','northeast','Box','off')
xlim([xmin xmax])
xticks([xmin xmax])
%ylim([0 8])
%yticks([0 4 8])
%title('B', 'Units', 'normalized', 'Position', [-0.12 1.02 0])


subplot(4,2,3), hold on, set(gca,'box','off','tickdir','out','fontsize',12)
yline(0, '-', 'Color', color_zero, 'LineWidth', 2, 'HandleVisibility', 'off')
plot(t_30, pct_Psi_30, '--', 'Color', color_Psi, 'LineWidth', 3, 'DisplayName', '+37% [Ca^{2+}]_i')
plot(t_50, pct_Psi_50, '-',  'Color', color_Psi, 'LineWidth', 3, 'DisplayName', '+62% [Ca^{2+}]_i')

ylabel('%\Delta (\Delta\Psi)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([xmin xmax])
ylim([-0.8,0.4])
xticks([xmin xmax])
yticks([-0.8 -0.2 0.4])
%title('C', 'Units', 'normalized', 'Position', [-0.12 1.02 0])
legend('Location','northeast','Box','off')



subplot(4,2,2), hold on, set(gca,'box','off','tickdir','out','fontsize',12)
yline(0, '-', 'Color', color_zero, 'LineWidth', 2, 'HandleVisibility', 'off')
plot(t_30, pct_Cam_30, '--', 'Color', color_Cam, 'LineWidth', 3, 'DisplayName', '+37% [Ca^{2+}]_i')
plot(t_50, pct_Cam_50, '-',  'Color', color_Cam, 'LineWidth', 3, 'DisplayName', '+62% [Ca^{2+}]_i')

ylabel('%\Delta [Ca^{2+}]_m')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([xmin xmax])
ylim([0 8])
yticks([0 4 8])
xticks([xmin xmax])
%title('D', 'Units', 'normalized', 'Position', [-0.12 1.02 0])
legend('Location','northeast','Box','off')



subplot(4,2,4), hold on, set(gca,'box','off','tickdir','out','fontsize',12)
yline(0, '-', 'Color', color_zero, 'LineWidth', 2, 'HandleVisibility', 'off')
plot(t_30, pct_JETC_30, '--', 'Color', color_JETC, 'LineWidth', 3, 'DisplayName', '+37% [Ca^{2+}]_i')
plot(t_50, pct_JETC_50, '-',  'Color', color_JETC, 'LineWidth', 3, 'DisplayName', '+62% [Ca^{2+}]_i')

ylabel('%\Delta J_{ETC}')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([xmin xmax])
ylim([-10 30])
yticks([-10 10 30])
xticks([xmin xmax])
%title('E', 'Units', 'normalized', 'Position', [-0.12 1.02 0])
legend('Location','northeast','Box','off')



subplot(4,2,5), hold on, set(gca,'box','off','tickdir','out','fontsize',12)
yline(0, '-', 'Color', color_zero, 'LineWidth', 2, 'HandleVisibility', 'off')
plot(t_30, pct_ROSi_30, '--', 'Color', color_ROSi, 'LineWidth', 3, 'DisplayName', '+37% [Ca^{2+}]_i')
plot(t_50, pct_ROSi_50, '-',  'Color', color_ROSi, 'LineWidth', 3, 'DisplayName', '+62% [Ca^{2+}]_i')

ylabel('%\Delta [O_2^{.-}]_i')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([xmin xmax])
ylim([-15 75])
yticks([-15 30 75])
xticks([xmin xmax])
%title('F', 'Units', 'normalized', 'Position', [-0.12 1.02 0])
legend('Location','northeast','Box','off')

subplot(4,2,6), hold on, set(gca,'box','off','tickdir','out','fontsize',12)


%% =========================================================
%  EXTRACT QUANTITATIVE VALUES
% =========================================================

% Use last 100ms of trace as steady-state window
ss_mask = t_base >= 400;

% --- Baseline steady-state values ---
peak_Cai_base  = max(cai_base(ss_mask));
diast_Cai_base = min(cai_base(ss_mask));
peak_Cam_base  = max(Cam_base(ss_mask));
diast_Cam_base = min(Cam_base(ss_mask));
peak_JETC_base = max(JETC_base(ss_mask));
peak_ROSi_base = max(ROSi_base(ss_mask));
min_Psi_base   = min(Psi_base(ss_mask));

% --- +37% Cai ---
peak_Cai_30    = max(cai_30(ss_mask));
diast_Cai_30   = min(cai_30(ss_mask));
peak_Cam_30    = max(Cam_30(ss_mask));
diast_Cam_30   = min(Cam_30(ss_mask));
peak_JETC_30   = max(JETC_30(ss_mask));
peak_ROSi_30   = max(ROSi_30(ss_mask));
min_Psi_30     = min(Psi_30(ss_mask));

% --- +62% Cai ---
peak_Cai_50    = max(cai_50(ss_mask));
diast_Cai_50   = min(cai_50(ss_mask));
peak_Cam_50    = max(Cam_50(ss_mask));
diast_Cam_50   = min(Cam_50(ss_mask));
peak_JETC_50   = max(JETC_50(ss_mask));
peak_ROSi_50   = max(ROSi_50(ss_mask));
min_Psi_50     = min(Psi_50(ss_mask));

% --- Percent changes ---
pct_peak_Cam_30  = 100*(peak_Cam_30  - peak_Cam_base)  / peak_Cam_base;
pct_diast_Cam_30 = 100*(diast_Cam_30 - diast_Cam_base) / diast_Cam_base;
pct_peak_Cam_50  = 100*(peak_Cam_50  - peak_Cam_base)  / peak_Cam_base;
pct_diast_Cam_50 = 100*(diast_Cam_50 - diast_Cam_base) / diast_Cam_base;

pct_peak_JETC_30 = 100*(peak_JETC_30 - peak_JETC_base) / peak_JETC_base;
pct_peak_JETC_50 = 100*(peak_JETC_50 - peak_JETC_base) / peak_JETC_base;

pct_peak_ROSi_30 = 100*(peak_ROSi_30 - peak_ROSi_base) / peak_ROSi_base;
pct_peak_ROSi_50 = 100*(peak_ROSi_50 - peak_ROSi_base) / peak_ROSi_base;

pct_min_Psi_30   = 100*(min_Psi_30   - min_Psi_base)   / abs(min_Psi_base);
pct_min_Psi_50   = 100*(min_Psi_50   - min_Psi_base)   / abs(min_Psi_base);

% --- Print summary ---
fprintf('\n=== Quantitative Summary — Cai Perturbation at 1Hz ===\n\n');
fprintf('%-25s  %10s  %10s\n', 'Variable', '+37% Cai', '+62% Cai');
fprintf('%s\n', repmat('-', 1, 50));
fprintf('%-25s  %10.2f  %10.2f\n', 'Peak Cam (% change)',   pct_peak_Cam_30,  pct_peak_Cam_50);
fprintf('%-25s  %10.2f  %10.2f\n', 'Diast Cam (% change)',  pct_diast_Cam_30, pct_diast_Cam_50);
fprintf('%-25s  %10.2f  %10.2f\n', 'Peak JETC (% change)',  pct_peak_JETC_30, pct_peak_JETC_50);
fprintf('%-25s  %10.2f  %10.2f\n', 'Peak ROSi (% change)',  pct_peak_ROSi_30, pct_peak_ROSi_50);
fprintf('%-25s  %10.2f  %10.2f\n', 'Min Psi (% change)',    pct_min_Psi_30,   pct_min_Psi_50);
fprintf('\n');
