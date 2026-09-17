% ord_dox_SA1_generate_parameters.m
% Generates the population parameter matrix for the ORd+DOX model.
%
% Sampling scheme: uniform in [lower_bound, upper_bound] x baseline.
% Default: +/-20%, i.e. each scaling factor drawn from U[0.8, 1.2].
% To change bounds per parameter, edit the lb and ub vectors below.
%
% Output: parameter_ord_dox_pop.mat
%   all_parameters  [N_trials x N_params]  scaling factors
%   param_names     {1 x N_params}         parameter labels
%   lb, ub          [1 x N_params]         bounds used
%   p_fixed         [1 x 200]              fixed settings vector

close all
clear
clc

%% =========================================================
%  CONDUCTANCE PARAMETER DEFINITIONS
%  One row per parameter: { name, lower_bound, upper_bound }
%  Lower and upper bounds are MULTIPLIERS on the baseline (1.0).
%  To change a single parameter range, edit its lb/ub here only.
%  To add a new parameter, append a new row and add the
%  corresponding scaling index in ord_dox_function.m (p(13), etc.)
% =========================================================

param_defs = {
    'GNa',   0.8, 1.2;   % p(1)
    'Gto',   0.8, 1.2;   % p(2)
    'GNaL',  0.8, 1.2;   % p(3)
    'PCa',  0.8, 1.2;   % p(4)
    'GKs',   0.8, 1.2;   % p(5)
    'GK1',   0.8, 1.2;   % p(6)
    'Gncx',  0.8, 1.2;   % p(7)
    'Pnak',  0.8, 1.2;   % p(8)
    'GKb',   0.8, 1.2;   % p(9)
    'PNab',  0.8, 1.2;   % p(10)
    'PCab',  0.8, 1.2;   % p(11)
    'GpCa',  0.8, 1.2;   % p(12)
    % EXPANSION: add rows here, e.g.:
    % 'GNewCurrent', 0.8, 1.2;   % p(13)
};

N_params  = size(param_defs, 1);
param_names = param_defs(:, 1)';   % cell row array of names
lb = cell2mat(param_defs(:, 2)');  % [1 x N_params] lower bounds
ub = cell2mat(param_defs(:, 3)');  % [1 x N_params] upper bounds

%% =========================================================
%  POPULATION SIZE
% =========================================================

N_trials = 1000;   % number of virtual cells; increase for production runs

%% =========================================================
%  UNIFORM SAMPLING
% =========================================================

rng(42);   % fixed seed for reproducibility; change or remove as needed
all_parameters = zeros(N_trials, N_params);
for ii = 1:N_params
    all_parameters(:, ii) = lb(ii) + (ub(ii) - lb(ii)) * rand(N_trials, 1);
end

%% =========================================================
%  FIXED SETTINGS VECTOR  p_fixed
%  Indices 1-12 are filled at runtime from all_parameters.
%  Indices 101-107 are fixed model settings (see ord_dox_function.m).
%  Indices 13-100 are reserved for future conductance parameters.
%  Indices 108+ are reserved for future fixed settings.
% =========================================================

p_fixed = zeros(1, 200);

p_fixed(101) = 0;      % celltype: 0=endo, 1=epi, 2=M
p_fixed(102) = 0.0;    % D: DOX level (1 = full DOX)
p_fixed(103) = 1;      % stim_flag: 1 = pace with stimulus
p_fixed(104) = 500;   % CL: pacing cycle length (ms)
p_fixed(105) = -80;    % stim_amp: stimulus amplitude (uA/uF)
p_fixed(106) = 0;      % stim_start: stimulus start within beat (ms)
p_fixed(107) = 0.5;    % stim_dur: stimulus duration (ms)
% EXPANSION: p_fixed(108) = value; for new fixed settings

%% =========================================================
%  SAVE
% =========================================================

save('parameter_ord_dox_pop.mat', 'all_parameters', 'param_names', 'lb', 'ub', 'p_fixed');
fprintf('Saved %d trials x %d parameters to parameter_ord_dox_pop.mat\n', N_trials, N_params);
