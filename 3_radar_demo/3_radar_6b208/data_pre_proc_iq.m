% 2023.3.31
% xy
clear;
clc;
tic 
% ��������
fs = 5e5;   % ������500kHz
fs_iq = fs / 2;
cycle = 1 / fs;  
cycle_iq = 1 / fs_iq;

len = 1000;

% 2023.4.20
% ��·��������500kHz, ����Ϊ0.002ms��ÿ��0.5M���㣬ÿ��30M���㡣
% ˫·��������250kHz, ����Ϊ0.004ms��ÿ��0.25M���㣬ÿ��15M���㡣
% 4.3 ���ɼ�16,945,151����
% 1kHzҪ�²�����20Hz��������������50����ȡ
% 1kHz��Ӧ1msһ��chirp,��250��I+Q����(250kHz/1kHz)
% 1kHz��Ӧ1s��1000��chirp,��250*1000��I+Q����(250kHz/1kHz)

% 4.24
% ��·����ʱ���������2us��1����������1ms��500����1s��1000���������ڡ�1s����������1000��(����)* 500��(��ʱ��)=500,0000
% ˫·����ʱ���������4us��1����������1ms��250*2����1s��1000���������ڡ�1s����������1000��(��ʱ��)* 250��*2(��ʱ��)=500,0000

% �״�����
rawdata = importdata('data/0403-1.txt');    % R2010a���д���R2020b��������
% rawdata = importdata('data/0403-1-10k.txt');    % R2010a���д���R2020b��������
% save rawdata.mat
% �ڶ�������
% tmp = load('data/0403.mat');
% rawdata = tmp.rawdata;

x = rawdata.data(:, 2);
y_i = rawdata.data(:, 3);
y_q = rawdata.data(:, 4);

plot(x(1:len), y_i(1:len), 'r');
hold on;
plot(x(1:len), y_q(1:len), 'b');

xlabel('(ms)')
ylabel('(mV)')
title('1kHz���Ҳ���������100kHz')

% 4.24 ���ݴ���
fs_slow = 20; % ��ʱ��Ƶ��20Hz�����ں�����������Ƶ�ʼ���
fs_mod = 1000; % �źŷ������ĵ���Ƶ��
down_sample_rate = fs_mod / fs_slow;
smpno_per_mod = round((1/fs_mod) / (cycle_iq));    % �����������ڵĿ�ʱ���������
smpno_per_slow = smpno_per_mod * down_sample_rate;   % ���������ڵĿ�ʱ���������
period_no_slow = floor(length(x) / smpno_per_slow);   % 1����1200��������

% ����1s�����ʱ������
x_ds = zeros(smpno_per_mod*period_no_slow,1);
for i = 1: period_no_slow
    a1 = smpno_per_mod*(i-1)+1; b1 = smpno_per_mod*i;
    a2 = smpno_per_slow*(i-1)+1;b2 = smpno_per_slow*(i-1)+smpno_per_mod;
    x_ds(a1:b1) = x(a2:b2);
%     x_ds(smpno_per_mod*(i-1)+1, smpno_per_mod*i) = x(smpno_per_slow*(i-1)+1, smpno_per_slow*(i-1)+smpno_per_mod);
end
% �鿴�²������
x_ds_sample = zeros(period_no_slow, 1);
for i = 1 : period_no_slow
   x_ds_sample(i) = x_ds(smpno_per_mod*(i-1)+1);
end
toc
