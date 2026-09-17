%% Summary PLOT
%% Summary Figure: %ΔCai vs %ΔROSi

clear; clc;

%% =========================
% Load files: 1000 ms CL
% =========================
base = load('output_1000CL_100perCai.txt');

inc10 = load('output_1000CL_10perCai.txt');
inc20 = load('output_1000CL_20perCai.txt');
inc30 = load('output_1000CL_30perCai.txt');
inc40 = load('output_1000CL_40perCai.txt');
inc50 = load('output_1000CL_50perCai.txt');

%% =========================
% Load files: 750 ms CL
% =========================
base750 = load('output_750CL_100perCai.txt');

inc10750 = load('output_750CL_10perCai.txt');
inc20750 = load('output_750CL_20perCai.txt');
inc30750 = load('output_750CL_30perCai.txt');
inc40750 = load('output_750CL_40perCai.txt');
inc50750 = load('output_750CL_50perCai.txt');

%% =========================
%Load files: 2000 ms CL
% =========================
base2000 = load('output_2000CL_100perCai.txt');

inc102000 = load('output_2000CL_10perCai.txt');
inc202000 = load('output_2000CL_20perCai.txt');
inc302000 = load('output_2000CL_30perCai.txt');
inc402000 = load('output_2000CL_40perCai.txt');
inc502000 = load('output_2000CL_50perCai.txt');

%% =========================
% Load files: 500 ms CL
% =========================
base500 = load('output_500CL_100perCai.txt');

inc10500 = load('output_500CL_10perCai.txt');
inc20500 = load('output_500CL_20perCai.txt');
inc30500 = load('output_500CL_30perCai.txt');
inc40500 = load('output_500CL_40perCai.txt');
inc50500 = load('output_500CL_50perCai.txt');

%% =========================
% Extract variables
% Columns:
% 1 t, 2 v, 3 cai, 4 Psi, 5 Cam, 6 J_ETC, 7 ROSi
% =========================

% 1000 ms
t_base    = base(:,1);
cai_base  = base(:,3);
ROSi_base = base(:,7);

cai_10  = inc10(:,3);  ROSi_10  = inc10(:,7);
cai_20  = inc20(:,3);  ROSi_20  = inc20(:,7);
cai_30  = inc30(:,3);  ROSi_30  = inc30(:,7);
cai_40  = inc40(:,3);  ROSi_40  = inc40(:,7);
cai_50  = inc50(:,3);  ROSi_50  = inc50(:,7);

% 750 ms
t_base_750    = base750(:,1);
cai_base_750  = base750(:,3);
ROSi_base_750 = base750(:,7);

cai_10_750  = inc10750(:,3);  ROSi_10_750  = inc10750(:,7);
cai_20_750  = inc20750(:,3);  ROSi_20_750  = inc20750(:,7);
cai_30_750  = inc30750(:,3);  ROSi_30_750  = inc30750(:,7);
cai_40_750  = inc40750(:,3);  ROSi_40_750  = inc40750(:,7);
cai_50_750  = inc50750(:,3);  ROSi_50_750  = inc50750(:,7);

% 2000 ms
t_base_2000    = base2000(:,1);
cai_base_2000  = base2000(:,3);
ROSi_base_2000 = base2000(:,7);

cai_10_2000  = inc102000(:,3);  ROSi_10_2000  = inc102000(:,7);
cai_20_2000  = inc202000(:,3);  ROSi_20_2000  = inc202000(:,7);
cai_30_2000  = inc302000(:,3);  ROSi_30_2000  = inc302000(:,7);
cai_40_2000  = inc402000(:,3);  ROSi_40_2000  = inc402000(:,7);
cai_50_2000  = inc502000(:,3);  ROSi_50_2000  = inc502000(:,7);

% 500 ms
t_base_500    = base500(:,1);
cai_base_500  = base500(:,3);
ROSi_base_500 = base500(:,7);

