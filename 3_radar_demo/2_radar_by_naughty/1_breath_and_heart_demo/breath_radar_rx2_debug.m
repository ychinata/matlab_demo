% Author����Ƥ������
% Date��2022.05.27
% Func�����˺�������ԭʼ���ݲɼ���MATLAB����
% https://zhuanlan.zhihu.com/p/510366812
% ����TIƽ̨ IWR1642EVM+DCA1000
% Review: 2022.9.18
% ========================================================================

%% ========================================================================
% ��1��Range FFT������άFFT�� 
% ��2��Range bin tracking��������������
% ��3��Extract Phase����λ��ȡ��
% ��4��Phase Unwrapping����λ����ƣ�
% ��5��Phase Difference ����λ��֣�
% ��6��Bandpass Filtering ����ͨ�˲�����
% ��7��Spectral Estimation���׹��ƣ�
% ��8��Decision���о���
% ��9��Ƶ�׽��зָ�
% ��10������/����Ƶ�ʼ���

%% ========================================================================
% ���ʣ�
% I/Q��·����

%% ========================================================================
clc;
clear all;
close all;

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
delta_R = c/(2*B_valid);  % ����ֱ���

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
else % �������߸÷�֧
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
for row = 1:numRX           % ���4��
    for i = 1: numChirps    % ���2048��
        % adcDataÿ�����200�����ݣ�1-200, 201-400...
        % LVDSÿ�е����ݣ�1-200, 201-400, 401-600, 601-800
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end

% 200*2048
retVal = reshape(adcData(1, :), numADCSamples, numChirps); %ȡ�ڶ��������������ݣ����ݴ洢��ʽΪһ��chirpһ��

%IWR1642Ϊ2T4R ��ֻ����TX1 һ��ͨ����Ϊ1T4R:2*200*1024=200* 2048,�����TX1�� TX2��Ϊ2T4R:4*200*1024=200*4096
% 200*1024, 1T4Rֻȡһ��������
process_adc = zeros(numADCSamples, numChirps/2);
for nchirp = 1:2:numChirps  %1T4R 
    process_adc(:, (nchirp-1)/2+1) = retVal(:,nchirp);
end

%% ����άFFT��1��chirp)
% Ϊ�˼���ͼ����ʾ,��ʱע�͵�
% ��Ŀ�����1.5m������1.5m�������һ����ֵ
%{
figure;
plot((1:numADCSamples)*delta_R, db(abs(fft(process_adc(:,1))))); % ��2048��chip��ȡ��1��
xlabel('���루m��');
ylabel('����(dB)');
title('Fig.1.����άFFT��1��chirp��');

figure;
plot(db(abs(fft(process_adc(:,1)))))
xlabel('������');
ylabel('����(dB)');
title('Fig.2.����άFFT��1��chirp��');

figure;
plot(real(process_adc(:,1)),'b');
hold on;
plot(imag(process_adc(:,1)),'r')
xlabel('������');
ylabel('����');
title('Fig.2-1.һ��chirpʱ��');
%}

%% ��λ����Ʋ���
RangFFT = 256;      % ����άFFT����
fft_data_last = zeros(1, RangFFT); 
range_max = 0;
adcdata = process_adc;          % ���黻��������
numChirps = size(adcdata, 2);   % 1024

%% ����άFFT

fft_data = fft(adcdata, RangFFT);   % 200*1024->256*1024
fft_data = fft_data.';              % 1024*256

for ii = 1 : numChirps-1            % ��������������һ�����塣��fft_dataά�Ȳ���
     fft_data(ii,:) = fft_data(ii+1,:)-fft_data(ii,:);
end
% 1024*256
fft_data_abs = abs(fft_data);
fft_data_abs(:,1:10) = 0;           % ȥ��ֱ������, Ϊʲô��1:10?

real_data = real(fft_data);
imag_data = imag(fft_data);

%% �ҳ������������λ  extract phase from selected range bin
angle_fft = zeros(size(fft_data));  % 1024*256
for i = 1 : numChirps
    for j = 1 : RangFFT             % ��ÿһ�������ȡ��λ extract phase
        angle_fft(i,j) = atan2(imag_data(i, j),real_data(i, j));    % atan2�����޷�����
    end
end


% Range-bin tracking �ҳ��������ĵ㣬�������λ��
for j = 1 : RangFFT
    % j*delta_R��ʾʲô��
    if ((j*delta_R) < 2.5 && (j*delta_R) > 0.5) % �޶�������0.5-1m, �Ƿ���Ҫ�������ݽ����޸�?
        for i = 1 : numChirps                   % ���з���ɻ���
            fft_data_last(j) = fft_data_last(j) + fft_data_abs(i,j);
        end
        
        if (fft_data_last(j) > range_max)
            range_max = fft_data_last(j);
            max_num = j;  
        end
    end
end

% ȡ�������������λ
angle_fft_last = angle_fft(:,max_num);

%% ������λ���  
% phase unwrapping(�ֶ���)���Զ�����Բ���MATLAB�Դ��ĺ���unwrap()
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

%% phase difference ��λ��ֺ������
angle_fft_last2 = zeros(1,numChirps);       % rename: angle_fft_diff
for i = 1 : numChirps-1
    angle_fft_last2(i) = angle_fft_last(i+1) - angle_fft_last(i);
    angle_fft_last2(numChirps) = angle_fft_last(numChirps) - angle_fft_last(numChirps-1);
end 

figure;
plot(angle_fft_last2);
xlabel('������N��');
ylabel('��λ');
title('Fig.3.��λ��ֺ�Ľ��');

%%  IIR��ͨ�˲� Bandpass Filter 0.1-0.6hz���õ�����������
fs = 20;                %���������źŲ�����
COE1 = chebyshev_IIR;   %����fdatool���ɺ������������?
save coe1.mat COE1;
breath_data = filter(COE1, angle_fft_last2);

figure;
plot(breath_data);
xlabel('ʱ��/����');
ylabel('����');
title('Fig.4.����ʱ����');

%% �׹��� -FFT -Peak interval
N1 = length(breath_data);                               % 1024
fshift = (-N1/2:N1/2-1) * (fs/N1);                      % zero-centered frequency
breath_data_freq = abs(fftshift(fft(breath_data)));     % FFT, Ϊʲô����һ��fft?

figure;
% subplot(2,1,1)
plot(fshift, breath_data_freq);
xlabel('Ƶ�ʣ�f/Hz��');
ylabel('����');
title('Fig.5.�����ź�FFT with shift');

% ������fftshift
% fnoshift = (0:N1-1) * (fs/N1);
% breath_data_freq_noshift = abs(fft(breath_data));     % FFT, Ϊʲô����һ��fft?
% subplot(2,1,2)
% plot(fnoshift, breath_data_freq_noshift);
% xlabel('Ƶ�ʣ�f/Hz��');
% ylabel('����');
% title('Fig.5.�����ź�FFT without shift');

breath_freq_max = 0;                        % ����Ƶ��
for i = 1:length(breath_data_freq)          % �׷����ֵ����,1024��
    if (breath_data_freq(i) > breath_freq_max)
        breath_freq_max = breath_data_freq(i);
        breath_index = i;
    end
end

% ���Ϳ���ʵ���������׷����ֵ����
% [breath_freq_max, breath_index] = max(breath_data_freq);


breath_count =(fs * (numChirps/2 - (breath_index-1)) / numChirps) * 60; %����Ƶ�ʽ��㣬ԭ��
disp(['������',num2str(breath_count)])

