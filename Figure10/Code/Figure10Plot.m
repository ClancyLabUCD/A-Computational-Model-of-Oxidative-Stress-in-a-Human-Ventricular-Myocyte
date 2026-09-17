%% Figure10_bars.m
%  Left column  — grouped bar plots (log y, shared axis) one variable per row
%  Right column — time traces at D=0, D=0.75, D=1.0
%
%  Row A: APD90   | V traces
%  Row B: ROSi    | ROSi traces
%  Row C: Cam     | Cam traces
%  Row D: Psi min | Psi traces
%
%  All at 500 ms CL (2 Hz)

%% =========================================================
%  HELPER FUNCTIONS
% =========================================================
function s = extract_SS(data)
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

    apd_col = data(:, 26);
    apd_col = apd_col(apd_col > 0);
    s.APD   = apd_col(end);

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
    v = [d.ctrl.(field), d.d05.(field), d.d06.(field), d.d07.(field), ...
         d.d075.(field), d.d08.(field), d.d09.(field), d.max.(field)];
end

function [t1, v1] = first_beat(t_ss, v_ss, CL_ms)
    idx = t_ss <= CL_ms;
    t1  = t_ss(idx);
    v1  = v_ss(idx);
end

%% =========================================================
%  COLORS
% =========================================================
% Bar colors — D values light to dark (D=0.5 lightest, D=1.0 darkest)
% Each variable has its own hue family

% APD — charcoal greys
bar_col_V    = [0.82 0.82 0.82;   % D=0.5
                0.65 0.65 0.65;   % D=0.6
                0.50 0.50 0.50;   % D=0.7
                0.38 0.38 0.38;   % D=0.75
                0.26 0.26 0.26;   % D=0.8
                0.15 0.15 0.15;   % D=0.9
                0.05 0.05 0.05];  % D=1.0

% ROSi — blues
bar_col_ROSi = [0.76 0.88 0.99;
                0.58 0.74 0.95;
                0.42 0.62 0.90;
                0.28 0.50 0.83;
                0.18 0.42 0.78;
                0.10 0.33 0.72;
                0.05 0.25 0.65];

% Cam — magentas
bar_col_Cam  = [0.98 0.82 0.90;
                0.95 0.65 0.80;
                0.92 0.48 0.70;
                0.88 0.30 0.60;
                0.84 0.18 0.52;
                0.80 0.08 0.45;
                0.72 0.02 0.38];

% Psi — greens
bar_col_Psi  = [0.70 0.92 0.70;
                0.50 0.82 0.50;
                0.33 0.73 0.33;
                0.20 0.63 0.20;
                0.12 0.55 0.12;
                0.06 0.46 0.06;
                0.03 0.38 0.03];

% Time trace colors — 3 shades
col_V    = [0.05 0.05 0.05; 0.50 0.50 0.50; 0.85 0.85 0.85];
col_ROSi = [0.05 0.25 0.65; 0.42 0.62 0.90; 0.76 0.88 0.99];
col_Cam  = [0.75 0.02 0.40; 0.92 0.48 0.70; 0.98 0.82 0.90];
col_Psi  = [0.03 0.40 0.03; 0.33 0.73 0.33; 0.70 0.92 0.70];

%% =========================================================
%  LOAD DATA — 500 ms CL (2 Hz)
% =========================================================
d500.ctrl = extract_SS(readmatrix("output_500CL_D0.txt"));
d500.d05  = extract_SS(readmatrix("output_500CL_D05.txt"));
d500.d06  = extract_SS(readmatrix("output_500CL_D06.txt"));
d500.d07  = extract_SS(readmatrix("output_500CL_D07.txt"));
d500.d075 = extract_SS(readmatrix("output_500CL_D75.txt"));
d500.d08  = extract_SS(readmatrix("output_500CL_D08.txt"));
d500.d09  = extract_SS(readmatrix("output_500CL_D09.txt"));
d500.max  = extract_SS(readmatrix("output_500CL_D1.txt"));

%% =========================================================
%  SUMMARY VECTORS
% =========================================================
D_vals = [0, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0];

APD90_500     = buildvec(d500, 'APD');
Cam_peak_500  = buildvec(d500, 'Cam_peak');
Psi_min_500   = buildvec(d500, 'Psi_min');
ROSi_peak_500 = buildvec(d500, 'ROSi_peak');

%% =========================================================
%  % CHANGE — skip D=0 (always 0%), plot D=0.5 through D=1.0
%  Index 2:8 corresponds to D=0.5,0.6,0.7,0.75,0.8,0.9,1.0
% =========================================================
D_bar    = D_vals(2:end);   % [0.5 0.6 0.7 0.75 0.8 0.9 1.0]
xlabels  = {'0.5','0.6','0.7','0.75','0.8','0.9','1.0'};

