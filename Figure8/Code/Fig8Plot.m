%% =========================================
% 8-panel figure:
% LEFT column  = heat maps
% RIGHT column = open trace panels to fill later
%
% Heat maps:
%   A: SS APD90
%   C: SS Peak Cai
%   E: SS Peak Cam
%   G: SS Peak ROSi
%
% Each heat map includes a horizontal dashed line at ETC Leak = 0.55
% Missing values (NaN) are shown as gray
%% =========================================

clear; clc; close all;

%% -----------------------------
% File names
% -----------------------------
file_05Hz = 'ETCLeak_sweep_summary_2000CL.txt';   % 2000 ms CL
file_1Hz  = 'ETCLeak_sweep_summary_1000CL.txt';    % 1000 ms CL
file_15Hz = 'ETCLeak_sweep_summary_750CL.txt';   % 750 ms CL
file_2Hz  = 'ETCLeak_sweep_summary_500CL.txt';    % 500 ms CL


%% -----------------------------
% Load tables
% -----------------------------
T05 = readtable(file_05Hz, 'FileType','text', 'Delimiter','\t');
T1  = readtable(file_1Hz,  'FileType','text', 'Delimiter','\t');
T15 = readtable(file_15Hz, 'FileType','text', 'Delimiter','\t');
T2  = readtable(file_2Hz,  'FileType','text', 'Delimiter','\t');

% Keep only steady-state rows
T05 = T05(strcmp(T05.status, 'steady_state'), :);
T1  = T1(strcmp(T1.status,  'steady_state'), :);
T15 = T15(strcmp(T15.status, 'steady_state'), :);
T2  = T2(strcmp(T2.status,  'steady_state'), :);

%% -----------------------------
% Convert units if needed
% Assuming Cai, Cam, ROSi were written in mM
% Convert to uM for plotting
% -----------------------------
T05.SS_peak_Cai  = T05.SS_peak_Cai  * 1000;
T05.SS_peak_Cam  = T05.SS_peak_Cam  * 1000;
T05.SS_peak_ROSi = T05.SS_peak_ROSi * 1000;

T1.SS_peak_Cai   = T1.SS_peak_Cai   * 1000;
T1.SS_peak_Cam   = T1.SS_peak_Cam   * 1000;
T1.SS_peak_ROSi  = T1.SS_peak_ROSi  * 1000;

T15.SS_peak_Cai  = T15.SS_peak_Cai  * 1000;
T15.SS_peak_Cam  = T15.SS_peak_Cam  * 1000;
T15.SS_peak_ROSi = T15.SS_peak_ROSi * 1000;

T2.SS_peak_Cai   = T2.SS_peak_Cai   * 1000;
T2.SS_peak_Cam   = T2.SS_peak_Cam   * 1000;
T2.SS_peak_ROSi  = T2.SS_peak_ROSi  * 1000;

%% -----------------------------
% Build common ETC leak axis
% -----------------------------
all_ETC = unique([T05.ETC_Leak; T1.ETC_Leak; T15.ETC_Leak; T2.ETC_Leak]);
all_ETC = sort(all_ETC);

nETC = length(all_ETC);
nCL  = 4;
CL_labels = {'2000','1000','750','500'};

APD_mat  = nan(nETC, nCL);
Cai_mat  = nan(nETC, nCL);
Cam_mat  = nan(nETC, nCL);
ROSi_mat = nan(nETC, nCL);

for i = 1:height(T05)
    r = find(abs(all_ETC - T05.ETC_Leak(i)) < 1e-12, 1);
    APD_mat(r,1)  = T05.SS_APD90(i);
    Cai_mat(r,1)  = T05.SS_peak_Cai(i);
    Cam_mat(r,1)  = T05.SS_peak_Cam(i);
    ROSi_mat(r,1) = T05.SS_peak_ROSi(i);
end

for i = 1:height(T1)
    r = find(abs(all_ETC - T1.ETC_Leak(i)) < 1e-12, 1);
    APD_mat(r,2)  = T1.SS_APD90(i);
    Cai_mat(r,2)  = T1.SS_peak_Cai(i);
    Cam_mat(r,2)  = T1.SS_peak_Cam(i);
    ROSi_mat(r,2) = T1.SS_peak_ROSi(i);
