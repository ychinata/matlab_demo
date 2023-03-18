% Author：调皮连续波
% Date：2022.05.27
% Func：单人呼吸心跳原始数据采集与MATLAB仿真
% https://zhuanlan.zhihu.com/p/510366812
% 采用TI平台 IWR1642EVM+DCA1000
% Review: 2022.9.18
% ========================================================================

%% ========================================================================
% （1）Range FFT（距离维FFT） 
% （2）Range bin tracking（距离门锁定）
% （3）Extract Phase（相位提取）
% （4）Phase Unwrapping（相位解缠绕）
% （5）Phase Difference （相位差分）
% （6）Bandpass Filtering （带通滤波器）
% （7）Spectral Estimation（谱估计）
% （8）Decision（判决）
% （9）频谱进行分割
% （10）心跳/呼吸频率计算

%% ========================================================================
% 疑问：
% I/Q两路数据

%% ========================================================================
clc;
clear all;
close all;

%% 读取数据部分
numADCSamples = 200; % number of ADC samples per chirp
numADCBits = 16;     % number of ADC bits per sample
numRX = 4;           % number of receivers
numLanes = 2;        % do not change. number of lanes is always 2
isReal = false;      % set to true if real only data, false if complex data0
chirpLoop = 2;

%% 雷达参数设置
Fs = 4e6;               % ADC采样率 见配置说明
c = 3*1e8;              % 光速
ts = numADCSamples/Fs;  % ADC采样时间
slope = 70e12;          % 调频斜率，这么高？
B_valid = ts*slope;     % 有效带宽
delta_R = c/(2*B_valid);  % 距离分辨率

%% 读取Bin文件
Filename = 'data/data_one_1p5m_comm/one_1.5m_common_1.bin';    %文件名 用户需要按照自己的文件名修改
fid = fopen(Filename,'r');
adcDataRow = fread(fid, 'int16');           % 应该是adcDataRaw?

% 若设置的ADC位宽超过16bit，则进行截取处理（减去2^16）
if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcDataRow(adcDataRow > l_max) = adcDataRow(adcDataRow > l_max) - 2^numADCBits;
end
fclose(fid);
% adcDataRow(1:10)  % 看下数据，为正负整数 
% max(adcDataRow)   % 4025
% min(adcDataRow)   % -4103

%% 排列IQ数据
fileSize = size(adcDataRow, 1); % 3276800
PRTnum = fix(fileSize/(numADCSamples*numRX));       % fix向下取整，4096
fileSize = PRTnum * numADCSamples * numRX;          % 取整之后3276800
adcData = adcDataRow(1:fileSize);                   % 取整之后的adc数据    
% real data reshape, filesize = numADCSamples*numChirps

if isReal
    numChirps = fileSize/numADCSamples/numRX;
    LVDS = zeros(1, fileSize);
    %create column for each chirp
    LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';
else % 本程序走该分支
    numChirps = fileSize/2/numADCSamples/numRX;     % 含有实部虚部除以2，为2048
    LVDS = zeros(1, fileSize/2);
    %combine real and imaginary part into complex data
    %read in file: 2I is followed by 2Q
    counter = 1;
    for i=1:4:fileSize-1
        LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2);
        LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); 
        counter = counter + 2;
    end
    % create column for each chirp
    LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';      % size:(2048*800), 2048个Chirps, 每个Chirps有200*4(Ch)个数据
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

%IWR1642为2T4R 但只用了TX1 一个通道即为1T4R:2*200*1024=200* 2048,如果用TX1和 TX2则为2T4R:4*200*1024=200*4096
% 200*1024, 1T4R只取一半列数据
process_adc = zeros(numADCSamples, numChirps/2);
for nchirp = 1:2:numChirps  %1T4R 
    process_adc(:, (nchirp-1)/2+1) = retVal(:,nchirp);
end

%% 距离维FFT（1个chirp)
% 为了减少图像显示,暂时注释掉
% 若目标距离1.5m，则在1.5m处会出现一个峰值
%{
figure;
plot((1:numADCSamples)*delta_R, db(abs(fft(process_adc(:,1))))); % 在2048个chip中取第1个
xlabel('距离（m）');
ylabel('幅度(dB)');
title('Fig.1.距离维FFT（1个chirp）');

figure;
plot(db(abs(fft(process_adc(:,1)))))
xlabel('样点数');
ylabel('幅度(dB)');
title('Fig.2.距离维FFT（1个chirp）');

figure;
plot(real(process_adc(:,1)),'b');
hold on;
plot(imag(process_adc(:,1)),'r')
xlabel('样点数');
ylabel('幅度');
title('Fig.2-1.一个chirp时域');
%}

