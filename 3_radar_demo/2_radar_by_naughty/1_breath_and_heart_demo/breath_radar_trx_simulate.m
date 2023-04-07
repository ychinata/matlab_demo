%% FMCW���ײ��״������������
% Author����Ƥ������
% https://zhuanlan.zhihu.com/p/510366812

clc;
close all;
clear all;
%% 
include_heartbeat = true;
sig_amp_heartbeat = 0.3;

Breath_PerMinute    = 20;   %������������
Heartbeat_PerMinute = 73;   %������������
Breath_Var    = 0.05;
Heartbeat_Var = 0.05;  

fs = 50;            % ������
SNR = 40;           % ���������
NonLinear = true;   % ������ʹ��

sim_cnt = 20; %���ŵ�ʱ�� ��������Ƶ����һ�������仯

%% ����
ts = 1/fs;
n = 5000;
T = n/fs;  %����ʱ��
t = 0:ts:T;

for kk=1:sim_cnt
    wb =Breath_PerMinute/60 * 2*pi * (1+2*(rand-0.5)*Breath_Var);         %����Ƶ�� ���� ���Ϸ���
    wh = Heartbeat_PerMinute/60 * 2*pi * (1+2*(rand-0.5)*Heartbeat_Var);   %����Ƶ�� ���� ���Ϸ���

    fb = wb/(2*pi);
    fh = wh/(2*pi);

    pb = 0.05*(rand(n,1)-0.5); %�����ź���λ����
    pb2 = 2*pb;
    ph = 0.05*(rand(n,1)-0.5); %�����ź���λ����

    for k=2:n
        pb(k)  = pb(k) + pb(k-1) + wb*ts;    %��λ����
        pb2(k) = pb2(k) + pb2(k-1) + 2*wb*ts;%������λ����
        ph(k)  = ph(k) + ph(k-1) + wh*ts;    %������λ����
    end

    if NonLinear 
        xb = sin(pb) + 0.15 * sin(pb2);    %�����ź�
    else
        xb = sin(pb);
    end

    xh = sig_amp_heartbeat * sin(ph + 2*pi*rand);%�����ź�

    if ~include_heartbeat
        x = xb; 
    else
        x = xb + xh; %�������������źŵ���
    end

    x = awgn(x, SNR); %�������������źŵ��ӣ��ټ��ϸ�˹������
    %
    if NonLinear
        y = x.^3;     %����������
    else
        y = x;
    end

    %% ��ͼ
    f = abs(fft(y(1:1024)));    %���������ź��׹��ƣ�FFT��
    subplot(211)
    plot(y(1:1024)); 
    title('��������ʱ���ź�');

    subplot(212)
    plot((fs/1024)*((1:128)-1),f(1:128));  %����������Ƶ��
    title(['���������ź��׹���:','����Ƶ�ʣ�',num2str(fb),'   ����Ƶ�ʣ�',num2str(fh)]);
    pause(1);
end
%%
% save('vital_sign_sim.mat','y');
% figure; plot(y); fs    
