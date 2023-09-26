tic;
figure;

%% ========================================================================
clc;
clear;
close all;
% 疑问：

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
% t_frame = 0.05;         % 慢时间轴采样20Hz（抽样50倍）
t_frame = 0.001;         % 慢时间轴采样1kHz

n = 3000;     % 在N个chip中取第n个chirp并显示,50
%%
% save process_adc.txt -ascii process_adc
% save process_adc.mat process_adc
load('process_adc.mat')

% plotSamples = numADCSamples;
plotSamples = 25;
% 把process_adc这个数据保存下来
process_adc_fft = abs(fft(process_adc(:,n)));   % 250*1,是否应该用fftshitf?
plot((1:plotSamples)*delta_R, db(process_adc_fft(1:plotSamples))); 
xlabel('距离（m）');
ylabel('幅度(dB)');
title('Fig.1.距离维FFT(1个chirp)');
grid on

figure;
plot(real(process_adc(:,n)),'b');
hold on;
plot(imag(process_adc(:,n)),'r')
xlabel('样点数');
ylabel('幅度');
title('Fig.2-1.一个chirp时域');
legend('real','imag')

%% 相位解缠绕部分
RangFFT = 256;      % 距离维FFT点数
fft_data_last = zeros(1, RangFFT); 
range_max = 0;
adcData_matrix = process_adc;          % 建议换个变量名
numChirps = size(adcData_matrix, 2);   % 1024


%% 距离维FFT
fft_data = fft(adcData_matrix, RangFFT);   % 200*1024->256*1024
fft_data = fft_data.';              % 1024*256

% 滑动对消，导致峰值出现在2.4m，而不是0.6m，为什么要有这个操作？
% for ii = 1 : numChirps-1            % 滑动对消，少了一个脉冲。但fft_data维度不变
%      fft_data(ii,:) = fft_data(ii+1,:)-fft_data(ii,:);
% end

% 1024*256
fft_data_abs = abs(fft_data);
% fft_data_abs(:,1:10) = 0;           % 为什么去除直流分量, 为什么是前10个%
% Innosent不能去除前10个

data_real = real(fft_data);
data_image = imag(fft_data);

%% 找出能量最大点的相位  extract phase from selected range bin
angle_fft = zeros(size(fft_data));  % 1024*256
for i = 1 : numChirps
    for j = 1 : RangFFT             % 对每一个距离点取相位 extract phase
        angle_fft(i,j) = atan2(data_image(i, j), data_real(i, j));    % atan2四象限反正切
    end
end

% 单位(米)
detectRangeMin = 0;
detectRangeMax = 3;
% Range-bin tracking 找出能量最大的点，即人体的位置
for j = 1 : RangFFT
    % j*delta_R表示什么？
    if ((j*delta_R) > detectRangeMin && (j*delta_R) < detectRangeMax) % 限定检测距离0.5-2.5m, 是否需要根据数据进行修改?
        for i = 4 : 10 %numChirps                    
            fft_data_last(j) = fft_data_last(j) + fft_data_abs(i,j); % (按距离点)进行非相干积累
        end
        % 取出最大值
        if (fft_data_last(j) > range_max)
            range_max = fft_data_last(j);
            max_num = j;  
        end
    end
end

% 取出能量最大点的相位, 1024*1
angle_fft_last = angle_fft(:,max_num);
angle_fft_last_origin = angle_fft(:,max_num);

figure
% plot((1:plotSamples)*delta_R, db(process_adc_fft(1:plotSamples))); 
plotSamples = 25;
plot((1:plotSamples)*delta_R*numADCSamples/RangFFT, fft_data_last(1:plotSamples));
xlabel('距离（m）');
ylabel('幅度');
grid on;
title('Fig.2-2.非相干积累256点距离维FFT');

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

figure
plot((1:numChirps)*t_frame, angle_fft_last_origin);
xlabel('时间（s）');
ylabel('相位');
title('fig3-1.原始相位');

figure
plot((1:numChirps)*t_frame, angle_fft_last);
xlabel('时间（s）');
ylabel('相位');
grid on
title('fig3-2.解缠绕后相位');

%%
toc

%% todo 2023.6.4
% 按照YonseiU的配置重新测量，在0.6m为间距，测0.6,1.2,1.8m，先看能不能找出信号强的点
% [53]YonseiU的配置：
% 参考[54]TexusU的算法流程