pct_APD  = max(100*(APD90_500(2:end)    - APD90_500(1))    / APD90_500(1)    + 1, 1);
pct_ROSi =     100*(ROSi_peak_500(2:end)- ROSi_peak_500(1))/ ROSi_peak_500(1)+ 1;
pct_Cam  =     100*(Cam_peak_500(2:end) - Cam_peak_500(1)) / Cam_peak_500(1) + 1;
pct_Psi  =     100*(-(Psi_min_500(2:end)- Psi_min_500(1))) / abs(Psi_min_500(1)) + 1;

%% =========================================================
%  ONE-BEAT EXTRACTION — D=0, D=0.75, D=1.0
% =========================================================
CL_ms = 500;

[t_D0,  v_D0  ] = first_beat(d500.ctrl.t, d500.ctrl.v,    CL_ms);
[~,   ROSi_D0 ] = first_beat(d500.ctrl.t, d500.ctrl.ROSi, CL_ms);
[~,   Cam_D0  ] = first_beat(d500.ctrl.t, d500.ctrl.Cam,  CL_ms);
[~,   Psi_D0  ] = first_beat(d500.ctrl.t, d500.ctrl.Psi,  CL_ms);

[t_D75, v_D75 ] = first_beat(d500.d075.t, d500.d075.v,    CL_ms);
[~,   ROSi_D75] = first_beat(d500.d075.t, d500.d075.ROSi, CL_ms);
[~,   Cam_D75 ] = first_beat(d500.d075.t, d500.d075.Cam,  CL_ms);
[~,   Psi_D75 ] = first_beat(d500.d075.t, d500.d075.Psi,  CL_ms);

[t_D1,  v_D1  ] = first_beat(d500.max.t, d500.max.v,    CL_ms);
[~,   ROSi_D1 ] = first_beat(d500.max.t, d500.max.ROSi, CL_ms);
[~,   Cam_D1  ] = first_beat(d500.max.t, d500.max.Cam,  CL_ms);
[~,   Psi_D1  ] = first_beat(d500.max.t, d500.max.Psi,  CL_ms);

%% =========================================================
%  SHARED AXIS SETTINGS
% =========================================================
shared_ylim   = [1 2000];
shared_yticks = [1 2 11 101 1001];
shared_ylabs  = {'0','1','10','100','1000'};
shared_ylabel = '%\Delta from D=0 (log)';
lw2 = 2.5;
leg = {'D=0','D=0.75','D=1.0'};

figure('Color','w','Position',[50 50 1100 1050]);

%% ---- PANEL A: APD90 bar -----------------------------------------------
subplot(4,2,1); hold on;
for k = 1:7
    bar(k, pct_APD(k), 0.8, 'FaceColor', bar_col_V(k,:), 'EdgeColor', 'none');
