%% run_ZukowskiECMROS_and_plot.m
%  Runs the MATLAB ZukowskiECMROS simulation, then loads its output file
%  and produces the same 7-panel summary plot as the C++ version.
%
%  zukowskiECMROS() writes 33 columns to output3_1Hz.txt:
%    1:t  2:v  3:cai  4:cass  5:cansr  6:cajsr  7:Jrel  8:Jup  9:INa
%    10:INaL  11:Ito  12:ICaL  13:ICaNa  14:ICaK  15:IKr  16:IKs  17:IK1
%    18:INaCa_i  19:INaCa_ss  20:INaCa  21:INaK  22:IKb  23:INab  24:IpCa
%    25:ICab  26:APD  27:ROSi  28:ROSm  29:H2O2  30:GSH  31:Psi  32:NADHm
%    33:Cam
%
%  Only the same 7 variables plotted in the C++ version are pulled out:
%  v, cai, ICaL, INaL, ROSi, Cam, Psi (cai/ROSi/Cam converted mM -> uM).

clear; clc; close all

%% -----------------------------
% Run the simulation
% -----------------------------
zukowskiECMROS();

%% -----------------------------
% Load output and extract matching columns
% -----------------------------
data = load('output3_1Hz.txt');

t    = data(:,1);
v    = data(:,2);
cai  = data(:,3)  * 1000;   % mM -> uM
ICaL = data(:,12);
INaL = data(:,10);
ROSi = data(:,27) * 1000;   % mM -> uM
Psi  = data(:,31);
Cam  = data(:,33) * 1000;   % mM -> uM

%% -----------------------------
% Plot (matches Figure_HZ_1Hz_Plot.m layout)
% -----------------------------
figure('Color','w','Position',[100 100 1000 800]);
set(groot, 'defaultLineLineWidth', 2)
set(groot, 'defaultAxesFontSize', 11)

c = [0.2 0.2 0.2];

subplot(4,2,1)
plot(t, v, 'Color', c)
ylabel('V (mV)')
xlabel('Time (ms)')
box off; set(gca,'TickDir','out')

subplot(4,2,2)
plot(t, cai, 'Color', [0.5 0.0 0.5])
ylabel('[Ca^{2+}]_i (\muM)')
xlabel('Time (ms)')
box off; set(gca,'TickDir','out')

subplot(4,2,3)
plot(t, ICaL, 'Color', [0.1 0.4 0.8])
ylabel('I_{CaL} (\muA/\muF)')
xlabel('Time (ms)')
box off; set(gca,'TickDir','out')

subplot(4,2,4)
plot(t, INaL, 'Color', [0.8 0.3 0.1])
ylabel('I_{NaL} (\muA/\muF)')
xlabel('Time (ms)')
box off; set(gca,'TickDir','out')

subplot(4,2,5)
plot(t, ROSi, 'Color', [0.1 0.4 0.8])
ylabel('ROS_i (\muM)')
xlabel('Time (ms)')
box off; set(gca,'TickDir','out')

subplot(4,2,6)
plot(t, Cam, 'Color', [0.85 0.1 0.5])
ylabel('[Ca^{2+}]_m (\muM)')
xlabel('Time (ms)')
box off; set(gca,'TickDir','out')

subplot(4,2,7)
plot(t, Psi, 'Color', [0.1 0.55 0.1])
ylabel('\Psi_m (mV)')
xlabel('Time (ms)')
box off; set(gca,'TickDir','out')

sgtitle('Baseline 1Hz Simulation (MATLAB)', 'FontSize', 13, 'FontWeight', 'normal')
