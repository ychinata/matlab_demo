% 2023.3.31
% xy
clear;
clc;
tic 
% 参数设置
fs = 5e5;   % 采样率500kHz
fs_iq = fs / 2;
cycle = 1 / fs;  
cycle_iq = 1 / fs_iq;

len = 1000;

% 2023.4.20
% 单路最大采样率500kHz, 周期为0.002ms。每秒0.5M样点，每分30M样点。
% 双路最大采样率250kHz, 周期为0.004ms。每秒0.25M样点，每分15M样点。
% 4.3 共采集16,945,151个点
% 1kHz要下采样到20Hz，减少数据量，50倍抽取
% 1kHz对应1ms一个chirp,即250个I+Q样点(250kHz/1kHz)
% 1kHz对应1s有1000个chirp,即250*1000个I+Q样点(250kHz/1kHz)

% 4.24
% 单路：快时间采样周期2us，1个调制周期1ms有500个；1s有1000个调制周期。1s采样点数：1000个(调制)* 500个(快时间)=500,0000
% 双路：快时间采样周期4us，1个调制周期1ms有250*2个；1s有1000个调制周期。1s采样点数：1000个(慢时间)* 250个*2(快时间)=500,0000

% 首次运行
rawdata = importdata('data/0403-1.txt');    % R2010a运行错误，R2020b运行正常
% rawdata = importdata('data/0403-1-10k.txt');    % R2010a运行错误，R2020b运行正常
% save rawdata.mat
% 第二次运行
% tmp = load('data/0403.mat');
% rawdata = tmp.rawdata;

x = rawdata.data(:, 2);
y_i = rawdata.data(:, 3);
y_q = rawdata.data(:, 4);

plot(x(1:len), y_i(1:len), 'r');
hold on;
plot(x(1:len), y_q(1:len), 'b');

xlabel('(ms)')
ylabel('(mV)')
title('1kHz正弦波，采样率100kHz')

% 4.24 数据处理
fs_slow = 20; % 慢时间频率20Hz，大于呼吸和心跳的频率即可
fs_mod = 1000; % 信号发生器的调制频率
down_sample_rate = fs_mod / fs_slow;
smpno_per_mod = round((1/fs_mod) / (cycle_iq));    % 单个调制周期的快时间采样点数
smpno_per_slow = smpno_per_mod * down_sample_rate;   % 单个慢周期的快时间采样点数
period_no_slow = floor(length(x) / smpno_per_slow);   % 1分钟1200个慢周期

% 抽样1s里的慢时间数据
x_ds = zeros(smpno_per_mod*period_no_slow,1);
for i = 1: period_no_slow
    a1 = smpno_per_mod*(i-1)+1; b1 = smpno_per_mod*i;
    a2 = smpno_per_slow*(i-1)+1;b2 = smpno_per_slow*(i-1)+smpno_per_mod;
    x_ds(a1:b1) = x(a2:b2);
%     x_ds(smpno_per_mod*(i-1)+1, smpno_per_mod*i) = x(smpno_per_slow*(i-1)+1, smpno_per_slow*(i-1)+smpno_per_mod);
end
% 查看下采样结果
x_ds_sample = zeros(period_no_slow, 1);
for i = 1 : period_no_slow
   x_ds_sample(i) = x_ds(smpno_per_mod*(i-1)+1);
end
toc
