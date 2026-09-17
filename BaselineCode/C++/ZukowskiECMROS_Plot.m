%% Figure_HZ_1Hz_Plot.m
%  Loads the baseline 1Hz C++ output and plots all variables in one
%  figure. Columns in the output file (all in mM/mV/native units):
%    1: t (ms)
%    2: v (mV)
%    3: cai (mM)   -> converted to uM for plotting
%    4: ICaL (uA/uF)
%    5: INaL (uA/uF)
%    6: ROSi (mM)  -> converted to uM for plotting
%    7: Cam (mM)   -> converted to uM for plotting
%    8: Psi (mV)

clear; clc; close all

%% -----------------------------
% Load data
% -----------------------------
data = load('output_HZ_1000CL.txt');

t    = data(:,1);
v    = data(:,2);
cai  = data(:,3) * 1000;   % mM -> uM
ICaL = data(:,4);
INaL = data(:,5);
ROSi = data(:,6) * 1000;   % mM -> uM
Cam  = data(:,7) * 1000;   % mM -> uM
Psi  = data(:,8);

%% -----------------------------
% Plot
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

sgtitle('Baseline 1Hz Simulation', 'FontSize', 13, 'FontWeight', 'normal')
