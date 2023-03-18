%% Author����Ƥ������
%% Date��2022.05.27
%% Func�����˺�������ԭʼ���ݲɼ���MATLAB����
%% ����TIƽ̨ IWR1642EVM+DCA1000
%% ========================================================================

clc;
clear all;
close all;
%% =========================================================================
%% ��ȡ���ݲ���
numADCSamples = 200; % number of ADC samples per chirp
numADCBits = 16;     % number of ADC bits per sample
numRX = 4;           % number of receivers
numLanes = 2;        % do not change. number of lanes is always 2
isReal = 0;          % set to 1 if real only data, 0 if complex data0
chirpLoop = 2;

%% �״��������
Fs = 4e6;               % ADC������ ������˵��
c = 3*1e8;              % ����
ts = numADCSamples/Fs;  % ADC����ʱ��
slope = 70e12;          % ��Ƶб�ʣ���ô�ߣ�
B_valid = ts*slope;     % ��Ч����
detaR = c/(2*B_valid);  % ����ֱ���

%% ��ȡBin�ļ�
Filename = 'data/data_one_1p5m_comm/one_1.5m_common_1.bin';  %�ļ��� �û���Ҫ�����Լ����ļ����޸�
fid = fopen(Filename,'r');
adcDataRow = fread(fid, 'int16');
if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcDataRow(adcDataRow > l_max) = adcDataRow(adcDataRow > l_max) - 2^numADCBits;
end
fclose(fid);

fileSize = size(adcDataRow, 1);
PRTnum = fix(fileSize/(numADCSamples*numRX));
fileSize = PRTnum * numADCSamples*numRX;
adcData = adcDataRow(1:fileSize);
% real data reshape, filesize = numADCSamples*numChirps
if isReal
    numChirps = fileSize/numADCSamples/numRX;
    LVDS = zeros(1, fileSize);
    %create column for each chirp
    LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';
else
    numChirps = fileSize/2/numADCSamples/numRX;     %����ʵ���鲿����2
    LVDS = zeros(1, fileSize/2);
    %combine real and imaginary part into complex data
    %read in file: 2I is followed by 2Q
    counter = 1;
    for i=1:4:fileSize-1
        LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2);
        LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); counter = counter + 2;
    end
    % create column for each chirp
    LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';
end

%% ��������
adcData = zeros(numRX,numChirps*numADCSamples);
for row = 1:numRX
    for i = 1: numChirps
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end

retVal= reshape(adcData(1, :), numADCSamples, numChirps); %ȡ�ڶ��������������ݣ����ݴ洢��ʽΪһ��chirpһ��

process_adc=zeros(numADCSamples,numChirps/2);

for nchirp = 1:2:numChirps  %1T4R 
    process_adc(:, (nchirp-1)/2+1) = retVal(:,nchirp);
end
	
%% ����άFFT��1��chirp)
figure;
plot((1:numADCSamples)*detaR,db(abs(fft(process_adc(:,1)))));
xlabel('���루m��');
ylabel('����(dB)');
title('����άFFT��1��chirp��');

figure;
plot(db(abs(fft(process_adc(:,1)))))

%% ��λ����Ʋ���
RangFFT = 256;
fft_data_last = zeros(1,RangFFT); 
range_max = 0;
adcdata = process_adc;
numChirps = size(adcdata, 2);

%% ����άFFT
fft_data = fft(adcdata,RangFFT); 
fft_data = fft_data.';

for ii=1:numChirps-1                % ��������������һ������
     fft_data(ii,:) = fft_data(ii+1,:)-fft_data(ii,:);
end

fft_data_abs = abs(fft_data);

fft_data_abs(:,1:10)=0; %ȥ��ֱ������

real_data = real(fft_data);
imag_data = imag(fft_data);


for i = 1:numChirps
    for j = 1:RangFFT  %��ÿһ�������ȡ��λ extract phase
        angle_fft(i,j) = atan2(imag_data(i, j),real_data(i, j));
    end
end

% Range-bin tracking �ҳ��������ĵ㣬�������λ��  
for j = 1:RangFFT
    if((j*detaR)<2.5 &&(j*detaR)>0.5) % �޶�������0.5-1m
        for i = 1:numChirps % ���з���ɻ���
            fft_data_last(j) = fft_data_last(j) + fft_data_abs(i,j);
        end
        
        if ( fft_data_last(j) > range_max)
            range_max = fft_data_last(j);
            max_num = j;  
        end
    end