end

for i = 1:height(T15)
    r = find(abs(all_ETC - T15.ETC_Leak(i)) < 1e-12, 1);
    APD_mat(r,3)  = T15.SS_APD90(i);
    Cai_mat(r,3)  = T15.SS_peak_Cai(i);
    Cam_mat(r,3)  = T15.SS_peak_Cam(i);
    ROSi_mat(r,3) = T15.SS_peak_ROSi(i);
end

for i = 1:height(T2)
    r = find(abs(all_ETC - T2.ETC_Leak(i)) < 1e-12, 1);
    APD_mat(r,4)  = T2.SS_APD90(i);
    Cai_mat(r,4)  = T2.SS_peak_Cai(i);
    Cam_mat(r,4)  = T2.SS_peak_Cam(i);
    ROSi_mat(r,4) = T2.SS_peak_ROSi(i);
end

%% -----------------------------
% Custom colormaps
% -----------------------------
nmap = 256;

% APD90: light -> dark green
cmap_APD = [linspace(0.88,0.10,nmap)' linspace(0.97,0.45,nmap)' linspace(0.88,0.20,nmap)'];

% Cai: light -> dark purple
cmap_Cai = [linspace(0.93,0.35,nmap)' linspace(0.88,0.15,nmap)' linspace(0.97,0.55,nmap)'];

% Cam: light pink -> dark magenta
cmap_Cam = [linspace(0.98,0.65,nmap)' linspace(0.84,0.05,nmap)' linspace(0.92,0.45,nmap)'];

% ROSi: light -> dark blue
cmap_ROS = [linspace(0.88,0.05,nmap)' linspace(0.95,0.25,nmap)' linspace(1.00,0.75,nmap)'];

nan_color = [0.82 0.82 0.82];
make_alpha = @(M) ~isnan(M);

%% -----------------------------
% Target ETC leak
% -----------------------------
ETC_target = 0.55;
row_target = find(abs(all_ETC - ETC_target) < 1e-12, 1);

%% -----------------------------
% Trace files for ETC Leak = 0.33
% Columns:
% 1 t
% 2 v
% 3 cai
% 4 Cam
% 5 ROSi
% -----------------------------
file_trace_15 = 'output_750CL_55.txt';   % 750 ms CL
file_trace_05 = 'output_2000CL_55.txt';   % 2000 ms CL
file_trace_1  = 'output_1000CL_55.txt';    % 1000 ms CL
file_trace_2  = 'output_500CL_55.txt';    % 500 ms CL

D15 = load(file_trace_15);
D05 = load(file_trace_05);
D1  = load(file_trace_1);
D2  = load(file_trace_2);

% 2000 ms CL
t05    = D05(:,1);
v05    = D05(:,2);
cai05  = D05(:,3) * 1000;   % mM -> uM
Cam05  = D05(:,4) * 1000;   % mM -> uM
ROSi05 = D05(:,5) * 1000;   % mM -> uM

% 1000 ms CL
t1    = D1(:,1);
v1    = D1(:,2);
cai1  = D1(:,3) * 1000;
Cam1  = D1(:,4) * 1000;
ROSi1 = D1(:,5) * 1000;

% 750 ms CL
t15    = D15(:,1);
v15    = D15(:,2);
cai15  = D15(:,3) * 1000;
Cam15  = D15(:,4) * 1000;
ROSi15 = D15(:,5) * 1000;

% 500 ms CL
t2    = D2(:,1);
v2    = D2(:,2);
cai2  = D2(:,3) * 1000;
Cam2  = D2(:,4) * 1000;
ROSi2 = D2(:,5) * 1000;

col_05 = [0.25 0.25 0.25];   % 2000 ms
col_1  = [0.40 0.40 0.70];   % 1000 ms
col_15 = [0.65 0.35 0.75];   % 750 ms
col_2  = [0.15 0.60 0.85];   % 500 ms

%% -----------------------------
% Colorbar tick helper
% Same number of ticks for every heat map
% -----------------------------
nTicks = 4;
make_ticks = @(M) linspace(min(M(:),[],'omitnan'), max(M(:),[],'omitnan'), nTicks);

%% -----------------------------
% Y-axis labels
% -----------------------------
y_first = 1;
y_last  = nETC;
y_labels = {sprintf('%.2f', all_ETC(1)), sprintf('%.2f', all_ETC(end))};

%% -----------------------------
% Figure setup
% -----------------------------
figure('Color','w','Position',[100 50 1200 1100]);
set(groot,'defaultAxesFontSize',12)

xmin = 0;
xmax = 500; 

%% =========================================
% A: Heat map APD90
%% =========================================
subplot(4,2,1)
h = imagesc(APD_mat);
set(h, 'AlphaData', make_alpha(APD_mat))
set(gca, 'YDir', 'normal')
xticks(1:nCL)
xticklabels(CL_labels)
yticks([y_first y_last])
yticklabels(y_labels)
xlabel('Cycle Length (ms)')
ylabel('ETC Leak')
%title('A: SS APD90')
colormap(gca, cmap_APD)
ax = gca;
ax.Color = nan_color;
caxis([240 360]) 
cb = colorbar;
ticks = make_ticks([240 280 320 360]);
cb.Ticks = ticks;
cb.TickLabels = compose('%0.0f', ticks);
hold on
yline(row_target, '--k', 'LineWidth', 1.5)


%% =========================================
% B: OPEN TRACE PANEL
%% =========================================
subplot(4,2,2); hold on; box off; set(gca,'TickDir','out')
%title('B: Trace at ETC Leak = 0.33')
xlabel('Time (ms)')
ylabel('V (mV)')
plot(t05, v05, 'Color', col_05, 'DisplayName', '2000 ms')
plot(t1,  v1,  'Color', col_1,  'DisplayName', '1000 ms')
plot(t15, v15, 'Color', col_15, 'DisplayName', '750 ms')
plot(t2,  v2,  'Color', col_2,  'DisplayName', '500 ms')
legend('Box','off','Location','northeast')
xlim([xmin xmax])
xticks([0 500])
yticks([-100 -50 0 50])

%% =========================================
% C: Heat map Cai
%% =========================================
subplot(4,2,3)
h = imagesc(Cai_mat);
set(h, 'AlphaData', make_alpha(Cai_mat))
set(gca, 'YDir', 'normal')
xticks(1:nCL)
xticklabels(CL_labels)
yticks([y_first y_last])
yticklabels(y_labels)
xlabel('Cycle Length (ms)')
ylabel('ETC Leak')
%title('C: SS Peak [Ca^{2+}]_i (\muM)')
colormap(gca, cmap_Cai)
ax = gca;
ax.Color = nan_color;
caxis([0.2 1.8]) 
cb = colorbar;
ticks = make_ticks([0.2 0.7 1.2 1.8]);
cb.Ticks = ticks;
cb.TickLabels = compose('%.1f', ticks);
hold on
yline(row_target, '--k', 'LineWidth', 1.5)

%% =========================================
% D: OPEN TRACE PANEL
%% =========================================
subplot(4,2,4); hold on; box off; set(gca,'TickDir','out')
%title('D: Trace at ETC Leak = 0.33')
xlabel('Time (ms)')
ylabel('[Ca2+]i (muM)')
plot(t05, cai05, 'Color', col_05, 'DisplayName', '2000 ms')
plot(t1,  cai1,  'Color', col_1,  'DisplayName', '1000 ms')
plot(t15, cai15, 'Color', col_15, 'DisplayName', '750 ms')
plot(t2,  cai2,  'Color', col_2,  'DisplayName', '500 ms')
xlim([xmin xmax])
xticks([0 500])
ylim([0 1.8])
yticks([0 0.6 1.2 1.8])

%% =========================================
% E: Heat map Cam
%% =========================================
subplot(4,2,5)
h = imagesc(Cam_mat);
set(h, 'AlphaData', make_alpha(Cam_mat))
set(gca, 'YDir', 'normal')
xticks(1:nCL)
xticklabels(CL_labels)
yticks([y_first y_last])
yticklabels(y_labels)
xlabel('Cycle Length (ms)')
ylabel('ETC Leak')
%title('E: SS Peak [Ca^{2+}]_m (\muM)')
colormap(gca, cmap_Cam)
ax = gca;
ax.Color = nan_color;
caxis([0.1 0.7]) 
cb = colorbar;
ticks = make_ticks([0.1 0.3 0.5 0.7]);
cb.Ticks = ticks;
cb.TickLabels = compose('%.1f', ticks);
hold on
yline(row_target, '--k', 'LineWidth', 1.5)


%% =========================================
% F: OPEN TRACE PANEL
%% =========================================
subplot(4,2,6); hold on; box off; set(gca,'TickDir','out')
%title('F: Trace at ETC Leak = 0.33')
xlabel('Time (ms)')
ylabel('[Ca2+]m (muM)')
plot(t05, Cam05, 'Color', col_05, 'DisplayName', '2000 ms')
plot(t1,  Cam1,  'Color', col_1,  'DisplayName', '1000 ms')
plot(t15, Cam15, 'Color', col_15, 'DisplayName', '750 ms')
plot(t2,  Cam2,  'Color', col_2,  'DisplayName', '500 ms')
xlim([xmin xmax])
xticks([0 500])
ylim([0 0.6])
yticks([0 0.2 0.4 0.6])

%% =========================================
% G: Heat map ROSi
%% =========================================
subplot(4,2,7)
h = imagesc(ROSi_mat);
set(h, 'AlphaData', make_alpha(ROSi_mat))
set(gca, 'YDir', 'normal')
xticks(1:nCL)
xticklabels(CL_labels)
yticks([y_first y_last])
yticklabels(y_labels)
xlabel('Cycle Length (ms)')
ylabel('ETC Leak')
%title('G: SS Peak ROS_i (\muM)')
colormap(gca, cmap_ROS)
ax = gca;
ax.Color = nan_color;
caxis([0 1.8]) 
cb = colorbar;
ticks = make_ticks([0 0.6 1.2 1.8]);
cb.Ticks = ticks;
cb.TickLabels = compose('%.1f', ticks);
hold on
yline(row_target, '--k', 'LineWidth', 1.5)

%% =========================================
% H: OPEN TRACE PANEL
%% =========================================
subplot(4,2,8); hold on; box off; set(gca,'TickDir','out')
%title('H: Trace at ETC Leak = 0.33')
xlabel('Time (ms)')
ylabel('[O2.-]i (muM)')
plot(t05, ROSi05, 'Color', col_05, 'DisplayName', '2000 ms')
plot(t1,  ROSi1,  'Color', col_1,  'DisplayName', '1000 ms')
plot(t15, ROSi15, 'Color', col_15, 'DisplayName', '750 ms')
plot(t2,  ROSi2,  'Color', col_2,  'DisplayName', '500 ms')
xlim([xmin xmax])
xticks([0 500])
ylim([0 1.5])
yticks([0 0.5 1.0 1.5])

%% =========================================================
%  EXTRACT QUANTITATIVE VALUES — Heatmap corners + ETC=0.55
% =========================================================

% ETC leak indices for min (0.40) and max (0.60)
idx_min = find(abs(all_ETC - 0.40) < 1e-12, 1);
idx_max = find(abs(all_ETC - 0.60) < 1e-12, 1);
idx_55  = find(abs(all_ETC - 0.55) < 1e-12, 1);

% Column indices: 1=2000ms, 2=1000ms, 3=750ms, 4=500ms
CL_names = {'CL=2000ms', 'CL=1000ms', 'CL=750ms', 'CL=500ms'};

fprintf('\n=== APD90 (ms) at ETC Leak corners ===\n');
fprintf('%-15s  %10s  %10s  %10s  %10s\n', 'ETC Leak', CL_names{:});
fprintf('%s\n', repmat('-', 1, 55));
fprintf('%-15s  %10.1f  %10.1f  %10.1f  %10.1f\n', '0.40 (min)', APD_mat(idx_min,:));
fprintf('%-15s  %10.1f  %10.1f  %10.1f  %10.1f\n', '0.55 (rep)', APD_mat(idx_55,:));
fprintf('%-15s  %10.1f  %10.1f  %10.1f  %10.1f\n', '0.60 (max)', APD_mat(idx_max,:));

fprintf('\n=== Peak [Ca2+]i (uM) at ETC Leak corners ===\n');
fprintf('%-15s  %10s  %10s  %10s  %10s\n', 'ETC Leak', CL_names{:});
fprintf('%s\n', repmat('-', 1, 55));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.40 (min)', Cai_mat(idx_min,:));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.55 (rep)', Cai_mat(idx_55,:));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.60 (max)', Cai_mat(idx_max,:));

fprintf('\n=== Peak [Ca2+]m (uM) at ETC Leak corners ===\n');
fprintf('%-15s  %10s  %10s  %10s  %10s\n', 'ETC Leak', CL_names{:});
fprintf('%s\n', repmat('-', 1, 55));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.40 (min)', Cam_mat(idx_min,:));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.55 (rep)', Cam_mat(idx_55,:));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.60 (max)', Cam_mat(idx_max,:));

fprintf('\n=== Peak [O2.-]i (uM) at ETC Leak corners ===\n');
fprintf('%-15s  %10s  %10s  %10s  %10s\n', 'ETC Leak', CL_names{:});
fprintf('%s\n', repmat('-', 1, 55));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.40 (min)', ROSi_mat(idx_min,:));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.55 (rep)', ROSi_mat(idx_55,:));
fprintf('%-15s  %10.3f  %10.3f  %10.3f  %10.3f\n', '0.60 (max)', ROSi_mat(idx_max,:));

fprintf('\n=== Percent change from ETC=0.40 to ETC=0.60 ===\n');
fprintf('%-15s  %10s  %10s  %10s  %10s\n', 'Variable', CL_names{:});
fprintf('%s\n', repmat('-', 1, 55));
fprintf('%-15s  %10.1f  %10.1f  %10.1f  %10.1f\n', 'APD90 (%)', ...
    100*(APD_mat(idx_max,:) - APD_mat(idx_min,:)) ./ APD_mat(idx_min,:));
fprintf('%-15s  %10.1f  %10.1f  %10.1f  %10.1f\n', 'Peak Cai (%)', ...
    100*(Cai_mat(idx_max,:) - Cai_mat(idx_min,:)) ./ Cai_mat(idx_min,:));
fprintf('%-15s  %10.1f  %10.1f  %10.1f  %10.1f\n', 'Peak Cam (%)', ...
    100*(Cam_mat(idx_max,:) - Cam_mat(idx_min,:)) ./ Cam_mat(idx_min,:));
fprintf('%-15s  %10.1f  %10.1f  %10.1f  %10.1f\n', 'Peak ROSi (%)', ...
    100*(ROSi_mat(idx_max,:) - ROSi_mat(idx_min,:)) ./ ROSi_mat(idx_min,:));

fprintf('\n=== Representative traces at ETC=0.55 ===\n');
fprintf('Peak ROSi:  2000ms=%.3f, 1000ms=%.3f, 750ms=%.3f, 500ms=%.3f uM\n', ...
    max(ROSi05), max(ROSi1), max(ROSi15), max(ROSi2));
fprintf('Peak Cai:   2000ms=%.3f, 1000ms=%.3f, 750ms=%.3f, 500ms=%.3f uM\n', ...
    max(cai05), max(cai1), max(cai15), max(cai2));
fprintf('Diast Cai:  2000ms=%.3f, 1000ms=%.3f, 750ms=%.3f, 500ms=%.3f uM\n', ...
    min(cai05), min(cai1), min(cai15), min(cai2));
fprintf('Peak Cam:   2000ms=%.3f, 1000ms=%.3f, 750ms=%.3f, 500ms=%.3f uM\n', ...
    max(Cam05), max(Cam1), max(Cam15), max(Cam2));
fprintf('Diast Cam:  2000ms=%.3f, 1000ms=%.3f, 750ms=%.3f, 500ms=%.3f uM\n', ...
    min(Cam05), min(Cam1), min(Cam15), min(Cam2));
fprintf('\n');
