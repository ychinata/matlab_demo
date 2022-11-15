% 2022.11.3
% https://zhuanlan.zhihu.com/p/508764579

%%=========================================================================
clear all;
close all;
clc;
%% 雷达系统参数设置
maxR = 200;           % 雷达最大探测目标的距离
rangeRes = 1;         % 雷达的距离分率
maxV = 70;            % 雷达最大检测目标的速度
fc= 77e9;             % 雷达工作频率 载频
c = 3e8;              % 光速

%% 用户自定义目标参数
r0 = 90; % 目标距离设置 (max = 200m)
v0 = 10; % 目标速度设置 (min =-70m/s, max=70m/s)

%% FMCW波形参数设置
B = c / (2*rangeRes);       % 发射信号带宽 (y-axis)  B = 150MHz
Tchirp = 5.5 * 2 * maxR/c;  % 扫频时间 (x-axis), 5.5= sweep time should be at least 5 o 6 times the round trip time
slope = B / Tchirp;         %调频斜率
endle_time=6.3e-6;          %空闲时间
f_IFmax= (slope*2*maxR)/c ; %最高中频频率
f_IF=(slope*2*r0)/c ;       %当前中频频率

Nd = 128;                                   % chirp数量 
Nr = 1024;                                  % ADC采样点数
vres = (c/fc)/(2*Nd*(Tchirp+endle_time));   % 速度分辨率
% Nr=1024*256;                              % 和频信号点数设置
Fs=Nr/Tchirp;                               % 模拟信号采样频率

t = linspace(0,Nd*Tchirp,Nr*Nd);            % 发射信号和接收信号的采样时间，在MATLAB中的模拟信号是通过数字信号无限采样生成的。
                                            % 产生Nr*Nd个点

Tx = zeros(1,length(t));      % 发射信号
Rx = zeros(1,length(t));      % 接收信号
Mix = zeros(1,length(t));     % 差频、差拍、拍频、中频信号

r_t = zeros(1,length(t));
td = zeros(1,length(t));
freq = zeros(1,length(t));
freq_echo = zeros(1,length(t));

%% 动目标信号生成

for i=1:length(t)
    
    r_t(i) = r0 + v0*t(i); % 距离更新
    td(i) = 2*r_t(i)/c;    % 延迟时间
    
    % 实数信号
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2)); % 发射信号 
    Rx(i) = cos(2*pi*(fc*(t(i)-td(i)) + (slope*(t(i)-td(i))^2)/2)); %接收信号, t(i)-td(i)
    
    if i <= Nr      % 1024
         freq(i) = fc + slope*i;        % 发射信号时频图 只取第一个chirp
         freq_echo(i) = fc + slope*i;   % 回波信号频谱延迟      % 与freq相同?长度会不会设置过长
    end

    Mix(i) = Tx(i).*Rx(i);%差频、差拍、拍频、中频信号
end

% fig1.发射信号时域图
figure;
plot(Tx(1:1024));
xlabel('点数');
ylabel('幅度');
title('TX发射信号时域图(第1个chirp)');

% fig2.发射信号时频图
figure;
plot(t(1:1024),freq(1:1024));
xlabel('时间');
ylabel('频率');
title('TX发射信号时频图(第1个chirp)');

% fig3.接收信号时域图
figure;
plot(Rx(1:1024));
xlabel('点数');
ylabel('幅度');
title('RX接收信号时域图(第1个chirp)');

% fig4.接收信号与发射信号的时频图
figure;
plot(t(1:1024),freq(1:1024));
hold on;
plot(t(1:1024)+td(1:1024),freq(1:1024),'r');
xlabel('时间');
ylabel('频率');
title('接收信号与发射信号时频图(第1个chirp)');
legend ('TX','RX');

% fig5.
figure;
plot(db(abs(fft(Mix(1:1024)))));%查看宽带的和频信号 将chirp的点数改为1024*256即可看到有一个门信号，但注意计算机内存。
xlabel('频率');
ylabel('幅度');
title('中频信号频谱');


