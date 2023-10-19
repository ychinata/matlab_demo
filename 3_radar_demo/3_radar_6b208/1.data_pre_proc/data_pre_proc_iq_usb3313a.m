% 2023.10.19
% USB3313A data pre proc 

%{ 
USB 3133A数据格式
文件标志:DAQ
采样率:250000
通道数:2
电压_0,电压_1
2.26354151881605,2.25659792010391
2.24397319517275,2.23197970648814
2.22030183592682,2.21209576472156
2.19505238606449,2.19442114981793
2.16759360933921,2.18337451550317
2.14045045073721,2.17453720805135
2.1104667290257,2.16854046370905
%}



filename = 'data/1019_iq_24g_500k_3_1.csv';
adcDataRaw = importdata(filename);

freq_s = 250000;
t_gap = 1 / freq_s;

y_i = adcDataRaw.data(:, 1);
y_q = adcDataRaw.data(:, 2);
data_len = size(y_i);

x_t = 0 : t_gap : (data_len-1)*t_gap;
x_t = x_t';

plot_len = 1000;
plot(x_t(1:plot_len), y_i(1:plot_len), 'r');
hold on;
plot(x_t(1:plot_len), y_q(1:plot_len), 'b');

xlabel('(ms)')
ylabel('(mV)')
title('1kHz正弦波，采样率100kHz')

