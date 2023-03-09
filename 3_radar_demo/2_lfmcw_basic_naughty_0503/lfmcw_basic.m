% 2022.11.3-2023.1.17
% https://zhuanlan.zhihu.com/p/508764579

%%=========================================================================
clear all;
close all;
clc;
%% 雷达系统参数设置
maxR = 200;           % 雷达最大探测目标的距离(单位m)
rangeRes = 1;         % 雷达的距离分辨率(单位m)
maxV = 70;            % 雷达最大检测目标的速度(单位m/s)
fc= 77e9;             % 雷达工作频率载频, 77G(单位Hz)
c = 3e8;              % 光速(单位m/s)

%% 用户自定义目标参数
r0 = 90;        % 目标距离设置 (max = 200m)
v0 = 10;        % 目标速度设置 (min =-70m/s, max=70m/s)

%% FMCW波形参数设置
B = c / (2*rangeRes);       % 发射信号带宽(y-axis),  B = 150MHz
Tchirp = 5.5*2*maxR / c;    % 扫频时间(x-axis), 扫频时间须为往返程时间的5-6倍,此处选择5.5倍,Tchirp=7.33us
slope = B / Tchirp;         % 调频斜率,slope=20.5T(单位Hz/s)
endle_time = 6.3e-6;        % 空闲时间(单位s)
f_IFmax= (slope*2*maxR)/c;  % 最高中频频率, f_IFmax = 27.27MHz
f_IF = (slope*2*r0)/c;      % 当前中频频率, f_IFmax = 12.27MHz

Nd = 128;                                   % chirp数量 
Nr = 1024;                                  % ADC采样点数, 1个chirp的点数
vres = (c/fc)/(2*Nd*(Tchirp+endle_time));   % 速度分辨率,vres = 1.1163m/s
Fs = Nr/Tchirp;                             % 模拟信号采样频率, Fs = 139.64MHz
t = linspace(0,Nd*Tchirp,Nr*Nd);            % 发射信号和接收信号的采样时间 = 0.93ms
                                            % 在MATLAB中的模拟信号是通过数字信号无限采样生成的。
                                            % 产生Nr*Nd = 131072个点

Tx = zeros(1,length(t));      % 发射信号
Rx = zeros(1,length(t));      % 接收信号
Mix = zeros(1,length(t));     % 差频、差拍、拍频、中频信号

r_t = zeros(1,length(t));
td = zeros(1,length(t));
freq = zeros(1,length(t));
freq_echo = zeros(1,length(t));

%% 动目标信号生成

for i=1:length(t)    
    r_t(i) = r0 + v0*t(i); % 更新距离, r_t(1) = 90m, 变化缓慢
    td(i) = 2 * r_t(i)/c;  % 延迟时间, td = 0.6us, 变化缓慢
    
    % 实数信号
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2)); % 发射信号 
    Rx(i) = cos(2*pi*(fc*(t(i)-td(i)) + (slope*(t(i)-td(i))^2)/2)); %接收信号, t(i)-td(i)
    
    if i <= Nr                          % ADC采样点数1024点
         freq(i) = fc + slope*i;        % 发射信号时频图,只取第一个chirp
         freq_echo(i) = fc + slope*i;   % 回波信号频谱延迟      % 与freq相同?长度会不会设置过长
    end

    Mix(i) = Tx(i).*Rx(i);              % 差频/差拍/拍频/中频信号
end

% fig1.发射信号时域图
figure;
plot(Tx(1:Nr));
xlabel('点数');
ylabel('幅度');
title('TX发射信号时域图(第1个chirp)');

% figure;
% n = 2;
% plot(Tx((n-1)*Nr+1 : n*Nr));
% xlabel('点数');
% ylabel('幅度');
% title('TX发射信号时域图(第n个chirp)');

