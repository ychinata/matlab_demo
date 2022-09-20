clc;
clear;
close all;

%% 双直流电源U_BB/U_CC
R_b = 1e3;
r_bb = 300;
beta = 100;
I_CQ = 2.22;
r_be = r_bb + (1+beta)*26/I_CQ

R_i = R_b + r_be;


%% 单直流电源不分压


%% 分压偏置



