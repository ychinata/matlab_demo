clear;
clc;
close all

fs = 6*1e3;%采样率
f1 = 5;%信号频率
f2 = 10;%信号频率
T = 1;%时宽1s
%n = round(T*fs);%采样点个数
N = 1024;
% t = linspace(0,T,n);%时域横坐标

% 读取一段采样数据
data = importdata('20230805-1-音符408.txt');
figure(1);
plot(data);
grid on

% 加窗Hamming

%x = 3+cos(2*pi*f1*t) + 2.*cos(2*pi*f2*t);%形成三频信号,注意第二个频率信号幅度为2，直流幅度为3
%figure(1);
%plot(t,x);%画时域图
%xlabel('t/s')


X = fftshift(fft(data./(N))); %用fft得出离散傅里叶变换
f = linspace(-fs/2,fs/2-1,N);%频域横坐标，注意奈奎斯特采样定理，最大原信号最大频率不超过采样频率的一半
figure(2)
plot(f,abs(X));%画双侧频谱幅度图
xlabel('f/Hz')
ylabel('幅度')
grid on

% 自创
f = linspace(0,fs/2-1,N/2);
figure(3)
plot(f,abs(X(N/2+1:end)));%画双侧频谱幅度图
xlabel('f/Hz')
ylabel('幅度')
grid on

% 
% y0 = abs(fft(data)); %快速傅里叶变换的幅值
% %将横坐标转化，显示为频率f= n*(fs/N)
% f = (0:N-1)*fs/N;
% figure(3)
% plot(f,y0);
% xlabel('f/Hz')
% ylabel('幅度')
% grid on
