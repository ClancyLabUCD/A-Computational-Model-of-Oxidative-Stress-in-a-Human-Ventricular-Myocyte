%% Figure 6 Code

% Load files - SIMULATION
% -----------------------------
% 1 Hz
data_1Hz_base = load('output3_HZ_1Hz_base.txt');
data_1Hz_high = load('output3_HZ_1Hz_high.txt');

% ===== 1 Hz =====
t_1Hz_base    = data_1Hz_base(:,1);
v_1Hz_base    = data_1Hz_base(:,2);
cai_1Hz_base  = data_1Hz_base(:,3);
ICaL_1Hz_base = data_1Hz_base(:,4);
INaL_1Hz_base = data_1Hz_base(:,5);
ROSi_1Hz_base = data_1Hz_base(:,6);
APD_1Hz_base  = data_1Hz_base(:,7);

t_1Hz_high    = data_1Hz_high(:,1);
v_1Hz_high    = data_1Hz_high(:,2);
cai_1Hz_high  = data_1Hz_high(:,3);
ICaL_1Hz_high = data_1Hz_high(:,4);
INaL_1Hz_high = data_1Hz_high(:,5);
ROSi_1Hz_high = data_1Hz_high(:,6);
APD_1Hz_high  = data_1Hz_high(:,7);

beat_start = 0;
beat_end = 500; 
% ---------- 1 Hz ----------
idx_1b = t_1Hz_base >= beat_start & t_1Hz_base <= beat_end;
idx_1h = t_1Hz_high >= beat_start & t_1Hz_high <= beat_end;

% INaL AUC
INaL_auc_1b = abs(trapz(t_1Hz_base(idx_1b), INaL_1Hz_base(idx_1b)));
INaL_auc_1h = abs(trapz(t_1Hz_high(idx_1h), INaL_1Hz_high(idx_1h)));
INaL_pct_1Hz = 100 * (INaL_auc_1h - INaL_auc_1b) / INaL_auc_1b;

% Peak ICaL (fast initial peak - full beat window)
ICaL_peak_1b = abs(min(ICaL_1Hz_base(idx_1b)));
ICaL_peak_1h = abs(min(ICaL_1Hz_high(idx_1h)));
ICaL_peak_pct_1Hz = 100 * (ICaL_peak_1h - ICaL_peak_1b) / ICaL_peak_1b;



% -----------------------------
% Print results
% -----------------------------
fprintf('\n===== 1 Hz =====\n');
fprintf('INaL AUC %% change      = %.2f %%\n', INaL_pct_1Hz);
fprintf('Peak ICaL %% change     = %.2f %%\n', ICaL_peak_pct_1Hz);


%% -----------------------------
% Experimental percent changes
% -----------------------------

% ---- ICaL (Xie et al.) ----

% Peak ICaL
ICaL_peak_ctl     = 7.3;
ICaL_peak_ros     = 12.1;
ICaL_peak_ctl_err = 0.8;
ICaL_peak_ros_err = 1.8;

ICaL_peak_exp_pct = 100 * (ICaL_peak_ros - ICaL_peak_ctl) / ICaL_peak_ctl;

ICaL_peak_exp_err = 100 * sqrt( ...
    (ICaL_peak_ros_err / ICaL_peak_ctl)^2 + ...
    ((ICaL_peak_ros * ICaL_peak_ctl_err) / (ICaL_peak_ctl^2))^2 );

fprintf('ICaL Peak: %.2f ± %.2f %%\n', ICaL_peak_exp_pct, ICaL_peak_exp_err);




% ---- INaL (Song et al.) ----

INaL_ctl     = 3.419;
INaL_ros     = 6.215;
INaL_ctl_err = 0.392;
INaL_ros_err = 0.471;

INaL_exp_pct = 100 * (INaL_ros - INaL_ctl) / INaL_ctl;