end 

%% ȡ�������������λ  extract phase from selected range bin
angle_fft_last = angle_fft(:,max_num);

%% ������λ���  phase unwrapping(�ֶ���)���Զ�����Բ���MATLAB�Դ��ĺ���unwrap()
n = 1;
for i = 1+1:numChirps
    diff = angle_fft_last(i) - angle_fft_last(i-1);
    if diff > pi
        angle_fft_last(i:end) = angle_fft_last(i:end) - 2*pi;
        n = n + 1;
    elseif diff < -pi
        angle_fft_last(i:end) = angle_fft_last(i:end) + 2*pi;  
    end
end

%% phase difference ��λ��ֺ������
angle_fft_last2=zeros(1,numChirps);
for i = 1:numChirps-1
    angle_fft_last2(i) = angle_fft_last(i+1) - angle_fft_last(i);
    angle_fft_last2(numChirps)=angle_fft_last(numChirps)-angle_fft_last(numChirps-1);
end 

figure;
plot(angle_fft_last2);
xlabel('������N��');
ylabel('��λ');
title('��λ��ֺ�Ľ��');


%%  IIR��ͨ�˲� Bandpass Filter 0.1-0.6hz���õ�����������
fs =20; %���������źŲ�����
%% FIR ��ͨ�˲����������ã�
% f1 = 0.1;
% f3 = 0.5;
% N=RangFFT; 
% b=fir1(N,wp,blackman(N+1)); 
% breath_data = filter(b,1,angle_fft_last2); 

COE1=chebyshev_IIR; %����fdatool���ɺ���
save coe1.mat COE1;
breath_data = filter(COE1,angle_fft_last2); 

figure;
plot(breath_data);
xlabel('ʱ��/����');
ylabel('����');
title('����ʱ����');

%% �׹��� -FFT -Peak interval
N1=length(breath_data);
fshift = (-N1/2:N1/2-1)*(fs/N1); % zero-centered frequency
breath_fre = abs(fftshift(fft(breath_data)));              %--FFT

figure;
plot(fshift,breath_fre);
xlabel('Ƶ�ʣ�f/Hz��');
ylabel('����');
title('�����ź�FFT  ');

breath_fre_max = 0; % ����Ƶ��
for i = 1:length(breath_fre) %�׷����ֵ����
    if (breath_fre(i) > breath_fre_max)    
        breath_fre_max = breath_fre(i);
        breath_index=i;
    end
end

breath_count =(fs*(numChirps/2-(breath_index-1))/numChirps)*60; %����Ƶ�ʽ���

%% IIR��ͨ�˲� Bandpass Filter 0.8-2hz �õ�����������
COE2=chebyshev_IIR2;
save coe2.mat COE2;
heart_data = filter(COE2,angle_fft_last2); 
figure;
plot(heart_data);
xlabel('ʱ��/����');
ylabel('����');
title('����ʱ����');

N1=length(heart_data);
fshift = (-N1/2:N1/2-1)*(fs/N1); % zero-centered frequency
heart_fre = abs(fftshift(fft(heart_data))); 
figure;
plot(fshift,heart_fre);
xlabel('Ƶ�ʣ�f/Hz��');
ylabel('����');
title('�����ź�FFT');

heart_fre_max = 0; 
for i = 1:length(heart_fre)/2 
    if (heart_fre(i) > heart_fre_max)    
        heart_fre_max = heart_fre(i);
        if(heart_fre_max<1e-2)%�������� �ж��Ƿ��Ǵ����˵�����
            heart_index=1025;
        else
            heart_index=i;
        end
    end
end
heart_count =(fs*(numChirps/2-(heart_index-1))/numChirps)*60;%����Ƶ�ʽ���

% 1024��֡��ԼΪ51.2s��
% ������ݳ��ȹ��������״��51.2s�Ժ������ݺ��������ݽ���һ��ˢ�£�
%�Ա�ʵ�ָ�Ϊ��ȷ�ļ�⡣

disp(['������',num2str(breath_count), '������',num2str(heart_count)])

%% ������ʾ
% �������п���

%% END &thank YOU !



