% 2023.4.24 下采样
% 每隔12500个adc点数保留250个,即50倍下采样
%% 
% 原始数据
%  /|  /|  /|     /|  /|
% / | / | / |    / | / |
%/  |/  |/  |.../  |/  |
% 抽样后数据（每50个锯齿波抽样1个）
%  /|              /|
% / |             / |
%/  |____________/  |
%%
% 入参
% x

% 参数设置
fs = 5e5;   % 采样率500kHz
fs_iq = fs / 2;
cycle = 1 / fs;  
cycle_iq = 1 / fs_iq;

tic 
fs_slow = 20; % 慢时间频率20Hz，大于呼吸和心跳的频率即可
fs_mod = 1000; % 信号发生器的调制频率
down_sample_rate = fs_mod / fs_slow;                % 50倍
smpno_per_mod = round((1/fs_mod) / (cycle_iq));    % 单个调制周期的快时间采样点数250
smpno_per_slow = smpno_per_mod * down_sample_rate;   % 单个慢周期的快时间采样点数12500
period_no_slow = floor(length(x) / smpno_per_slow);   % 1分钟1200个慢周期

% 抽样1s里的慢时间数据, 250*20=5000.每隔12500个adc点数保留250个,即50倍下采样
x_ds = zeros(smpno_per_mod*period_no_slow, 1);
y_ids = zeros(smpno_per_mod*period_no_slow, 1);
y_qds = zeros(smpno_per_mod*period_no_slow, 1);
for i = 1: period_no_slow
    i;
    a1 = smpno_per_mod*(i-1)+1;
    b1 = smpno_per_mod*i;
    a2 = smpno_per_slow*(i-1)+1;
    b2 = smpno_per_slow*(i-1)+smpno_per_mod;
    x_ds(a1:b1) = x(a2:b2);
    y_ids(a1:b1) = y_i(a2:b2);
    y_qds(a1:b1) = y_q(a2:b2);
end

x_ds_sample = zeros(period_no_slow, 1);
y_ids_sample = zeros(period_no_slow, 1);
y_qds_sample = zeros(period_no_slow, 1);
for i = 1 : period_no_slow
   x_ds_sample(i) = x_ds(smpno_per_mod*(i-1)+1);
   y_ids_sample(i) = y_ids(smpno_per_mod*(i-1)+1);
   y_qds_sample(i) = y_qds(smpno_per_mod*(i-1)+1);
end

% save x_ds.mat
% save y_ids.mat
% save y_qds.mat

% save x_ds_sample.mat % 1个.mat 300M，太大了，应该用txt保存
% save y_ids_sample.mat
% save y_qds_sample.mat
% clear x_ds_sample
% clear y_ids_sample
% clear y_qds_sample

toc