end
set(gca, 'YScale', 'log');
ylim(shared_ylim); yticks(shared_yticks); yticklabels(shared_ylabs);
ylabel(shared_ylabel, 'FontSize', 12);
xlabel('DOX Effect (D)', 'FontSize', 12);
xticks(1:7); 
%xticklabels(xlabels);
xlim([0.3 7.7]); box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- PANEL B: V time traces -------------------------------------------
subplot(4,2,2); hold on;
plot(t_D0,  v_D0,  'Color', col_V(3,:), 'LineWidth', lw2);
plot(t_D75, v_D75, 'Color', col_V(2,:), 'LineWidth', lw2);
plot(t_D1,  v_D1,  'Color', col_V(1,:), 'LineWidth', lw2);
ylabel('V (mV)', 'FontSize', 12);
xlabel('Time (ms)', 'FontSize', 12);
xlim([0 CL_ms]); xticks([0 250 500]);
ylim([-100 50]); yticks([-100 -50 0 50]);
legend(leg, 'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- PANEL C: ROSi bar ------------------------------------------------
subplot(4,2,3); hold on;
for k = 1:7
    bar(k, pct_ROSi(k), 0.8, 'FaceColor', bar_col_ROSi(k,:), 'EdgeColor', 'none');
end
set(gca, 'YScale', 'log');
ylim(shared_ylim); yticks(shared_yticks); yticklabels(shared_ylabs);
ylabel(shared_ylabel, 'FontSize', 12);
xlabel('DOX Effect (D)', 'FontSize', 12);
xticks(1:7); 
%xticklabels(xlabels);
xlim([0.3 7.7]); box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- PANEL D: ROSi time traces ----------------------------------------
subplot(4,2,4); hold on;
plot(t_D0,  ROSi_D0,  'Color', col_ROSi(3,:), 'LineWidth', lw2);
plot(t_D75, ROSi_D75, 'Color', col_ROSi(2,:), 'LineWidth', lw2);
plot(t_D1,  ROSi_D1,  'Color', col_ROSi(1,:), 'LineWidth', lw2);
ylabel('ROS_i (\muM)', 'FontSize', 11);
xlabel('Time (ms)', 'FontSize', 11);
xlim([0 CL_ms]); xticks([0 250 500]);
ylim([0 1.7]); yticks([0 0.85 1.7]);
legend(leg, 'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- PANEL E: Cam bar -------------------------------------------------
subplot(4,2,5); hold on;
for k = 1:7
    bar(k, pct_Cam(k), 0.8, 'FaceColor', bar_col_Cam(k,:), 'EdgeColor', 'none');
end
set(gca, 'YScale', 'log');
ylim(shared_ylim); yticks(shared_yticks); yticklabels(shared_ylabs);
ylabel(shared_ylabel, 'FontSize', 12);
xlabel('DOX Effect (D)', 'FontSize', 12);
xticks(1:7); 
%xticklabels(xlabels);
xlim([0.3 7.7]); box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- PANEL F: Cam time traces -----------------------------------------
subplot(4,2,6); hold on;
plot(t_D0,  Cam_D0,  'Color', col_Cam(3,:), 'LineWidth', lw2);
plot(t_D75, Cam_D75, 'Color', col_Cam(2,:), 'LineWidth', lw2);
plot(t_D1,  Cam_D1,  'Color', col_Cam(1,:), 'LineWidth', lw2);
ylabel('[Ca^{2+}]_m (\muM)', 'FontSize', 12);
xlabel('Time (ms)', 'FontSize', 12);
xlim([0 CL_ms]); xticks([0 250 500]);
ylim([0.2 0.8]); yticks([0.2 0.5 0.8]);
legend(leg, 'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- PANEL G: Psi bar -------------------------------------------------
subplot(4,2,7); hold on;
for k = 1:7
    bar(k, pct_Psi(k), 0.8, 'FaceColor', bar_col_Psi(k,:), 'EdgeColor', 'none');
end
set(gca, 'YScale', 'log');
ylim(shared_ylim); yticks(shared_yticks); yticklabels(shared_ylabs);
ylabel(shared_ylabel, 'FontSize', 12);
xlabel('DOX Effect (D)', 'FontSize', 12);
xticks(1:7); 
%xticklabels(xlabels);
xlim([0.3 7.7]); box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- PANEL H: Psi time traces -----------------------------------------
subplot(4,2,8); hold on;
plot(t_D0,  Psi_D0,  'Color', col_Psi(3,:), 'LineWidth', lw2);
plot(t_D75, Psi_D75, 'Color', col_Psi(2,:), 'LineWidth', lw2);
plot(t_D1,  Psi_D1,  'Color', col_Psi(1,:), 'LineWidth', lw2);
ylabel('\Psi_m (mV)', 'FontSize', 12);
xlabel('Time (ms)', 'FontSize', 12);
xlim([0 CL_ms]); xticks([0 250 500]);
ylim([176 190]); yticks([176 183 190]);
legend(leg, 'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
box off; set(gca, 'FontSize', 12, 'TickDir', 'out');

%% ---- Global formatting ------------------------------------------------
set(findall(gcf,'Type','axes'), 'LineWidth', 1.0);


%% =========================================================
%  RESULTS TEXT VALUES — 
% =========================================================

% D_bar = [0.5 0.6 0.7 0.75 0.8 0.9 1.0], indices 1-7
true_pct_APD  = 100*(APD90_500(2:end)     - APD90_500(1))     / APD90_500(1);
true_pct_ROSi = 100*(ROSi_peak_500(2:end) - ROSi_peak_500(1)) / ROSi_peak_500(1);
true_pct_Cam  = 100*(Cam_peak_500(2:end)  - Cam_peak_500(1))  / Cam_peak_500(1);
true_pct_Psi  = 100*(-(Psi_min_500(2:end) - Psi_min_500(1)))  / abs(Psi_min_500(1));

% Full table across all 7 D values (0.5 through 1.0)
fprintf('\n===== Figure 10: True percent change from D=0 baseline (500ms CL) =====\n');
fprintf('%-6s %10s %10s %10s %10s\n', 'D', 'APD90', 'ROSi', 'Cam', 'Psi(depol)');
for k = 1:length(D_bar)
    fprintf('%-6.2f %9.2f%% %9.2f%% %9.2f%% %9.2f%%\n', ...
        D_bar(k), true_pct_APD(k), true_pct_ROSi(k), true_pct_Cam(k), true_pct_Psi(k));
end

% Specific D values referenced in the Results paragraph: 0.5, 0.7, 0.75, 1.0
report_D = [0.5, 0.7, 0.75, 1.0];
fprintf('\n===== Values for Results text (D = 0.5, 0.7, 0.75, 1.0) =====\n');
for dval = report_D
    idx = find(abs(D_bar - dval) < 1e-9, 1);
    if isempty(idx)
        fprintf('D=%.2f not found in D_bar\n', dval);
        continue
    end
    fprintf('D=%.2f:  APD90 = %.2f%%   ROSi = %.2f%%   Cam = %.2f%%   Psi (depol) = %.2f%%\n', ...
        dval, true_pct_APD(idx), true_pct_ROSi(idx), true_pct_Cam(idx), true_pct_Psi(idx));
end
