% 2023.4.26
% 将原始数据处理后的txt文件重新载入
%%
tic
%%
clear;
clc;
clear x_ds_sample
clear y_ids_sample
clear y_qds_sample
% 一个chirp有250个adc数据，一秒有20个chirp，5k个数据，一分钟有30w个adc数据

data_ds = importdata('data/0403-1_ds-338750.txt');
x_ds = data_ds(:, 1);
y_ids = data_ds(:, 2);
y_qds = data_ds(:, 3);

%%
% 读取原始文件指定行
% tic 
% fid = fopen('data/0403-1.txt'); % 耗时约10s
% % fid = fopen('data/0403-1-10k.txt');
% % 读取指定行
% gap = 250*50;
% i = 1;
% row_num = gap*i+1+2;  % 前2行是表头，从第3行开始
% for ii = 1:row_num-1
%     fgetl(fid);  % 必须逐行读取
% end
% row_data = fgetl(fid);
% % 关闭文件
% fclose(fid);
% toc
% format shortG
% format long g
% disp(data_ds(i*250+1,:))
% disp(row_data)
%%
% 画图
len = 1000;
cycle = 0.004;
t = 0:cycle:(len-1)*cycle;
plot(t, y_ids(1:len), 'r');
hold on;
plot(t, y_qds(1:len), 'b');

xlabel('(ms)')
ylabel('(mV)')
title('1kHz正弦波，采样率100kHz')
%%
toc
