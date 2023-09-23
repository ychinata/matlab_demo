% �������˲����¶Ȳ���
% �޸���Andrew D. Straw��Python����
% Matlab����Դ�� "�ִ�ҽѧ�źŴ���" ���, ��ѧ������, 2016
% type by xy, 2023.1.10
clear all;
close all;
clc;

%% ������ʼ��
n_iter = 100;
sz = [n_iter, 1];
x = 24; % �¶�
Q = 4e-4; % ���̷���
R = 0.25; % ��������
z = x + sqrt(R) * randn(sz); % �¶ȼƲ������

%% ��������г�ʼ��
x_hat = zeros(sz); % �¶ȵĺ������
P = zeros(sz);  % ������Ƶķ���
x_hat_minus = zeros(sz);    % �¶ȹ��Ƶ��������
P_minus = zeros(sz);        % ������Ƶķ���
K = zeros(sz);              % ����������

%% ��ʼ����
x_hat(1) = 23.5;
P(1) = 1;
for k = 2:n_iter
    % Ԥ��
    x_hat_minus(k) = x_hat(k-1);
    P_minus(k) = P(k-1) + Q;
    % У��
    K(k) = P_minus(k) / (P_minus(k) + R);
    x_hat(k) = x_hat_minus(k) + K(k)*(z(k)-x_hat_minus(k));
    P(k) = (1-K(k)) * P_minus(k);
end

%% ��ͼ
% ͼ1.��ʵֵ�����Ź���ֵ�ıȽ�
fontsize = 14;
linewidth = 3;
figure();
plot(z, 'k+');
hold on;
plot(x_hat, 'b-', 'LineWidth', linewidth)
hold on;
plot(x*ones(sz), 'g-', 'LineWidth', linewidth)
legend('�¶ȼƵĲ������', '�������˲��������', '��ʵֵ')
x1 = xlabel('ʱ��(����)');
y1 = ylabel('�¶�');
set(x1, 'fontsize', fontsize);
set(y1, 'fontsize', fontsize);
hold off;

% ͼ2.���Ź���ֵ�ķ���
set(gca, 'Fontsize', fontsize);
figure();
valid_iter = 2:n_iter;
plot(valid_iter, P(valid_iter), 'LineWidth', linewidth);
legend('������Ƶ�������');
x1 = xlabel('ʱ��(����)');
y1 = ylabel('��^2');
set(x1, 'fontsize', fontsize);
set(y1, 'fontsize', fontsize);
set(gca, 'Fontsize', fontsize);

