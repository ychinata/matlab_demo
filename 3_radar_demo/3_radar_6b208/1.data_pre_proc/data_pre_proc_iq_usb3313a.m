%% 2023.10.19
% USB3313A data pre proc 

%{ 
USB 3133A���ݸ�ʽ
�ļ���־:DAQ
������:250000
ͨ����:2
��ѹ_0,��ѹ_1
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
title('1kHz���Ҳ���������100kHz')

%% ��װԭʼ����
adcDataRaw = zeros(data_len(1), 3);     % [x_t, y_i, y_q]
adcDataRaw(:,1) = x_t;
adcDataRaw(:,2) = y_i;
adcDataRaw(:,3) = y_q;

%% �״��������
numADCSamples = 250;    % number of ADC samples per chirp
% numADCBits = 16;        % number of ADC bits per sample, ͨ��ʱ���ο���û�б��ͣ��ݲ�����
numRX = 1;           % number of receivers
isReal = false;      % set to true if real only data, false if complex data
Fs = 5e5 / 2;           % ADC������ ������˵����iq��·��Ҫ����Ϊ250kHz
c = 3*1e8;              % ����
ts = numADCSamples/Fs;  % ADC����ʱ��
B_valid = 0.25e9;       % ��Ч����,24.00-24.25GHz,250MHz
delta_R = c/(2*B_valid);% ����ֱ���,0.6m
% t_frame = 0.05;         % ��ʱ�������20Hz
t_frame = 0.001;         % ��ʱ�������1kHz

% �����õ�ADCλ����xbit������н�ȡ����������һ��
%% ����IQ����
fileSize = size(adcDataRaw, 1);
PRTnum = fix(fileSize/(numADCSamples*numRX));       % fix����ȡ����4096
fileSize = PRTnum * numADCSamples * numRX;          % ȡ��֮��3276800
% adcData = adcDataRaw(1:3e5, :);  % �ֶ�ȡ��Ϊ300k
adcData = adcDataRaw(1:fileSize, :);  % �Զ�ȡ��

% InnoSenT ԭʼ���ݸ�ʽ��TI��ͬ����Ҫ��д
if isReal
    % todo
else
    numChirps = fileSize/numADCSamples/numRX;     % Ϊ
    LVDS = zeros(1, fileSize/1);            % һ�����ݰ���I��Q
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
    LVDS = LVDS.';      % size:(numChirps, numADCSamples*numRX), ����1200 ��Chirps, ÿ��Chirps��250*1(Ch)������ 
end

%% ��������
adcData = zeros(numRX,numChirps*numADCSamples);     % size:(4*409600)
for row = 1:numRX           % ���4��
    for i = 1: numChirps    % ���2048��
        % adcDataÿ�����200�����ݣ�1-200, 201-400...
        % LVDSÿ�е����ݣ�1-200, 201-400, 401-600, 601-800
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end
% 200*2048
retVal = reshape(adcData(1, :), numADCSamples, numChirps); %ȡ�ڶ��������������ݣ����ݴ洢��ʽΪһ��chirpһ��
% 200*1024, 1T4Rֻȡһ��������, InnoSenT�����˲������հ�����
process_adc = zeros(numADCSamples, numChirps);
gap = 1;
for nchirp = 1:gap:numChirps  %1T4R 
    process_adc(:, (nchirp-1)/gap+1) = retVal(:,nchirp);
end
% ��������
% save('process_adc_1x_1019.mat','process_adc'); %250*2306
save(filenameSave,'process_adc'); %250*2306

%%
toc