cai_10_500  = inc10500(:,3);  ROSi_10_500  = inc10500(:,7);
cai_20_500  = inc20500(:,3);  ROSi_20_500  = inc20500(:,7);
cai_30_500  = inc30500(:,3);  ROSi_30_500  = inc30500(:,7);
cai_40_500  = inc40500(:,3);  ROSi_40_500  = inc40500(:,7);
cai_50_500  = inc50500(:,3);  ROSi_50_500  = inc50500(:,7);

%% =========================
% Compute % change relative to baseline
% =========================

% 1000 ms
pct_cai_10 = 100 * (cai_10 - cai_base) ./ cai_base;
pct_cai_20 = 100 * (cai_20 - cai_base) ./ cai_base;
pct_cai_30 = 100 * (cai_30 - cai_base) ./ cai_base;
pct_cai_40 = 100 * (cai_40 - cai_base) ./ cai_base;
pct_cai_50 = 100 * (cai_50 - cai_base) ./ cai_base;

pct_ROSi_10 = 100 * (ROSi_10 - ROSi_base) ./ ROSi_base;
pct_ROSi_20 = 100 * (ROSi_20 - ROSi_base) ./ ROSi_base;
pct_ROSi_30 = 100 * (ROSi_30 - ROSi_base) ./ ROSi_base;
pct_ROSi_40 = 100 * (ROSi_40 - ROSi_base) ./ ROSi_base;
pct_ROSi_50 = 100 * (ROSi_50 - ROSi_base) ./ ROSi_base;

% 750 ms
pct_cai_10_750 = 100 * (cai_10_750 - cai_base_750) ./ cai_base_750;
pct_cai_20_750 = 100 * (cai_20_750 - cai_base_750) ./ cai_base_750;
pct_cai_30_750 = 100 * (cai_30_750 - cai_base_750) ./ cai_base_750;
pct_cai_40_750 = 100 * (cai_40_750 - cai_base_750) ./ cai_base_750;
pct_cai_50_750 = 100 * (cai_50_750 - cai_base_750) ./ cai_base_750;

pct_ROSi_10_750 = 100 * (ROSi_10_750 - ROSi_base_750) ./ ROSi_base_750;
pct_ROSi_20_750 = 100 * (ROSi_20_750 - ROSi_base_750) ./ ROSi_base_750;
pct_ROSi_30_750 = 100 * (ROSi_30_750 - ROSi_base_750) ./ ROSi_base_750;
pct_ROSi_40_750 = 100 * (ROSi_40_750 - ROSi_base_750) ./ ROSi_base_750;
pct_ROSi_50_750 = 100 * (ROSi_50_750 - ROSi_base_750) ./ ROSi_base_750;

% 2000 ms
pct_cai_10_2000 = 100 * (cai_10_2000 - cai_base_2000) ./ cai_base_2000;
pct_cai_20_2000 = 100 * (cai_20_2000 - cai_base_2000) ./ cai_base_2000;
pct_cai_30_2000 = 100 * (cai_30_2000 - cai_base_2000) ./ cai_base_2000;
pct_cai_40_2000 = 100 * (cai_40_2000 - cai_base_2000) ./ cai_base_2000;
pct_cai_50_2000 = 100 * (cai_50_2000 - cai_base_2000) ./ cai_base_2000;

pct_ROSi_10_2000 = 100 * (ROSi_10_2000 - ROSi_base_2000) ./ ROSi_base_2000;
pct_ROSi_20_2000 = 100 * (ROSi_20_2000 - ROSi_base_2000) ./ ROSi_base_2000;
pct_ROSi_30_2000 = 100 * (ROSi_30_2000 - ROSi_base_2000) ./ ROSi_base_2000;
pct_ROSi_40_2000 = 100 * (ROSi_40_2000 - ROSi_base_2000) ./ ROSi_base_2000;
pct_ROSi_50_2000 = 100 * (ROSi_50_2000 - ROSi_base_2000) ./ ROSi_base_2000;

% 500 ms
pct_cai_10_500 = 100 * (cai_10_500 - cai_base_500) ./ cai_base_500;
pct_cai_20_500 = 100 * (cai_20_500 - cai_base_500) ./ cai_base_500;
pct_cai_30_500 = 100 * (cai_30_500 - cai_base_500) ./ cai_base_500;
pct_cai_40_500 = 100 * (cai_40_500 - cai_base_500) ./ cai_base_500;
pct_cai_50_500 = 100 * (cai_50_500 - cai_base_500) ./ cai_base_500;

