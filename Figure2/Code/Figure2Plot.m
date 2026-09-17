%%1000 ms CL 

data1 = load("output_HZ_1000.txt");
t_1000 = data1(:,1);
v_1000 = data1(:,2);
cai_1000 = data1(:,3);
Cam_1000  = data1(:,4);


%%
% Load the data from the text file
data = load('ExpDataAndrienko.txt');  % Ensure this file is in the same directory

data12 = load('ExpDataCollins.txt'); 

Ca_i_uM_Collins = data12(:,1); 
Ca_m_uM_Collins = data12(:,2); 
% Separate the columns
Ca_i_uM = data(:,1);   % Cytosolic Ca2+ [µM]
Ca_m_uM = data(:,2);   % Mitochondrial Ca2+ [µM]

% Asymmetric error bars for Collins et al. (2001)
% Define vertical and horizontal errors
x_err_half = [0, 0.193/2, 0.209/2, 0.101/2, 0.393/2];  % µM
y_err =     [0,      0,     0.397/2,      0,     0.650/2]; % µM

% Define vertical error bars (µM) — half of total width in µM
Ca_m_err_uM = zeros(size(Ca_m_uM));
Ca_m_err_uM(4) = 160 / 1000 / 2;   % ~0.3 µM Ca_i
Ca_m_err_uM(5) = 342 / 1000 / 2;   % ~0.4 µM Ca_i
Ca_m_err_uM(6) = 106 / 1000 / 2;   % ~0.55 µM Ca_i
Ca_m_err_uM(7) = 194 / 1000 / 2;   % ~0.6 µM Ca_i

data4 = load('Output_Ca1.txt');
t_1 = data4(:,1);
v_1 = data4(:,2);
nai_1 = data4(:,3);
cai_1 = data4(:,4);
cam_1 = data4(:,5); 

data5 = load('Output_Ca2.txt');
t_2   = data5(:,1);
v_2   = data5(:,2);
nai_2 = data5(:,3);
cai_2 = data5(:,4);
cam_2 = data5(:,5);

data6 = load('Output_Ca3.txt');
t_3   = data6(:,1);
v_3   = data6(:,2);
nai_3 = data6(:,3);
cai_3 = data6(:,4);
cam_3 = data6(:,5);

data7 = load('Output_Ca4.txt');
t_4   = data7(:,1);
v_4   = data7(:,2);
nai_4 = data7(:,3);
cai_4 = data7(:,4);
cam_4 = data7(:,5);

data8 = load('Output_Ca5.txt');
t_5   = data8(:,1);
v_5   = data8(:,2);
nai_5 = data8(:,3);
cai_5 = data8(:,4);
cam_5 = data8(:,5);

data9 = load('Output_Ca6.txt');
t_6   = data9(:,1);
v_6   = data9(:,2);
nai_6 = data9(:,3);
cai_6 = data9(:,4);
cam_6 = data9(:,5);

data10 = load('Output_Ca7.txt');
t_7    = data10(:,1);
v_7    = data10(:,2);
nai_7  = data10(:,3);
cai_7  = data10(:,4);
cam_7  = data10(:,5);

data11 = load('Output_Ca8.txt');
t_8    = data11(:,1);
v_8    = data11(:,2);
nai_8  = data11(:,3);
cai_8  = data11(:,4);
cam_8  = data11(:,5);

% Final (last-timepoint) values
cai_sim = [ ...
    cai_1(end)*1000, ...
    cai_2(end)*1000, ...
    cai_3(end)*1000, ...
    cai_4(end)*1000, ...
    cai_5(end)*1000, ...
    cai_6(end)*1000, ...
    cai_7(end)*1000, ...
    cai_8(end)*1000 ...
];

cam_sim = [ ...
    cam_1(end)*1000, ...
    cam_2(end)*1000, ...
    cam_3(end)*1000, ...
    cam_4(end)*1000, ...
    cam_5(end)*1000, ...
    cam_6(end)*1000, ...
    cam_7(end)*1000, ...
    cam_8(end)*1000 ...
];


%% 
CL = 1000;
x_min = 0;
 
x_max = 2000; 


%% Ca_i (purple)  — anchor: [0.55 0.30 0.65]
color_cai_2000 = [0.35 0.18 0.45];  % dark purple (Ca_i)
color_cai_1000 = [0.55 0.30 0.65];  % purple (Ca_i)
color_cai_750  = [0.72 0.52 0.80];  % lighter purple (Ca_i)
color_cai_500  = [0.86 0.74 0.92];  % lightest purple (Ca_i)

