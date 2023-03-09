% 2022.11.3-2023.1.17
% https://zhuanlan.zhihu.com/p/508764579

%%=========================================================================
clear all;
close all;
clc;
%% �״�ϵͳ��������
maxR = 200;           % �״����̽��Ŀ��ľ���(��λm)
rangeRes = 1;         % �״�ľ���ֱ���(��λm)
maxV = 70;            % �״������Ŀ����ٶ�(��λm/s)
fc= 77e9;             % �״﹤��Ƶ����Ƶ, 77G(��λHz)
c = 3e8;              % ����(��λm/s)

%% �û��Զ���Ŀ�����
r0 = 90;        % Ŀ��������� (max = 200m)
v0 = 10;        % Ŀ���ٶ����� (min =-70m/s, max=70m/s)

%% FMCW���β�������
B = c / (2*rangeRes);       % �����źŴ���(y-axis),  B = 150MHz
Tchirp = 5.5*2*maxR / c;    % ɨƵʱ��(x-axis), ɨƵʱ����Ϊ������ʱ���5-6��,�˴�ѡ��5.5��,Tchirp=7.33us
slope = B / Tchirp;         % ��Ƶб��,slope=20.5T(��λHz/s)
endle_time = 6.3e-6;        % ����ʱ��(��λs)
f_IFmax= (slope*2*maxR)/c;  % �����ƵƵ��, f_IFmax = 27.27MHz
f_IF = (slope*2*r0)/c;      % ��ǰ��ƵƵ��, f_IFmax = 12.27MHz

Nd = 128;                                   % chirp���� 
Nr = 1024;                                  % ADC��������, 1��chirp�ĵ���
vres = (c/fc)/(2*Nd*(Tchirp+endle_time));   % �ٶȷֱ���,vres = 1.1163m/s
Fs = Nr/Tchirp;                             % ģ���źŲ���Ƶ��, Fs = 139.64MHz
t = linspace(0,Nd*Tchirp,Nr*Nd);            % �����źźͽ����źŵĲ���ʱ�� = 0.93ms
                                            % ��MATLAB�е�ģ���ź���ͨ�������ź����޲������ɵġ�
                                            % ����Nr*Nd = 131072����

Tx = zeros(1,length(t));      % �����ź�
Rx = zeros(1,length(t));      % �����ź�
Mix = zeros(1,length(t));     % ��Ƶ�����ġ���Ƶ����Ƶ�ź�

r_t = zeros(1,length(t));
td = zeros(1,length(t));
freq = zeros(1,length(t));
freq_echo = zeros(1,length(t));

%% ��Ŀ���ź�����

for i=1:length(t)    
    r_t(i) = r0 + v0*t(i); % ���¾���, r_t(1) = 90m, �仯����
    td(i) = 2 * r_t(i)/c;  % �ӳ�ʱ��, td = 0.6us, �仯����
    
    % ʵ���ź�
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2)); % �����ź� 
    Rx(i) = cos(2*pi*(fc*(t(i)-td(i)) + (slope*(t(i)-td(i))^2)/2)); %�����ź�, t(i)-td(i)
    
    if i <= Nr                          % ADC��������1024��
         freq(i) = fc + slope*i;        % �����ź�ʱƵͼ,ֻȡ��һ��chirp
         freq_echo(i) = fc + slope*i;   % �ز��ź�Ƶ���ӳ�      % ��freq��ͬ?���Ȼ᲻�����ù���
    end

    Mix(i) = Tx(i).*Rx(i);              % ��Ƶ/����/��Ƶ/��Ƶ�ź�
end

% fig1.�����ź�ʱ��ͼ
figure;
plot(Tx(1:Nr));
xlabel('����');
ylabel('����');
title('TX�����ź�ʱ��ͼ(��1��chirp)');

% figure;
% n = 2;
% plot(Tx((n-1)*Nr+1 : n*Nr));
% xlabel('����');
% ylabel('����');
% title('TX�����ź�ʱ��ͼ(��n��chirp)');

% fig2.�����ź�ʱƵͼ
figure;
plot(t(1:Nr),freq(1:Nr));
xlabel('ʱ��');
ylabel('Ƶ��');
title('TX�����ź�ʱƵͼ(��1��chirp)');

