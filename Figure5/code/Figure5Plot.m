%% Code Data 
% Load low ROS case
low = load('output_1Hz_ROSilow.txt');

% Assign variables
t_low     = low(:,1);
v_low     = low(:,2);
cai_low   = low(:,3);
cass_low  = low(:,4);
cansr_low = low(:,5);
cajsr_low = low(:,6);
Jrel_low  = low(:,7);
Jup_low   = low(:,8);
Cam_low   = low(:,9);
ROSi_low  = low(:,10);

% Load Mid ROS case
mid = load('output_1Hz_ROSimid.txt');

% Assign variables
t_mid     = mid(:,1);
v_mid     = mid(:,2);
cai_mid   = mid(:,3);
cass_mid  = mid(:,4);
cansr_mid = mid(:,5);
cajsr_mid = mid(:,6);
Jrel_mid  = mid(:,7);
Jup_mid   = mid(:,8);
Cam_mid   = mid(:,9);
ROSi_mid  = mid(:,10);

% Load Mid ROS case
high = load('output_1Hz_ROSihigh.txt');

% Assign variables
t_high     = high(:,1);
v_high     = high(:,2);
cai_high   = high(:,3);
cass_high  = high(:,4);
cansr_high = high(:,5);
cajsr_high = high(:,6);
Jrel_high  = high(:,7);
Jup_high   = high(:,8);
Cam_high   = high(:,9);
ROSi_high  = high(:,10);


%% SERCA Exp Data

% Experimental data: [ROSi (uM), normalized Jup/Jup0]
raw_uM = [
    0.437982    0.995847
   20.648340    0.569804
   39.800140    0.242640
   60.064945    0.068686
   79.922150    0.007543
   99.789582   -0.006246
  200.006317   -0.002763];

% Convert to mM
x = raw_uM(:,1) / 1000;   % ROSi (mM)
y = raw_uM(:,2);          % normalized SERCA flux

% SERCA fit
ROSi_SERCA = logspace(-6, 1, 4000);
SERCA_fit = 1.02 * exp(-43.67*ROSi_SERCA); 

% RyR
x_RyR = [0; 0.01; 0.1; 1.0];          % H2O2 (mM)
Po = [0.027; 0.067; 0.219; 0.219];    % open probability

Po0 = Po(1);
F = Po ./ Po0;                        % fold-change

ROSi_RyR = logspace(-6, 1, 4000)';   
RyR_fit  = 1.0 + (8.3 - 1.0) .* (1.0 - exp(-27.01 .* ROSi_RyR));

% Colors
color_SERCA_fit = [0.00 0.50 0.50];
color_SERCA_exp = [0.40 0.75 0.75];

color_RyR_fit   = [0.85 0.40 0.00];
color_RyR_exp   = [0.98 0.65 0.30];

col_ROI_low = [0.20 0.05 0.30];   % darkest (almost deep plum)
col_ROI_mid = [0.45 0.20 0.55];   % medium
col_ROI_hi  = [0.70 0.55 0.85];   % light
col_ROI_max = [0.90 0.82 0.95];   % very light but still visible
col_ROI_box = [0.82 0.82 0.82];

% =========================================================
% VERTICAL DASHED LINES: EDIT THESE VALUES
% =========================================================
line_low = 1.05e-4;
line_mid = 1e-3;
line_hi  = 0.1;
line_max = 3.0; 

% display-safe RyR baseline point for log axis
x_RyR_plot = x_RyR;
x_RyR_plot(x_RyR_plot == 0) = 1e-6;

%

fh = figure('Color','w');
set(fh, 'DefaultAxesFontSize', 12);
set(fh, 'DefaultAxesFontName', 'Arial');
set(fh, 'DefaultTextFontName', 'Arial');

% =========================
% Subplot A: full view
% =========================
axA = subplot(3,2,2);
hold(axA,'on')
set(axA,'XScale','log')

% ROI background box
yyaxis(axA,'left')
ylA = [1 9];
ylim(axA, ylA)

roi_x0 = 1e-6;
roi_x1 = 1e-2;
%rectangle(axA,'Position',[roi_x0 ylA(1) (roi_x1-roi_x0) (ylA(2)-ylA(1))], ...
    %'FaceColor', col_ROI_box, 'EdgeColor','none', 'FaceAlpha',0.35, ...
    %'HandleVisibility','off');