% Ca_m (magenta/pink) — anchor: [0.78 0.25 0.45]
color_cam_2000 = [0.55 0.12 0.30];  % darker pink / magenta (Ca_m)
color_cam_1000 = [0.78 0.25 0.45];  % dark pink / magenta (Ca_m)
color_cam_750  = [0.88 0.50 0.62];  % lighter pink / magenta (Ca_m)
color_cam_500  = [0.95 0.74 0.82];  % lightest pink / magenta (Ca_m)


%% Figure

figure()
set(gcf,'color','w','Position',[100 100 900 900]);
set(groot, 'defaultLineLineWidth', 3)
set(groot, 'defaultAxesFontSize', 12)

% Subplot 1: time traces
subplot(2,1,1), hold on, set(gca,'box','off','tickdir','out','fontsize',14)

p1 = plot(t_1000, cai_1000*1000, 'LineWidth', 3, 'Color', color_cai_1000);
p2 = plot(t_1000, Cam_1000*1000, 'LineWidth', 3, 'Color', color_cam_1000);

ylabel('[Ca^{2+}] (\muM)')
xlabel('Time (ms)')
legend([p1 p2], {'[Ca^{2+}]_i', '[Ca^{2+}]_m'}, ...
    'Location','northeast','Box','off')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
xticks([0 500 1000 1500 2000])
ylim([0.15 0.35])
yticks([0.15 0.25 0.35])

% Subplot 2: scatter overlay
subplot(2,1,2), hold on, set(gca,'box','off','tickdir','out','fontsize',14)

% Colors
expColor  = [0.3 0.3 0.3];
exp2Color = [0.6 0.6 0.6];
simColor  = color_cam_1000;

% Dataset 1: Experimental (Andrienko/Bers)
p_exp1 = scatter(Ca_i_uM, Ca_m_uM, 90, ...
    'o', 'MarkerEdgeColor', expColor, 'MarkerFaceColor', expColor, ...
    'LineWidth', 2, ...
    'DisplayName', 'Experimental (\itAndrienko et al., 2009)');

idx_err = Ca_m_err_uM > 0;
errorbar(Ca_i_uM(idx_err), Ca_m_uM(idx_err), Ca_m_err_uM(idx_err), ...
    'LineStyle','none', 'Color', expColor, 'LineWidth', 2, 'CapSize', 10, ...
    'HandleVisibility','off');

% Dataset 2: Experimental (Collins)
p_exp2 = scatter(Ca_i_uM_Collins, Ca_m_uM_Collins, 90, ...
    'o', 'MarkerEdgeColor', exp2Color, 'MarkerFaceColor', exp2Color, ...
    'LineWidth', 2, ...
    'DisplayName', 'Experimental (\itCollins et al., 2001)');

% vertical error bars
idx_y = y_err > 0;
errorbar(Ca_i_uM_Collins(idx_y), Ca_m_uM_Collins(idx_y), y_err(idx_y), ...
    'LineStyle','none', 'Color', exp2Color, 'LineWidth', 1.8, 'CapSize', 10, ...
    'HandleVisibility','off');

% horizontal error bars (manual)
cap_size = 0.02;
for i = 1:length(Ca_i_uM_Collins)
    if x_err_half(i) > 0
        xL = Ca_i_uM_Collins(i) - x_err_half(i);
        xR = Ca_i_uM_Collins(i) + x_err_half(i);
        y  = Ca_m_uM_Collins(i);

        plot([xL xR], [y y], '-', 'Color', exp2Color, 'LineWidth', 1.8, ...
            'HandleVisibility','off');
        plot([xL xL], [y-cap_size y+cap_size], '-', 'Color', exp2Color, 'LineWidth', 1.8, ...
            'HandleVisibility','off');
        plot([xR xR], [y-cap_size y+cap_size], '-', 'Color', exp2Color, 'LineWidth', 1.8, ...
            'HandleVisibility','off');
    end
end

% Dataset 3: Simulation
p_sim = scatter(cai_sim, cam_sim, 90, ...
    'o', 'MarkerEdgeColor', simColor, 'MarkerFaceColor', simColor, ...
    'LineWidth', 2, ...
    'DisplayName', 'Simulation');

ylabel('[Ca^{2+}]_m (\muM)')
xlabel('[Ca^{2+}]_i (\muM)')
legend([p_exp1 p_exp2 p_sim], 'Location','northwest','Box','off')
set(gca,'linewidth',1.5)
xlim([0 0.8])
ylim([-0.2 1.2])
xticks([0 0.2 0.4 0.6 0.8])
yticks([-0.2 0.15 0.5 0.85 1.2])
