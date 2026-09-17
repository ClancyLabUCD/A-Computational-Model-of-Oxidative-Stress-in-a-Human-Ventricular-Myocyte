%% Figure: Mito variables across cycle lengths

%% Load data
% Column order:
% 1 time
% 2 V
% 3 cai
% 4 NADHm
% 5 J_AGC
% 6 V_uni
% 7 J_PDH
% 8 J_mPTP
% 9 V_mNaCa


% 1000 ms CL
file_1000 = load('output3_HZ_1Hz_mito.txt');
t_1000      = file_1000(:,1);
v_1000      = file_1000(:,2);
cai_1000    = file_1000(:,3)*1000;% units µM
NADHm_1000  = file_1000(:,4)*1000;% units µM
JAGC_1000   = file_1000(:,5)*1000; % units µM/ms
Vuni_1000   = file_1000(:,6)*1000; % units µM/ms
JPDH_1000   = file_1000(:,7)*1000; % units µM/ms
JmPTP_1000  = file_1000(:,8)*1000; % units µM/ms
VmNaCa_1000 = file_1000(:,9)*1000; % units µM/ms
JETC_1000   = file_1000(:,10)*1000;% units µM/ms
JANT_1000   = file_1000(:,11)*1000;% units µM/ms
JF1F0_1000  = file_1000(:,12)*1000;% units µM/ms
JHleak_1000 = file_1000(:,13)*1000;% units µM/ms


%% Plot settings
figure()
set(gcf,'color','w','Position',[100 100 1200 1400]);
set(groot, 'defaultLineLineWidth', 3)
set(groot, 'defaultAxesFontSize', 12)

x_min = 0;
x_max = 1000;

% Colors
c1000 = [0.88 0.47 0.12];

% Black/gray shades for NADHm
n1000 = [0.30 0.30 0.30];

color_cai = [0.55 0.30 0.65];   % purple

% 1. Time vs V
subplot(5,2,1), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, v_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('V (mV)')
xlabel('Time (ms)')
%legend('Location','best','Box','off')
set(gca,'linewidth',1.5)
xlim([x_min x_max]) 
xticks([0 1000])
ylim([-100 50])

% 2. AGC
subplot(5,2,2), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, JAGC_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{AGC} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([0.03 0.05])
xticks([0 1000])
yticks([0.03 0.04 0.05])

% 3. Time vs V_uni (label as J_MCU)
subplot(5,2,3), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, Vuni_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{MCU} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([0 0.2])
xticks([0 1000])
yticks([0 0.1 0.2])

% 4. Time vs V_mNaCa (label as J_NCX)
subplot(5,2,4), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, VmNaCa_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{NCX} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([-0.01 0.05])
xticks([0 1000])
yticks([-0.01 0.02 0.05])

% 5. Time vs J_mPTP
subplot(5,2,5), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, JmPTP_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{mPTP} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([-0.5 2])
xticks([0 1000])
yticks([-0.5 0.75 2])

% 6. Time vs J_PDH
subplot(5,2,6), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, JPDH_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{PDH} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([0.026 0.03])
xticks([0 1000])
yticks([0.026 0.028 0.03])

% 7. Time vs J_ETC
subplot(5,2,7), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, JETC_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{ETC} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([0.05 0.09])
xticks([0 1000])
yticks([0.05 0.07 0.09])

% % 8. Time vs NADHm
% subplot(5,2,7), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
% plot(t_1000, NADHm_1000, 'Color', n1000, 'DisplayName', '1000')
% ylabel('NADH_m (µM)')
% xlabel('Time (ms)')
% set(gca,'linewidth',1.5)
% xlim([x_min x_max])
% %ylim([1415 1417])
% xticks([0 1000])
% %yticks([1415 1416 1417])

% 9. Time vs J_AGC
subplot(5,2,8), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, JAGC_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{AGC} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max]) 
ylim([0.03 0.05])
xticks([0 1000])
yticks([0.03 0.04 0.05])

% 10. Time vs J_F1F0
subplot(5,2,9), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, JF1F0_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{ATPASE} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([1.3 1.7])
xticks([0 1000])
yticks([1.3 1.5 1.7])

% 11. Time vs J_Hleak
subplot(5,2,10), hold on, set(gca,'box','off','tickdir','out','fontsize',14)
plot(t_1000, JHleak_1000, 'Color', c1000, 'DisplayName', '1000')
ylabel('J_{HLeak} (µM/ms)')
xlabel('Time (ms)')
set(gca,'linewidth',1.5)
xlim([x_min x_max])
ylim([0.34 0.35])
xticks([0 1000])
yticks([0.34 0.345 0.35])









