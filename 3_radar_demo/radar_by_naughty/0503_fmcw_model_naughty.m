%% Author: ��Ƥ������
%% Date: 2022.5
%% Func: FMCW�״﷢���źš��ز��źš���Ƶ������άFFT���ٶ�άFFT��ģ����
%% https://zhuanlan.zhihu.com/p/508764579
%% =========================================================================
clear all;
close all;
clc;
%% �״�ϵͳ��������
maxR = 200;           % �״����̽��Ŀ��ľ���
rangeRes = 1;         % �״�ľ������
maxV = 70;            % �״������Ŀ����ٶ�
fc= 77e9;             % �״﹤��Ƶ�� ��Ƶ
c = 3e8;              % ����

%% �û��Զ���Ŀ�����
r0 = 90; % Ŀ��������� (max = 200m)
v0 = 10; % Ŀ���ٶ����� (min =-70m/s, max=70m/s)


%% FMCW���β�������
B = c / (2*rangeRes);       % �����źŴ��� (y-axis)  B = 150MHz
Tchirp = 5.5 * 2 * maxR/c;  % ɨƵʱ�� (x-axis), 5.5= sweep time should be at least 5 o 6 times the round trip time
slope = B / Tchirp;         %��Ƶб��
endle_time=6.3e-6;          %����ʱ��
f_IFmax= (slope*2*maxR)/c ; %�����ƵƵ��
f_IF=(slope*2*r0)/c ;       %��ǰ��ƵƵ��

Nd=128;                          %chirp���� 
Nr=1024;                        %ADC��������
vres=(c/fc)/(2*Nd*(Tchirp+endle_time));%�ٶȷֱ���
% Nr=1024*256;                %��Ƶ�źŵ�������
Fs=Nr/Tchirp;                 %ģ���źŲ���Ƶ��

t=linspace(0,Nd*Tchirp,Nr*Nd); %�����źźͽ����źŵĲ���ʱ�䣬��MATLAB�е�ģ���ź���ͨ�������ź����޲������ɵġ�

Tx=zeros(1,length(t)); %�����ź�
Rx=zeros(1,length(t)); %�����ź�
Mix = zeros(1,length(t)); %��Ƶ�����ġ���Ƶ����Ƶ�ź�

r_t=zeros(1,length(t));
td=zeros(1,length(t));

%% ��Ŀ���ź�����

for i=1:length(t)
    
    r_t(i) = r0 + v0*t(i); % �������
    td(i) = 2*r_t(i)/c;    % �ӳ�ʱ��
    
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2)); % �����ź� ʵ���ź�
    Rx(i) = cos(2*pi*(fc*(t(i)-td(i)) + (slope*(t(i)-td(i))^2)/2)); %�����ź� ʵ���ź�
    
    if i<=1024
         freq(i)=fc+slope*i; %�����ź�ʱƵͼ ֻȡ��һ��chirp
         freq_echo(i)=fc+slope*i;%�ز��ź�Ƶ���ӳ�
    end

    Mix(i) = Tx(i).*Rx(i);%��Ƶ�����ġ���Ƶ����Ƶ�ź�
end

%�����ź�ʱ��ͼ
figure;
plot(Tx(1:1024));
xlabel('����');
ylabel('����');
title('TX�����ź�ʱ��ͼ');

% %�����ź�ʱƵͼ
figure;
plot(t(1:1024),freq);
xlabel('ʱ��');
ylabel('Ƶ��');
title('TX�����ź�ʱƵͼ');

%�����ź�ʱ��ͼ
figure;
plot(Rx(1:1024));
xlabel('����');
ylabel('����');
title('RX�����ź�ʱ��ͼ');

%�����ź��뷢���źŵ�ʱƵͼ
figure;
plot(t(1:1024),freq);
hold on;
plot(td(1:1024)+t(1:1024),freq);
xlabel('ʱ��');
ylabel('Ƶ��');
title('�����ź��뷢���ź�ʱƵͼ');
legend ('TX','RX');

%��Ƶ�ź�Ƶ�� ��Ƶ�źŹ۲�
%figure;
% plot(db(abs(fft(Mix(1:1024*256)))));%�鿴����ĺ�Ƶ�ź� ��chirp�ĵ�����Ϊ1024*256���ɿ�����һ�����źţ���ע�������ڴ档
% xlabel('Ƶ��');
% ylabel('����');
% title('��Ƶ�ź�Ƶ��');

figure;
plot(db(abs(fft(Mix(1:1024)))));%�鿴����ĺ�Ƶ�ź� ��chirp�ĵ�����Ϊ1024*256���ɿ�����һ�����źţ���ע�������ڴ档
xlabel('Ƶ��');
ylabel('����');
title('��Ƶ�ź�Ƶ��');

%% ��ͨ�˲� ��ֹƵ��30MHz  ����Ƶ��120MHz
% Mix=lowpass(Mix(1:1024*256),30e6,120e6);
% plot(db(abs(fft(Mix(1:1024*256)))));
% xlabel('Ƶ��');
% ylabel('����');
% title('��Ƶ�źŵ�ͨ�˲���');

%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
signal = reshape(Mix,Nr,Nd);

figure;
mesh(signal);
xlabel('������')
ylabel('��������');
title('��Ƶ�ź�ʱ��');

%% ����άFFT
sig_fft = fft(signal,Nr)./Nr;
sig_fft = abs(sig_fft);
sig_fft = sig_fft(1:(Nr/2),:);

figure;
plot(sig_fft(:,1));
xlabel('���루Ƶ�ʣ�');
ylabel('����')
title('��һ��chirp��FTF���')


%% ����FFT����׾���
figure;
mesh(sig_fft);
xlabel('���루Ƶ�ʣ�');
ylabel('chirp������')
zlabel('����')
title('����άFTF���')

%% �ٶ�άFFT

Mix=reshape(Mix,[Nr,Nd]);
sig_fft2 = fft2(Mix,Nr,Nd);

sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);

figure;
mesh(doppler_axis,range_axis,RDM);
xlabel('������ͨ��'); ylabel('����ͨ��'); zlabel('���ȣ�dB��');
title('�ٶ�άFFT �����������');

%% END