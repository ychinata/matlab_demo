% 2022.11.3
% https://zhuanlan.zhihu.com/p/508764579

%%=========================================================================
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

Nd = 128;                                   % chirp���� 
Nr = 1024;                                  % ADC��������
vres = (c/fc)/(2*Nd*(Tchirp+endle_time));   % �ٶȷֱ���
% Nr=1024*256;                              % ��Ƶ�źŵ�������
Fs=Nr/Tchirp;                               % ģ���źŲ���Ƶ��

t = linspace(0,Nd*Tchirp,Nr*Nd);            % �����źźͽ����źŵĲ���ʱ�䣬��MATLAB�е�ģ���ź���ͨ�������ź����޲������ɵġ�
                                            % ����Nr*Nd����

Tx = zeros(1,length(t));      % �����ź�
Rx = zeros(1,length(t));      % �����ź�
Mix = zeros(1,length(t));     % ��Ƶ�����ġ���Ƶ����Ƶ�ź�

r_t = zeros(1,length(t));
td = zeros(1,length(t));
freq = zeros(1,length(t));
freq_echo = zeros(1,length(t));

%% ��Ŀ���ź�����

for i=1:length(t)
    
    r_t(i) = r0 + v0*t(i); % �������
    td(i) = 2*r_t(i)/c;    % �ӳ�ʱ��
    
    % ʵ���ź�
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2)); % �����ź� 
    Rx(i) = cos(2*pi*(fc*(t(i)-td(i)) + (slope*(t(i)-td(i))^2)/2)); %�����ź�, t(i)-td(i)
    
    if i <= Nr      % 1024
         freq(i) = fc + slope*i;        % �����ź�ʱƵͼ ֻȡ��һ��chirp
         freq_echo(i) = fc + slope*i;   % �ز��ź�Ƶ���ӳ�      % ��freq��ͬ?���Ȼ᲻�����ù���
    end

    Mix(i) = Tx(i).*Rx(i);%��Ƶ�����ġ���Ƶ����Ƶ�ź�
end

% fig1.�����ź�ʱ��ͼ
figure;
plot(Tx(1:1024));
xlabel('����');
ylabel('����');
title('TX�����ź�ʱ��ͼ(��1��chirp)');

% fig2.�����ź�ʱƵͼ
figure;
plot(t(1:1024),freq(1:1024));
xlabel('ʱ��');
ylabel('Ƶ��');
title('TX�����ź�ʱƵͼ(��1��chirp)');

% fig3.�����ź�ʱ��ͼ
figure;
plot(Rx(1:1024));
xlabel('����');
ylabel('����');
title('RX�����ź�ʱ��ͼ(��1��chirp)');

% fig4.�����ź��뷢���źŵ�ʱƵͼ
figure;
plot(t(1:1024),freq(1:1024));
hold on;
plot(t(1:1024)+td(1:1024),freq(1:1024),'r');
xlabel('ʱ��');
ylabel('Ƶ��');
title('�����ź��뷢���ź�ʱƵͼ(��1��chirp)');
legend ('TX','RX');

% fig5.
figure;
plot(db(abs(fft(Mix(1:1024)))));%�鿴����ĺ�Ƶ�ź� ��chirp�ĵ�����Ϊ1024*256���ɿ�����һ�����źţ���ע�������ڴ档
xlabel('Ƶ��');
ylabel('����');
title('��Ƶ�ź�Ƶ��');


