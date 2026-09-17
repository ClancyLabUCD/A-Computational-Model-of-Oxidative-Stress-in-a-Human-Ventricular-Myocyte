% plot_pause_traces.m
clear, clc, close all
load('outputs_pause_D0IKr0.mat', 'V_all', 'Cai_all', 'Cam_all', 'ROSi_all', 'ICaL_all', 't_grid');

col_V    = [0.4  0.4  0.4];
col_ICaL = [0.2  0.6  0.8];   % teal for ICaL
col_Cai  = [0.5  0.0  0.5];
col_Cam  = [0.85 0.1  0.5];
col_ROSi = [0.1  0.4  0.8];

valid   = find(~all(isnan(V_all), 2));
n_valid = length(valid);
fprintf('%d valid trials to plot\n', n_valid);

figure('Color','w','Position',[100 100 400 1000]);
ax1 = subplot(5,1,1); hold on
ax2 = subplot(5,1,2); hold on
ax3 = subplot(5,1,3); hold on
ax4 = subplot(5,1,4); hold on
ax5 = subplot(5,1,5); hold on

for ii = 1:n_valid
    idx  = valid(ii);
    t    = t_grid;
    v    = V_all(idx,:)';
    ical = ICaL_all(idx,:)';
    cai  = Cai_all(idx,:)';
    cam  = Cam_all(idx,:)';
    rosi = ROSi_all(idx,:)';

    plot(ax1, t, v,    'Color', [col_V    0.5], 'LineWidth', 0.8)
    plot(ax2, t, ical, 'Color', [col_ICaL 0.5], 'LineWidth', 0.8)
    plot(ax3, t, cai,  'Color', [col_Cai  0.5], 'LineWidth', 0.8)
    plot(ax4, t, cam,  'Color', [col_Cam  0.5], 'LineWidth', 0.8)
    plot(ax5, t, rosi, 'Color', [col_ROSi 0.5], 'LineWidth', 0.8)
end

ylabel(ax1, 'V_m (mV)',              'FontSize', 12)
ylabel(ax2, 'I_{CaL} (A/F)',         'FontSize', 12)
ylabel(ax3, '[Ca^{2+}]_i (\muM)',    'FontSize', 12)
ylabel(ax4, '[Ca^{2+}]_m (\muM)',    'FontSize', 12)
ylabel(ax5, 'ROS_i (\muM)',          'FontSize', 12)
xlabel(ax5, 'Time (ms)',             'FontSize', 12)

for ax = [ax1 ax2 ax3 ax4 ax5]
    box(ax, 'off')
    set(ax, 'FontSize', 12, 'LineWidth', 1.0, 'TickDir', 'out')
end

title(ax1, 'Post-pause beat — D=0, IKr=0% Block', 'FontSize', 12, 'FontWeight', 'normal')
