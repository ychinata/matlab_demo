% 卡尔曼滤波：温度测量
% 修改自Andrew D. Straw的Python代码
% Matlab代码源自 "现代医学信号处理" 林岚, 科学出版社, 2016
% type by xy, 2023.1.10
clear all;
close all;
clc;

%% 参数初始化
n_iter = 100;
sz = [n_iter, 1];
x = 24; % 温度
Q = 4e-4; % 过程方差
R = 0.25; % 测量方差
z = x + sqrt(R) * randn(sz); % 温度计测量结果

%% 对数组进行初始化
x_hat = zeros(sz); % 温度的后验估计
P = zeros(sz);  % 后验估计的方差
x_hat_minus = zeros(sz);    % 温度估计的先验估计
P_minus = zeros(sz);        % 先验估计的方差
K = zeros(sz);              % 卡尔曼增益

%% 初始估计
x_hat(1) = 23.5;
P(1) = 1;
for k = 2:n_iter
    % 预测
    x_hat_minus(k) = x_hat(k-1);
    P_minus(k) = P(k-1) + Q;
    % 校正
    K(k) = P_minus(k) / (P_minus(k) + R);
    x_hat(k) = x_hat_minus(k) + K(k)*(z(k)-x_hat_minus(k));
    P(k) = (1-K(k)) * P_minus(k);
end

%% 画图
% 图1.真实值与最优估计值的比较
fontsize = 14;
linewidth = 3;
figure();
plot(z, 'k+');
hold on;
plot(x_hat, 'b-', 'LineWidth', linewidth)
hold on;
plot(x*ones(sz), 'g-', 'LineWidth', linewidth)
legend('温度计的测量结果', '卡尔曼滤波后验估计', '真实值')
x1 = xlabel('时间(分钟)');
y1 = ylabel('温度');
set(x1, 'fontsize', fontsize);
set(y1, 'fontsize', fontsize);
hold off;

% 图2.最优估计值的方差
set(gca, 'Fontsize', fontsize);
figure();
valid_iter = 2:n_iter;
plot(valid_iter, P(valid_iter), 'LineWidth', linewidth);
legend('后验估计的误差估计');
x1 = xlabel('时间(分钟)');
y1 = ylabel('℃^2');
set(x1, 'fontsize', fontsize);
set(y1, 'fontsize', fontsize);
set(gca, 'Fontsize', fontsize);

