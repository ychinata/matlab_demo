% Author：调皮连续波
% Date：2022.05.27
% Func：单人呼吸心跳原始数据采集与MATLAB仿真
% https://zhuanlan.zhihu.com/p/510366812
% 采用TI平台 IWR1642EVM+DCA1000
% Review: 2022.9.18
% ========================================================================

clc;
clear all;
close all;
%% =========================================================================
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
detaR = c/(2*B_valid);  % 距离分辨率

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
else
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
    LVDS = LVDS.';      % size:(2048*800)
end

%% 重组数据
adcData = zeros(numRX,numChirps*numADCSamples);     % size:(4*409600)
for row = 1:numRX
    for i = 1: numChirps
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end

retVal= reshape(adcData(1, :), numADCSamples, numChirps); %取第二个接收天线数据，数据存储方式为一个chirp一列

process_adc=zeros(numADCSamples,numChirps/2);

for nchirp = 1:2:numChirps  %1T4R 
    process_adc(:, (nchirp-1)/2+1) = retVal(:,nchirp);
end
