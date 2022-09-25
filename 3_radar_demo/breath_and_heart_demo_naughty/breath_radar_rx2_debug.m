% Author����Ƥ������
% Date��2022.05.27
% Func�����˺�������ԭʼ���ݲɼ���MATLAB����
% https://zhuanlan.zhihu.com/p/510366812
% ����TIƽ̨ IWR1642EVM+DCA1000
% Review: 2022.9.18
% ========================================================================

clc;
clear all;
close all;
%% =========================================================================
%% ��ȡ���ݲ���
numADCSamples = 200; % number of ADC samples per chirp
numADCBits = 16;     % number of ADC bits per sample
numRX = 4;           % number of receivers
numLanes = 2;        % do not change. number of lanes is always 2
isReal = false;      % set to true if real only data, false if complex data0
chirpLoop = 2;

%% �״��������
Fs = 4e6;               % ADC������ ������˵��
c = 3*1e8;              % ����
ts = numADCSamples/Fs;  % ADC����ʱ��
slope = 70e12;          % ��Ƶб�ʣ���ô�ߣ�
B_valid = ts*slope;     % ��Ч����
detaR = c/(2*B_valid);  % ����ֱ���

%% ��ȡBin�ļ�
Filename = 'data/data_one_1p5m_comm/one_1.5m_common_1.bin';    %�ļ��� �û���Ҫ�����Լ����ļ����޸�
fid = fopen(Filename,'r');
adcDataRow = fread(fid, 'int16');           % Ӧ����adcDataRaw?

% �����õ�ADCλ����16bit������н�ȡ������ȥ2^16��
if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcDataRow(adcDataRow > l_max) = adcDataRow(adcDataRow > l_max) - 2^numADCBits;
end
fclose(fid);
% adcDataRow(1:10)  % �������ݣ�Ϊ�������� 
% max(adcDataRow)   % 4025
% min(adcDataRow)   % -4103

%% ����IQ����
fileSize = size(adcDataRow, 1); % 3276800
PRTnum = fix(fileSize/(numADCSamples*numRX));       % fix����ȡ����4096
fileSize = PRTnum * numADCSamples * numRX;          % ȡ��֮��3276800
adcData = adcDataRow(1:fileSize);                   % ȡ��֮���adc����    
% real data reshape, filesize = numADCSamples*numChirps

if isReal
    numChirps = fileSize/numADCSamples/numRX;
    LVDS = zeros(1, fileSize);
    %create column for each chirp
    LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';
else
    numChirps = fileSize/2/numADCSamples/numRX;     % ����ʵ���鲿����2��Ϊ2048
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
    LVDS = LVDS.';      % size:(2048*800), 2048��Chirps, ÿ��Chirps��200*4(Ch)������
end

%% ��������
adcData = zeros(numRX,numChirps*numADCSamples);     % size:(4*409600)
for row = 1:numRX           % �����
    for i = 1: numChirps    % �����
        % adcDataÿ�����200�����ݣ�1-200, 201-400...
        % LVDSÿ�е����ݣ�1-200, 201-400, 401-600, 601-800
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end

% 200*2048
retVal = reshape(adcData(1, :), numADCSamples, numChirps); %ȡ�ڶ�?�������������ݣ����ݴ洢��ʽΪһ��chirpһ��

% 200*1024, Ϊʲôֻȡһ������, ���ǵڶ���������������?
process_adc = zeros(numADCSamples, numChirps/2);

for nchirp = 1:2:numChirps  %1T4R 
    process_adc(:, (nchirp-1)/2+1) = retVal(:,nchirp);
end

%% ����άFFT��1��chirp)
figure;
plot((1:numADCSamples)*detaR, db(abs(fft(process_adc(:,1)))));
xlabel('���루m��');
ylabel('����(dB)');
title('Fig.1.����άFFT��1��chirp��');

figure;
plot(db(abs(fft(process_adc(:,1)))))
xlabel('������');
ylabel('����(dB)');
title('Fig.2.����άFFT��1��chirp��');

%% ��λ����Ʋ���
RangFFT = 256;
fft_data_last = zeros(1,RangFFT); 
range_max = 0;
adcdata = process_adc;
numChirps = size(adcdata, 2);

