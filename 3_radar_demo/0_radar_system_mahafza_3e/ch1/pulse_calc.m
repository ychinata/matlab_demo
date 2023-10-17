function [dt, prf, pav, ep, ru] = pulse_calc(tau, pri, p_peak)
% Author: Mahafza.3e
% Date: 2022.9.24
% Func: ����ռ�����ӣ�ƽ�����书�ʣ����������������ظ��� 
% (�����磬��ʱ�ᱨδ�����type double���󣬲�֪ԭ��)pulse_train����pulse_calc��֤
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