% LEFT y-axis: RyR
yyaxis(axA,'left')
pA_exp_RyR = plot(axA, x_RyR_plot, F, 'o', ...
    'MarkerEdgeColor', color_RyR_exp, ...
    'MarkerFaceColor', color_RyR_exp, ...
    'LineWidth', 3, 'MarkerSize', 9, ...
    'LineStyle','none', ...
    'DisplayName','\itOba et al., 2002');

pA_fit_RyR = plot(axA, ROSi_RyR, RyR_fit, '-', ...
    'Color', color_RyR_fit, 'LineWidth', 3, ...
    'DisplayName','RyR fit');

ylim(axA,[1 9]); 
yticks(axA,[1 5 9]);
axA.YColor = color_RyR_fit;
yyaxis(axA,'left')
ylabel(axA,'RyR fold-change','FontSize',12);


% RIGHT y-axis: SERCA
yyaxis(axA,'right')
pA_exp_SERCA = plot(axA, x, y, 'o', ...
    'MarkerEdgeColor', color_SERCA_exp, ...
    'MarkerFaceColor', color_SERCA_exp, ...
    'LineWidth', 3, 'MarkerSize', 8, ...
    'LineStyle','none', ...
    'DisplayName','\itXu et al., 1997');

pA_fit_SERCA = plot(axA, ROSi_SERCA, SERCA_fit, '-', ...
    'Color', color_SERCA_fit, 'LineWidth', 3, ...
    'DisplayName','SERCA fit');

ylim(axA,[0 1.05]); 
yticks(axA,[0 0.5 1.0]);
axA.YColor = color_SERCA_fit;

xlabel(axA,'[O2.-]i (mM)');
xlim(axA,[1e-4 10])
xticks([1e-4 1e-3 1e-2 1e-1 1 10])
grid(axA,'off'); 
box(axA,'off');


% all three dashed reference lines
xline(axA, line_low, '--', 'LineWidth', 2.5, 'Color', col_ROI_low, 'HandleVisibility','off');
xline(axA, line_mid, '--', 'LineWidth', 2.5, 'Color', col_ROI_mid, 'HandleVisibility','off');
xline(axA, line_hi,  '--', 'LineWidth', 2.5, 'Color', col_ROI_hi,  'HandleVisibility','off');
 

% Plot variables from code
 xmin = 0; 
 xmax = 1000;
subplot(3,2,3)
plot(t_low, cai_low*1000, 'LineWidth', 2, 'Color', col_ROI_low)
hold on
plot(t_mid, cai_mid*1000, 'LineWidth', 2, 'Color', col_ROI_mid)
hold on
plot(t_high, cai_high*1000, 'LineWidth', 2, 'Color', col_ROI_hi)
xlabel('Time (ms)')
ylabel(['[Ca2+]_i (µM)'])
box off
xlim([xmin xmax])
xticks([0 1000])
ylim([0 0.6])
yticks([0 0.3 0.6])

subplot(3,2,4)
plot(t_low, Cam_low*1000, 'LineWidth', 2, 'Color', col_ROI_low)
hold on
plot(t_mid, Cam_mid*1000, 'LineWidth', 2, 'Color', col_ROI_mid)
hold on
plot(t_high, Cam_high*1000, 'LineWidth', 2, 'Color', col_ROI_hi)
xlabel('Time (ms)')
ylabel('[Ca2+]m (µM)')
box off
xlim([xmin xmax])
xticks([0 1000])
ylim([0 0.3])
yticks([0 0.15 0.3])

subplot(3,2,5)
plot(t_low, cansr_low*1000, 'LineWidth', 2, 'Color', col_ROI_low)
hold on
plot(t_mid, cansr_mid*1000, 'LineWidth', 2, 'Color', col_ROI_mid)
hold on
plot(t_high, cansr_high*1000, 'LineWidth', 2, 'Color', col_ROI_hi)
xlabel('Time (ms)')
ylabel('[Ca2+]NSR (µM)')
box off
xlim([xmin xmax])
xticks([0 1000])
ylim([0 2000])
yticks([0 1000 2000])

subplot(3,2,6)
plot(t_low, cajsr_low*1000, 'LineWidth', 2, 'Color', col_ROI_low)
hold on
plot(t_mid, cajsr_mid*1000, 'LineWidth', 2, 'Color', col_ROI_mid)
hold on
plot(t_high, cajsr_high*1000, 'LineWidth', 2, 'Color', col_ROI_hi)
xlabel('Time (ms)')
ylabel('[Ca2+]JSR (µM)')
box off
xlim([xmin xmax])
xticks([0 1000])
ylim([0 2000])
yticks([0 1000 2000])


