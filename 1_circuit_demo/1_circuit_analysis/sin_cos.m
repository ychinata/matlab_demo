% 2021.11.22
% Fundamentals of Electric Circuits, 6e

clf;clear;clc;close all;
I = 10;
fontsize = 40;
phi_1 = 0; phi_2 = pi/3;
t = 0:0.01:2*pi;
i1 = I * sin(t + phi_1);
i2 = I * sin(t + phi_2);
i3 = I * sin(t - phi_2);
i4 = 0.5*I * sin(t);
i5 = I * sin(t + pi);

subplot(2,2,1);
plot(t, i1, '-r');hold on;
plot(t, i2, '-b');hold on;
plot(zeros(21), -10:10, t,zeros(size(t)),'-k');grid on;
legend({'I_1','I_2'},'FontSize',fontsize);

subplot(2,2,2);
plot(t, i1, '-r');hold on;
plot(t, i3, '-b');hold on;
plot(zeros(21), -10:10, t,zeros(size(t)),'-k');grid on;
legend('I_1','I_2','FontSize',fontsize);

subplot(2,2,3);
plot(t, i1, '-r');hold on;
plot(t, i4, '-b');hold on;
plot(zeros(21), -10:10, t,zeros(size(t)),'-k');grid on;
legend('I_1','I_2','FontSize',fontsize);

subplot(2,2,4);
plot(t, i1, '-r');hold on;
plot(t, i5, '-b');hold on;
plot(zeros(21), -10:10, t,zeros(size(t)),'-k');grid on;
legend('I_1','I_2','FontSize',fontsize);

% title("");