INaL_exp_pct_err = 100 * sqrt( ...
    (INaL_ros_err / INaL_ctl)^2 + ...
    ((INaL_ros * INaL_ctl_err) / (INaL_ctl^2))^2 );

fprintf('INaL AUC: %.2f ± %.2f %%\n', INaL_exp_pct, INaL_exp_pct_err);

%% -----------------------------
% Plot
% -----------------------------
figure()
set(gcf,'color','w','Position',[100 100 900 1100]);
set(groot, 'defaultLineLineWidth', 3)
set(groot, 'defaultAxesFontSize', 12)

c_base = [0.35 0.35 0.35];
c_ros  = [0.62 0.22 0.40];

c_1000 = [0.45 0.10 0.55];

c_exp  = [0.85 0.85 0.85];

x_min = 0;
x_max = 500;


% =========================================
% Panel A: Experimental INaL percent change
% =========================================
subplot(4,2,1), hold on, set(gca,'box','off','tickdir','out','fontsize',12)

x_exp = 1.0;

% Experimental bar
bar(x_exp, INaL_exp_pct, 0.55, ...
    'FaceColor', c_exp, 'EdgeColor', 'none')

errorbar(x_exp, INaL_exp_pct, INaL_exp_pct_err, 'k', ...
    'LineStyle','none', 'LineWidth',1.5)


xlim([0.4 1.6])
xticks(1)
xticklabels({'\itSong et al., 2006'})
ylabel('INaL AUC % +')
ylim([0 120])
yticks([0 60 120])
set(gca,'TickDir','out','LineWidth',1.5,'FontSize',12)

% =========================================
% Panel B: INaL traces
% =========================================
subplot(4,2,2), hold on, set(gca,'box','off','tickdir','out','fontsize',12)

plot(t_1Hz_base, INaL_1Hz_base, 'Color', c_base, 'DisplayName', 'Basal') 
plot(t_1Hz_high, INaL_1Hz_high, 'Color', c_ros,  'DisplayName', 'High ROS')

ylabel('INaL (µA/µF)')
xlabel('Time (ms)')
xlim([x_min x_max])
xticks([0 500])
ylim([-0.5 0])
yticks([-0.5 -0.25 0])
set(gca,'linewidth',1.5)

legend('Location','southeast','Box','off','Orientation','vertical')

% =========================================
% Panel C: Peak ICaL percent change experimental
% =========================================
subplot(4,2,3), hold on, set(gca,'box','off','tickdir','out','fontsize',12)

x_exp = 1.0;

% Experimental pedestal bar
bar(x_exp, ICaL_peak_exp_pct, 0.55, ...
    'FaceColor', c_exp, 'EdgeColor', 'none');

errorbar(x_exp, ICaL_peak_exp_pct, ICaL_peak_exp_err, 'k', ...
    'LineStyle','none', 'LineWidth',1.5);

xlim([0.4 1.6])
xticks(1)
xticklabels({'\itXie et al., 2009'})
ylabel('Peak ICaL % +')
ylim([0 120])
yticks([0 60 120])
set(gca,'TickDir','out','LineWidth',1.5,'FontSize',12)


% =========================================
% Panel D: ICaL traces
% =========================================
subplot(4,2,4), hold on, set(gca,'box','off','tickdir','out','fontsize',12)

plot(t_1Hz_base, ICaL_1Hz_base, 'Color', c_base, 'DisplayName', 'Basal') 
plot(t_1Hz_high, ICaL_1Hz_high, 'Color', c_ros,  'DisplayName', 'High ROS')

ylabel('ICaL (µA/µF)')
xlabel('Time (ms)')
xlim([x_min x_max])
xticks([0 500])
ylim([-3 0])
yticks([-3 -1.5 0])
set(gca,'linewidth',1.5)

legend('Location','southeast','Box','off','Orientation','vertical')





% =========================================
% Panels 5-8 intentionally empty
% =========================================
subplot(4,2,5); axis off
subplot(4,2,6); axis off
subplot(4,2,7); axis off
subplot(4,2,8); axis off
