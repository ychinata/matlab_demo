function [dt, prf, pav, ep, ru] = pulse_calc(tau, pri, p_peak)
% Author: Mahafza.3e
% Date: 2022.9.24
% Func: 计算占空因子，平均发射功率，脉冲能量和脉冲重复率 
% (程序抽风，有时会报未定义的type double错误，不知原因)pulse_train改名pulse_calc验证
% computes duty cycle, average transmitted power, pulse energy, and pulse repetition frequency

% Inputs:
    %   tau    == Pulsewidth in seconds
    %   pri    == Pulse repetition interval in seconds, or T, or IPP
    %   p_peak == Peak power in Watts
%
% Outputs:
    %   dt    == Duty cycle - unitless
    %   prf   == Pulse repetition frequency in Hz
    %   pa    == Average power in Watts
    %   ep    == Pulse energy in Joules
    %   ru    == Unambiguous range in Km
    c = 3e8; % speed of light
    dt = tau / pri;
    prf = 1. / pri;             % equ.1.2
    pav = p_peak * dt;          % equ.1.3
    ep = p_peak * tau;          % equ.1.4
    ru = 1.e-3 * c * pri /2.0;  % equ.1.5
% return