% fig3.�����ź�ʱ��ͼ
figure;
plot(Rx(1:Nr));
xlabel('����');
ylabel('����');
title('RX�����ź�ʱ��ͼ(��1��chirp)');

% fig4.�����ź��뷢���źŵ�ʱƵͼ
figure;
plot(t(1:Nr),freq(1:Nr));
hold on;
plot(t(1:Nr)+td(1:Nr),freq(1:Nr),'r');  % td:�ӳ�ʱ��
xlabel('ʱ��');
ylabel('Ƶ��');
title('�����ź��뷢���ź�ʱƵͼ(��1��chirp)');
legend ('TX','RX');

% fig5.��Ƶ�ź�Ƶ��
figure;
plot(db(abs(fft(Mix(1:Nr)))));  % �鿴����ĺ�Ƶ�ź�
                                % ��chirp�ĵ�����Ϊ1024*256���ɿ�����һ�����źţ���ע�������ڴ档
xlabel('Ƶ��');
ylabel('����');
title('��Ƶ�ź�Ƶ��');

%% ��ͨ�˲� ��ֹƵ��30MHz  ����Ƶ��120MHz
% fig6.��Ƶ�ź�ʱ��
% Nr and Nd here would also define the size of Range and Doppler FFT respectively.
signal = reshape(Mix,Nr,Nd);
figure;
mesh(signal);
xlabel('������')       % Nd = 128
ylabel('��������');    % Nr = 1024
title('��Ƶ�ź�ʱ��');


%% ����άFFT
% fig7.��һ��chirp����ľ���άFFT���
sig_fft = fft(signal,Nr)./Nr;   % size(signal)
sig_fft = abs(sig_fft);
sig_fft = sig_fft(1:(Nr/2),:);  % ʵ�ź�FFT��Ƶ�׶Գƣ�ֻ����һ���Ƶ��
figure;
plot(sig_fft(:,1));
xlabel('���루Ƶ�ʣ�');
ylabel('����')
title('��һ��chirp����ľ���άFFT���')


%% fig8.����FFT����׾���
figure;
mesh(sig_fft);
xlabel('chirp������')
ylabel('���루Ƶ�ʣ�')
zlabel('����')
title('����άFFT����׾���')
axis([0, Nd, 0, Nr/2, 0, 0.3])

%% �ٶ�άFFT
% fig9.�ٶ�άFFT�����������

signal2 = reshape(Mix,[Nr,Nd]);
sig_fft2 = fft2(signal2,Nr,Nd);

sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift(sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;
doppler_axis = linspace(-100,100,Nd);               % [-100,100]��ôȷ����?
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);  % [-256,256]��ôȷ����?
[x_max_index, y_max_index] = find(RDM==max(max(RDM))); % XY������ת?
rdm_max = RDM(x_max_index, y_max_index); 

figure;
mesh(doppler_axis,range_axis,RDM);
xlabel('������ͨ��'); ylabel('����ͨ��'); zlabel('���ȣ�dB��');
title('�ٶ�άFFT�����������');
hold on;
plot3(doppler_axis(y_max_index),range_axis(x_max_index),rdm_max,'k.','MarkerSize',5) 
text(doppler_axis(y_max_index),range_axis(x_max_index),rdm_max,'x������Ϊ�������ź�')

%% ���ս��
K = 1;          % ��ʵ�������,K=1
% �����ź�
distance_gate_index = find(sig_fft(:,1)==max(sig_fft(:,1)));
r0_hat = (distance_gate_index-1) * rangeRes * K;
r0 = 90;        % Ŀ��������� (max = 200m)
v0 = 10;        % Ŀ���ٶ����� (min =-70m/s, max=70m/s)

% �ٶ��ź�
velocity_gate_index = floor(doppler_axis(y_max_index));
v0_hat = (velocity_gate_index-1) * vres * K;

sprintf(char('r0 = %.2f(m), v0 = %.2f(m/s)'), r0, v0)
sprintf(char('r0_hat = %.2f(m), v0_hat = %.2f(m/s)'), r0_hat, v0_hat)

%% END
