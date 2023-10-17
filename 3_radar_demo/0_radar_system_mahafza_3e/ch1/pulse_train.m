function [dt, prf, pav, ep, ru] = pulse_train(tau, pri, p_peak)
%% Author: Mahafza.3e
%% Date: 2022.9.24
%% Func: 计算占空因子，平均发射功率，脉冲能量和脉冲重复率
%% computes duty cycle, average transmitted power, pulse energy, and pulse repetition frequency

% Inputs:
    %   脉冲宽度    tau    == Pulsewidth in seconds
    %   PRI         pri    == Pulse repetition interval in seconds, or T, or IPP
    %   峰值功率    p_peak == Peak power in Watts
%
% Outputs:
    %   占空因子        dt    == Duty cycle - unitless
    %   PRF             prf   == Pulse repetition frequency in Hz
    %   平均发射功率    pav   == Average power in Watts
    %   脉冲能量        ep    == Pulse energy in Joules
    %   最大非模糊距离  ru    == Unambiguous range in Km
%
    c = 3e8; % speed of light
    dt = tau / pri;
    prf = 1. / pri;             % equ.1.2
    pav = p_peak * dt;          % equ.1.3
    ep = p_peak * tau;          % equ.1.4
    ru = 1.e-3 * c * pri /2.0;  % equ.1.5
return
