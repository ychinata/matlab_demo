% 2023.4.3
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

% clear;
% clc;
close

% 参数设置
fs = 5e5;   % 采样率500kHz=0.5MHz, 2us, 1min采样30M样点
cycle = 1 / fs;
len = 10000;
% 

% 16945151点，20230403采集约1分钟

% 首次运行
% rawdata = importdata('data/0403-1.txt');
% save rawdata.mat
% 第二次运行
% tmp = load('data/0403.mat');
% rawdata = tmp.rawdata;
% rawdata = importdata('0403.txt');
rawdata = importdata('../data/0403-1-1k.txt');
rawdata = importdata('../data/0403-1-10k.txt');


x = rawdata.data(:, 2);
y_i = rawdata.data(:, 3);
y_q = rawdata.data(:, 4);

plot(x(1:len), y_i(1:len), 'r');
hold on;
plot(x(1:len), y_q(1:len), 'b');

xlabel('(ms)')
ylabel('(mV)')
title('1kHz正弦波，采样率100kHz')
