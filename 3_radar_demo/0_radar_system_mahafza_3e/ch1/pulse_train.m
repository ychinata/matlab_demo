function [dt, prf, pav, ep, ru] = pulse_train(tau, pri, p_peak)
%% Author: Mahafza.3e
%% Date: 2022.9.24
%% Func: ����ռ�����ӣ�ƽ�����书�ʣ����������������ظ���
%% computes duty cycle, average transmitted power, pulse energy, and pulse repetition frequency

% Inputs:
    %   ������    tau    == Pulsewidth in seconds
    %   PRI         pri    == Pulse repetition interval in seconds, or T, or IPP
    %   ��ֵ����    p_peak == Peak power in Watts
%
% Outputs:
    %   ռ������        dt    == Duty cycle - unitless
    %   PRF             prf   == Pulse repetition frequency in Hz
    %   ƽ�����书��    pav   == Average power in Watts
    %   ��������        ep    == Pulse energy in Joules
    %   ����ģ������  ru    == Unambiguous range in Km
%
    c = 3e8; % speed of light
    dt = tau / pri;
    prf = 1. / pri;             % equ.1.2
    pav = p_peak * dt;          % equ.1.3
    ep = p_peak * tau;          % equ.1.4
    ru = 1.e-3 * c * pri /2.0;  % equ.1.5
return