% fig2.发射信号时频图
figure;
plot(t(1:Nr),freq(1:Nr));
xlabel('时间');
ylabel('频率');
title('TX发射信号时频图(第1个chirp)');

% fig3.接收信号时域图
figure;
plot(Rx(1:Nr));
xlabel('点数');
ylabel('幅度');
title('RX接收信号时域图(第1个chirp)');

% fig4.接收信号与发射信号的时频图
figure;
plot(t(1:Nr),freq(1:Nr));
hold on;
plot(t(1:Nr)+td(1:Nr),freq(1:Nr),'r');  % td:延迟时间
xlabel('时间');
ylabel('频率');
title('接收信号与发射信号时频图(第1个chirp)');
legend ('TX','RX');

% fig5.中频信号频谱
figure;
plot(db(abs(fft(Mix(1:Nr)))));  % 查看宽带的和频信号
                                % 将chirp的点数改为1024*256即可看到有一个门信号，但注意计算机内存。
xlabel('频率');
ylabel('幅度');
title('中频信号频谱');

%% 低通滤波 截止频率30MHz  采样频率120MHz
% fig6.中频信号时域
% Nr and Nd here would also define the size of Range and Doppler FFT respectively.
signal = reshape(Mix,Nr,Nd);
figure;
mesh(signal);
xlabel('脉冲数')       % Nd = 128
ylabel('距离门数');    % Nr = 1024
title('中频信号时域');


%% 距离维FFT
% fig7.第一个chirp脉冲的距离维FFT结果
sig_fft = fft(signal,Nr)./Nr;   % size(signal)
sig_fft = abs(sig_fft);
sig_fft = sig_fft(1:(Nr/2),:);  % 实信号FFT后频谱对称，只保留一半的频谱
figure;
plot(sig_fft(:,1));
xlabel('距离（频率）');
ylabel('幅度')
title('第一个chirp脉冲的距离维FFT结果')


%% fig8.距离FFT结果谱矩阵
figure;
mesh(sig_fft);
xlabel('chirp脉冲数')
ylabel('距离（频率）')
zlabel('幅度')
title('距离维FFT结果谱矩阵')
axis([0, Nd, 0, Nr/2, 0, 0.3])

%% 速度维FFT
% fig9.速度维FFT距离多普勒谱

signal2 = reshape(Mix,[Nr,Nd]);
sig_fft2 = fft2(signal2,Nr,Nd);

sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift(sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;
doppler_axis = linspace(-100,100,Nd);               % [-100,100]怎么确定的?
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);  % [-256,256]怎么确定的?
[x_max_index, y_max_index] = find(RDM==max(max(RDM))); % XY坐标旋转?
rdm_max = RDM(x_max_index, y_max_index); 

figure;
mesh(doppler_axis,range_axis,RDM);
xlabel('多普勒通道'); ylabel('距离通道'); zlabel('幅度（dB）');
title('速度维FFT距离多普勒谱');
hold on;
plot3(doppler_axis(y_max_index),range_axis(x_max_index),rdm_max,'k.','MarkerSize',5) 
text(doppler_axis(y_max_index),range_axis(x_max_index),rdm_max,'x轴坐标为多普勒门号')

%% 最终结果
K = 1;          % 本实验的设置,K=1
% 距离门号
distance_gate_index = find(sig_fft(:,1)==max(sig_fft(:,1)));
r0_hat = (distance_gate_index-1) * rangeRes * K;
r0 = 90;        % 目标距离设置 (max = 200m)
v0 = 10;        % 目标速度设置 (min =-70m/s, max=70m/s)

% 速度门号
velocity_gate_index = floor(doppler_axis(y_max_index));
v0_hat = (velocity_gate_index-1) * vres * K;

sprintf(char('r0 = %.2f(m), v0 = %.2f(m/s)'), r0, v0)
sprintf(char('r0_hat = %.2f(m), v0_hat = %.2f(m/s)'), r0_hat, v0_hat)

%% END
