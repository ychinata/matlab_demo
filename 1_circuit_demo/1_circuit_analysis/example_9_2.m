% 2021.11.22
% Fundamentals of Electric Circuits, 6e
% example 9.2

clf;clear;clc;close all;

fontsize = 40;
t = 0:0.01:2*pi;
u1 = -10 * cos(t + 5/18*pi);
u2 = 12 * sin(t - 1/18*pi);

plot(t, u1, '-r');hold on;
plot(t, u2, '-b');hold on;
plot(zeros(21), -10:10, t,zeros(size(t)),'-k');grid on;
legend({'u_1','u_2'},'FontSize',fontsize);