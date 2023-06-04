% 采用24GHz InnoSenT 平台,1T1R
% 原始数据进行50倍采样，因为数据量太大
% 2023.4.27
tic
%% ========================================================================
clc;
clear;
close;
% 疑问：
% 1.调制频率设置为1kHz会不会不够?即一个chirp为1ms会不会太长
% 2.距离分辨率,0.6m，会不会太大不能用？移动身体的位置到0.6m处?或者移动到其它位置试下
% 雷达在进行呼吸心跳检测时，需要具备较高的距离分辨率。通常情况下，约为1cm的距离分辨率能够满足需求？
% 24Ghz雷达有没有可行性，寻找文献。或者有没有其它应用场景，比如跌倒检测？车载？
%%
% Vtune:0.5V–10V，对应扫频24.00-24.25GHz
% 故调制锯齿波的Vpp为4.75V, -4.75V-4.75V, 偏移为5.25V, 即可生成0.5V-10V的锯齿波

%% 读取数据部分
numADCSamples = 250;    % number of ADC samples per chirp
% numADCBits = 16;        % number of ADC bits per sample, 通过时域波形看到没有饱和，暂不处理
numRX = 1;           % number of receivers
% numLanes = 2;        % do not change. number of lanes is always 2，用不到
isReal = false;      % set to true if real only data, false if complex data

%% 雷达参数设置
Fs = 5e5 / 2;           % ADC采样率 见配置说明，iq两路需要减半为250kHz
c = 3*1e8;              % 光速
ts = numADCSamples/Fs;  % ADC采样时间
% slope = B_valid / ts; % 调频斜率2.5e11
B_valid = 0.25e9;       % 有效带宽,24.00-24.25GHz,250MHz
delta_R = c/(2*B_valid);% 距离分辨率,0.6m
t_frame = 0.05;         % 慢时间轴采样20Hz

%% 读取Bin文件 2023.4.28
% txt数据格式：
% Tims      AI00(I) AI01(Q)      
% 0.00000	2610.17	2380.37
% 0.00400	2622.07	2337.95
% 0.00800	2626.34	2303.47
% 0.01200	2628.48	2260.74
% 0.01600	2630.92	2221.07
filename = 'data/0403-1_ds-338750.txt';     % 抽样50倍的数据
adcDataRaw = importdata(filename);
x_ds = adcDataRaw(:, 1);
y_ids = adcDataRaw(:, 2);
y_qds = adcDataRaw(:, 3);

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

%% 距离维FFT（1个chirp)
% 为了减少图像显示,暂时注释掉
% 若目标距离1.5m，则在1.5m处会出现一个峰值
% %{
figure;
% 在N个chip中取第n个chirp并显示
n = 100;
plot((1:numADCSamples)*delta_R, db(abs(fft(process_adc(:,n))))); 
xlabel('距离（m）');
ylabel('幅度(dB)');
title('Fig.1.距离维FFT(1个chirp)(抽样50倍)');

figure;
plot(db(abs(fft(process_adc(:,n)))))
xlabel('样点数');
ylabel('幅度(dB)');
title('Fig.2.距离维FFT(1个chirp)(抽样50倍)');

figure;
plot(real(process_adc(:,n)),'b');
hold on;
plot(imag(process_adc(:,n)),'r')
xlabel('样点数');
ylabel('幅度');
title('Fig.2-1.一个chirp时域(抽样50倍)');
% %}

%%
toc
