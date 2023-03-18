%% 2023.3.31
% xy

%{
ART_DAQ_USB2086 原始数据格式：

时间单位:mS, 转换单位: 毫伏
Index	  Tims        AI00      AI01      
     0    0.00000   2610.17   2380.37 
     1    0.00400   2622.07   2337.95 
     2    0.00800   2626.34   2303.47 
     3    0.01200   2628.48   2260.74 
     4    0.01600   2630.92   2221.07 
     5    0.02000   2622.38   2185.36 
     6    0.02400   2608.34   2145.39 
     7    0.02800   2598.57   2109.07 
     8    0.03200   2580.87   2079.47 
     9    0.03600   2560.12   2043.46 
%}

%% 
clear;
clc;

% 参数设置
fs = 1e5;   % 采样率100kHz, 0.01ms
cycle = 1 / fs;
len = 1000;
% 

% 首次运行
% rawdata = importdata('data/0331.txt');
rawdata = importdata('0403.txt');
% save rawdata.mat

% 第二次运行
% tmp = load('data/0331.mat');
% rawdata = tmp.rawdata;

x = rawdata.data(:, 2);
y = rawdata.data(:, 3);
plot(x(1:len), y(1:len));
xlabel('(ms)')
ylabel('(mV)')
title('1kHz正弦波，采样率100kHz')
