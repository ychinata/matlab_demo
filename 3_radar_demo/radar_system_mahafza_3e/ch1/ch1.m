%% Func:
% Author: xy
% Date: 2022.9.24

clear;
clc;
close all;

%% example.1.3
% 2022.9.24

% input paras
p_peak = 10*10^3;
prf = 30*10^3;          % f_r1=10*10^3, f_r2=30*10^3
pri = 1 / prf;          % prf, T = 10*10^3
p_av = 1500;
dt = p_av / p_peak;
tau = dt * pri;         % pav = 1500

% output paras
% [dt, prf, pav, ep, ru] = pulse_calc(tau, pri, p_peak)
[dt, prf, pav, ep, ru] = pulse_train(tau, pri, p_peak);

% show
% [dt, prf, pav, ep, ru]'
% disp(dt)
% fprintf('dt=%f, prf=%f, pav=%f, ep=%f, ru=%f \n', dt, prf, pav, ep, ru)
fprintf('d_t=%g, PRF=%g Hz, P_av=%g W, E_p=%g J, R_u=%g km\n', dt, prf, pav, ep, ru)     % 显示更为紧凑

%% example.1.4
% 2022.9.25

clear;
clc;
close all;
% input paras
ru = 100*10^3;
B = 0.5*1e6;
c = 3*1e8;

% output paras
prf = c / 2 / ru;
pri = 1 / prf;
delta_R = range_resolution(B);
% disp(delta_R)
tau = 2 * delta_R / c;

% show
fprintf('PRF=%g Hz, PRI=%g ms, Delta_R=%g m, tau=%g us\n', prf, pri*1e3, delta_R, tau*1e6)     % 显示更为紧凑

%% example.1.5
% 2022.9.30
lambda = 0.03;
freq = c / lambda;
ang = 0;                % 角度
v_radar = 250;
v_target = 175;

% 靠近目标
tv = v_radar + v_target;
[fd, ~] = doppler_freq (freq, ang, tv); %% 输入1
fprintf('f_d=%g kHz\n', fd/1e3);

% 远离目标
tv = v_radar - v_target;
[fd, ~] = doppler_freq (freq, ang, tv); %% 输入2
fprintf('f_d=%g kHz\n', fd/1e3);