pct_ROSi_10_500 = 100 * (ROSi_10_500 - ROSi_base_500) ./ ROSi_base_500;
pct_ROSi_20_500 = 100 * (ROSi_20_500 - ROSi_base_500) ./ ROSi_base_500;
pct_ROSi_30_500 = 100 * (ROSi_30_500 - ROSi_base_500) ./ ROSi_base_500;
pct_ROSi_40_500 = 100 * (ROSi_40_500 - ROSi_base_500) ./ ROSi_base_500;
pct_ROSi_50_500 = 100 * (ROSi_50_500 - ROSi_base_500) ./ ROSi_base_500;

% =========================
% Extract peak responses
% =========================

peak_ROSi = [ ...
    max(pct_ROSi_10), ...
    max(pct_ROSi_20), ...
    max(pct_ROSi_30), ...
    max(pct_ROSi_40), ...
    max(pct_ROSi_50) ...
];

peak_ROSi_750 = [ ...
    max(pct_ROSi_10_750), ...
    max(pct_ROSi_20_750), ...
    max(pct_ROSi_30_750), ...
    max(pct_ROSi_40_750), ...
    max(pct_ROSi_50_750) ...
];

peak_ROSi_2000 = [ ...
    max(pct_ROSi_10_2000), ...
    max(pct_ROSi_20_2000), ...
    max(pct_ROSi_30_2000), ...
    max(pct_ROSi_40_2000), ...
    max(pct_ROSi_50_2000) ...
];

peak_ROSi_500 = [ ...
    max(pct_ROSi_10_500), ...
    max(pct_ROSi_20_500), ...
    max(pct_ROSi_30_500), ...
    max(pct_ROSi_40_500), ...
    max(pct_ROSi_50_500) ...
];

% Add baseline point (0,0)
peak_ROSi      = [0 peak_ROSi];
peak_ROSi_750  = [0 peak_ROSi_750];
peak_ROSi_2000 = [0 peak_ROSi_2000];
peak_ROSi_500  = [0 peak_ROSi_500];


%% =========================
% Extract actual peak % change in Cai
% =========================

peak_Cai = [ ...
    max(pct_cai_10), ...
    max(pct_cai_20), ...
    max(pct_cai_30), ...
    max(pct_cai_40), ...
    max(pct_cai_50) ...
];

peak_Cai_750 = [ ...
    max(pct_cai_10_750), ...
    max(pct_cai_20_750), ...
    max(pct_cai_30_750), ...
    max(pct_cai_40_750), ...
    max(pct_cai_50_750) ...
];

peak_Cai_2000 = [ ...
    max(pct_cai_10_2000), ...
    max(pct_cai_20_2000), ...
    max(pct_cai_30_2000), ...
    max(pct_cai_40_2000), ...
    max(pct_cai_50_2000) ...
];

peak_Cai_500 = [ ...
    max(pct_cai_10_500), ...
    max(pct_cai_20_500), ...
    max(pct_cai_30_500), ...
    max(pct_cai_40_500), ...
    max(pct_cai_50_500) ...
];

% Add baseline point
peak_Cai      = [0 peak_Cai];
peak_Cai_750  = [0 peak_Cai_750];
peak_Cai_2000 = [0 peak_Cai_2000];
peak_Cai_500  = [0 peak_Cai_500];

%% =========================
% Plot
% =========================

figure()
subplot(1,1,1), hold on, set(gca,'box','off','tickdir','out','fontsize',12)
set(gcf,'color','w','Position',[100 100 700 550])
set(groot, 'defaultLineLineWidth', 2)


hold on
set(gca,'box','off','tickdir','out','fontsize',14)

%x_vals = [0 10 20 30 40 50];

c2000 = [0.00 0.20 0.50];   % darkest (2000 ms)
c1000 = [0.10 0.40 0.70];   % medium-dark
c750  = [0.30 0.60 0.85];   % medium-light
c500  = [0.60 0.80 0.95];   % lightest (500 ms)