%% 相位解缠绕部分
RangFFT = 256;      % 距离维FFT点数
fft_data_last = zeros(1, RangFFT); 
range_max = 0;
adcdata = process_adc;          % 建议换个变量名
numChirps = size(adcdata, 2);   % 1024

%% 距离维FFT

fft_data = fft(adcdata, RangFFT);   % 200*1024->256*1024
fft_data = fft_data.';              % 1024*256

for ii = 1 : numChirps-1            % 滑动对消，少了一个脉冲。但fft_data维度不变
     fft_data(ii,:) = fft_data(ii+1,:)-fft_data(ii,:);
end
% 1024*256
fft_data_abs = abs(fft_data);
fft_data_abs(:,1:10) = 0;           % 去除直流分量, 为什么是1:10?

real_data = real(fft_data);
imag_data = imag(fft_data);

%% 找出能量最大点的相位  extract phase from selected range bin
angle_fft = zeros(size(fft_data));  % 1024*256
for i = 1 : numChirps
    for j = 1 : RangFFT             % 对每一个距离点取相位 extract phase
        angle_fft(i,j) = atan2(imag_data(i, j),real_data(i, j));    % atan2四象限反正切
    end
end


% Range-bin tracking 找出能量最大的点，即人体的位置
for j = 1 : RangFFT
    % j*delta_R表示什么？
    if ((j*delta_R) < 2.5 && (j*delta_R) > 0.5) % 限定检测距离0.5-1m, 是否需要根据数据进行修改?
        for i = 1 : numChirps                   % 进行非相干积累
            fft_data_last(j) = fft_data_last(j) + fft_data_abs(i,j);
        end
        
        if (fft_data_last(j) > range_max)
            range_max = fft_data_last(j);
            max_num = j;  
        end
    end
end

% 取出能量最大点的相位
angle_fft_last = angle_fft(:,max_num);

%% 进行相位解缠  
% phase unwrapping(手动解)，自动解可以采用MATLAB自带的函数unwrap()
n = 1;
for i = 1+1 : numChirps
    diff = angle_fft_last(i) - angle_fft_last(i-1);
    if diff > pi
        angle_fft_last(i:end) = angle_fft_last(i:end) - 2*pi;
        n = n + 1;
    elseif diff < -pi
        angle_fft_last(i:end) = angle_fft_last(i:end) + 2*pi;  
    end
end

%% phase difference 相位差分后的数据
angle_fft_last2 = zeros(1,numChirps);       % rename: angle_fft_diff
for i = 1 : numChirps-1
    angle_fft_last2(i) = angle_fft_last(i+1) - angle_fft_last(i);
    angle_fft_last2(numChirps) = angle_fft_last(numChirps) - angle_fft_last(numChirps-1);
end 

figure;
plot(angle_fft_last2);
xlabel('点数（N）');
ylabel('相位');
title('Fig.3.相位差分后的结果');

%%  IIR带通滤波 Bandpass Filter 0.1-0.6hz，得到呼吸的数据
fs = 20;                %呼吸心跳信号采样率
COE1 = chebyshev_IIR;   %采用fdatool生成函数，如何生成?
save coe1.mat COE1;
breath_data = filter(COE1, angle_fft_last2);

figure;
plot(breath_data);
xlabel('时间/点数');
ylabel('幅度');
title('Fig.4.呼吸时域波形');

%% 谱估计 -FFT -Peak interval
N1 = length(breath_data);                               % 1024
fshift = (-N1/2:N1/2-1) * (fs/N1);                      % zero-centered frequency
breath_data_freq = abs(fftshift(fft(breath_data)));     % FFT, 为什么又做一次fft?

figure;
% subplot(2,1,1)
plot(fshift, breath_data_freq);
xlabel('频率（f/Hz）');
ylabel('幅度');
title('Fig.5.呼吸信号FFT with shift');

% 不进行fftshift
% fnoshift = (0:N1-1) * (fs/N1);
% breath_data_freq_noshift = abs(fft(breath_data));     % FFT, 为什么又做一次fft?
% subplot(2,1,2)
% plot(fnoshift, breath_data_freq_noshift);
% xlabel('频率（f/Hz）');
% ylabel('幅度');
% title('Fig.5.呼吸信号FFT without shift');

breath_freq_max = 0;                        % 呼吸频率
for i = 1:length(breath_data_freq)          % 谱峰最大值搜索,1024点
    if (breath_data_freq(i) > breath_freq_max)
        breath_freq_max = breath_data_freq(i);
        breath_index = i;
    end
end

% 这句就可以实现上述的谱峰最大值搜索
% [breath_freq_max, breath_index] = max(breath_data_freq);


breath_count =(fs * (numChirps/2 - (breath_index-1)) / numChirps) * 60; %呼吸频率解算，原理？
disp(['呼吸：',num2str(breath_count)])

