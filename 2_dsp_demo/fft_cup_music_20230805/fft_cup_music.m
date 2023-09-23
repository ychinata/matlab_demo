clear;
clc;
close all

fs = 6*1e3;%������
f1 = 5;%�ź�Ƶ��
f2 = 10;%�ź�Ƶ��
T = 1;%ʱ��1s
%n = round(T*fs);%���������
N = 1024;
% t = linspace(0,T,n);%ʱ�������

% ��ȡһ�β�������
data = importdata('20230805-1-����408.txt');
figure(1);
plot(data);
grid on

% �Ӵ�Hamming

%x = 3+cos(2*pi*f1*t) + 2.*cos(2*pi*f2*t);%�γ���Ƶ�ź�,ע��ڶ���Ƶ���źŷ���Ϊ2��ֱ������Ϊ3
%figure(1);
%plot(t,x);%��ʱ��ͼ
%xlabel('t/s')


X = fftshift(fft(data./(N))); %��fft�ó���ɢ����Ҷ�任
f = linspace(-fs/2,fs/2-1,N);%Ƶ������꣬ע���ο�˹�ز����������ԭ�ź����Ƶ�ʲ���������Ƶ�ʵ�һ��
figure(2)
plot(f,abs(X));%��˫��Ƶ�׷���ͼ
xlabel('f/Hz')
ylabel('����')
grid on

% �Դ�
f = linspace(0,fs/2-1,N/2);
figure(3)
plot(f,abs(X(N/2+1:end)));%��˫��Ƶ�׷���ͼ
xlabel('f/Hz')
ylabel('����')
grid on

% 
% y0 = abs(fft(data)); %���ٸ���Ҷ�任�ķ�ֵ
% %��������ת������ʾΪƵ��f= n*(fs/N)
% f = (0:N-1)*fs/N;
% figure(3)
% plot(f,y0);
% xlabel('f/Hz')
% ylabel('����')
% grid on