% Linear reference
%x_ref = linspace(0,50,100);
%plot(x_ref, x_ref, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.5, ...
   % 'HandleVisibility', 'off')

% Scatter
scatter(peak_Cai_2000, peak_ROSi_2000, 80, 'filled', ...
    'MarkerFaceColor', c2000, 'DisplayName', 'CL = 2000 ms')
scatter(peak_Cai, peak_ROSi, 80, 'filled', ...
    'MarkerFaceColor', c1000, 'DisplayName', 'CL = 1000 ms')
scatter(peak_Cai_750, peak_ROSi_750, 80, 'filled', ...
    'MarkerFaceColor', c750, 'DisplayName', 'CL = 750 ms')
scatter(peak_Cai_500, peak_ROSi_500, 80, 'filled', ...
    'MarkerFaceColor', c500, 'DisplayName', 'CL = 500 ms')

plot(peak_Cai_2000, peak_ROSi_2000, 'Color', c2000, 'LineWidth', 2, 'HandleVisibility', 'off')
plot(peak_Cai,      peak_ROSi,      'Color', c1000, 'LineWidth', 2, 'HandleVisibility', 'off')
plot(peak_Cai_750,  peak_ROSi_750,  'Color', c750,  'LineWidth', 2, 'HandleVisibility', 'off')
plot(peak_Cai_500,  peak_ROSi_500,  'Color', c500,  'LineWidth', 2, 'HandleVisibility', 'off')

%text(45, 65, 'Linear', 'Color', [0.3 0.3 0.3], 'FontSize', 10, 'FontWeight', 'bold')

xlabel('% increase cai')
ylabel('% increase ROSi')

set(gca,'linewidth',1.5)
xlim([0 60])
ylim([0 100])
xticks([0 30 60])
yticks([0 50 100])

%legend('Location','northoutside','Box','off','Orientation', 'horizontal')

%subplot(4,2,2), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
%subplot(4,2,3), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
%subplot(4,2,4), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
%subplot(4,2,5), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
%subplot(4,2,6), hold on, set(gca,'box','off','tickdir','out','fontsize',14)



%% =========================================================
%  EXTRACT QUANTITATIVE VALUES — Fig 4F (Cai vs ROSi across CL)
% =========================================================

fprintf('\n=== Fig 4F: Peak %%ROSi at each Cai perturbation level across CL ===\n\n');
fprintf('%-15s  %10s  %10s  %10s  %10s\n', 'Cai Perturbation', 'CL=2000ms', 'CL=1000ms', 'CL=750ms', 'CL=500ms');
fprintf('%s\n', repmat('-', 1, 60));

cai_levels = {'10%', '20%', '30%', '40%', '50%'};
for i = 1:5
    fprintf('%-15s  %10.2f  %10.2f  %10.2f  %10.2f\n', ...
        cai_levels{i}, ...
        peak_ROSi_2000(i+1), ...
        peak_ROSi(i+1), ...
        peak_ROSi_750(i+1), ...
        peak_ROSi_500(i+1));
end

fprintf('\n=== ROS amplification ratio (%%ROSi / %%Cai) at 50%% Cai perturbation ===\n\n');
fprintf('%-15s  %10.2f\n', 'CL=2000ms', peak_ROSi_2000(6) / peak_Cai_2000(6));
fprintf('%-15s  %10.2f\n', 'CL=1000ms', peak_ROSi(6)      / peak_Cai(6));
fprintf('%-15s  %10.2f\n', 'CL=750ms',  peak_ROSi_750(6)  / peak_Cai_750(6));
fprintf('%-15s  %10.2f\n', 'CL=500ms',  peak_ROSi_500(6)  / peak_Cai_500(6));

fprintf('\n=== Fold increase in ROSi amplification: CL=500ms vs CL=2000ms ===\n');
for i = 1:5
    ratio = peak_ROSi_500(i+1) / peak_ROSi_2000(i+1);
    fprintf('  At +%s Cai: %.2fx greater ROSi at 500ms vs 2000ms\n', cai_levels{i}, ratio);
end
fprintf('\n');
