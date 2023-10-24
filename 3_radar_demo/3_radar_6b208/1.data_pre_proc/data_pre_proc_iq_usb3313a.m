%% 2023.10.19
% USB3313A data pre proc 

%{ 
USB 3133A数据格式
文件标志:DAQ
采样率:250000
通道数:2
电压_0,电压_1
2.26354151881605,2.25659792010391
2.24397319517275,2.23197970648814
2.22030183592682,2.21209576472156
2.19505238606449,2.19442114981793
2.16759360933921,2.18337451550317
2.14045045073721,2.17453720805135
2.1104667290257,2.16854046370905
%}
tic;
clear;
clc;
close all;

% filename = '../data/20231019/1019_iq_24g_500k_3_1.csv';
filenameOpen = '../data/data_orig/20231024/1024_500k_1p2m_1_3.csv';
filenameSave = '../data/data_proc/process_adc_1x_1024_1p2_xy.mat';

dataRaw = importdata(filenameOpen);

freq_s = 250000;
t_gap = 1 / freq_s;

y_i = dataRaw.data(:, 1);
y_q = dataRaw.data(:, 2);
data_len = size(y_i);

x_t = 0 : t_gap : (data_len-1)*t_gap;
x_t = x_t';

plot_len = 1000;
plot(x_t(1:plot_len), y_i(1:plot_len), 'r');
hold on;
plot(x_t(1:plot_len), y_q(1:plot_len), 'b');

xlabel('(ms)')
ylabel('(mV)')
title('1kHz正弦波，采样率100kHz')

%% 组装原始数据
adcDataRaw = zeros(data_len(1), 3);     % [x_t, y_i, y_q]
adcDataRaw(:,1) = x_t;
adcDataRaw(:,2) = y_i;
adcDataRaw(:,3) = y_q;

%% 雷达参数设置
numADCSamples = 250;    % number of ADC samples per chirp
% numADCBits = 16;        % number of ADC bits per sample, 通过时域波形看到没有饱和，暂不处理
numRX = 1;           % number of receivers
isReal = false;      % set to true if real only data, false if complex data
Fs = 5e5 / 2;           % ADC采样率 见配置说明，iq两路需要减半为250kHz
c = 3*1e8;              % 光速
ts = numADCSamples/Fs;  % ADC采样时间
B_valid = 0.25e9;       % 有效带宽,24.00-24.25GHz,250MHz
delta_R = c/(2*B_valid);% 距离分辨率,0.6m
% t_frame = 0.05;         % 慢时间轴采样20Hz
t_frame = 0.001;         % 慢时间轴采样1kHz

% 若设置的ADC位宽超过xbit，则进行截取处理：忽略这一步
%% 排列IQ数据
fileSize = size(adcDataRaw, 1);
PRTnum = fix(fileSize/(numADCSamples*numRX));       % fix向下取整，4096
fileSize = PRTnum * numADCSamples * numRX;          % 取整之后3276800
% adcData = adcDataRaw(1:3e5, :);  % 手动取整为300k
adcData = adcDataRaw(1:fileSize, :);  % 自动取整

% InnoSenT 原始数据格式与TI不同，需要重写
if isReal
    % todo
else
    numChirps = fileSize/numADCSamples/numRX;     % 为
    LVDS = zeros(1, fileSize/1);            % 一行数据包括I和Q
    %combine real and imaginary part into complex data
    %read in file: 2I is followed by 2Q
    counter = 1;
    for i=1:1:fileSize
        LVDS(1,counter) = adcData(i,2) + sqrt(-1)*adcData(i,3);
%         LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2);
%         LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); 
        counter = counter + 1;
    end
    % create column for each chirp
    LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';      % size:(numChirps, numADCSamples*numRX), 比如1200 个Chirps, 每个Chirps有250*1(Ch)个数据 
end

%% 重组数据
adcData = zeros(numRX,numChirps*numADCSamples);     % size:(4*409600)
for row = 1:numRX           % 填充4行
    for i = 1: numChirps    % 填充2048列
        % adcData每次填充200个数据：1-200, 201-400...
        % LVDS每行的数据：1-200, 201-400, 401-600, 601-800
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end
% 200*2048
retVal = reshape(adcData(1, :), numADCSamples, numChirps); %取第二个接收天线数据，数据存储方式为一个chirp一列
% 200*1024, 1T4R只取一半列数据, InnoSenT不做此操作，照搬数据
process_adc = zeros(numADCSamples, numChirps);
gap = 1;
for nchirp = 1:gap:numChirps  %1T4R 
    process_adc(:, (nchirp-1)/gap+1) = retVal(:,nchirp);
end
% 保存数据
% save('process_adc_1x_1019.mat','process_adc'); %250*2306
save(filenameSave,'process_adc'); %250*2306

%%
toc
