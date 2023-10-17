% h00421956
% 2022.3.17

clc;clear;
%%%%%%% input para %%%%%%%%
% example 2.2.1 fuzhitong_6e
U_CC = 20; % V
R_b = 470; % kOhm
R_c = 6; % kOhm
R_L = 4; % kOhm
beta = 45;
loadFlag = 1;
%%%%%%%%%%%%%%%%%
[I_BQ, r_be_kOhm, A_u] = calc_bias_base_V_CC(U_CC,R_b,R_c,R_L,beta,loadFlag);
disp('Output Para:');
fprintf('I_BQ_mA=%f\n r_be_kOhm=%f\n A_u=%f\n', I_BQ, r_be_kOhm, A_u);
%[I_BQ, r_be_kOhm, A_u]

%% 双直流电源U_BB/U_CC
R_b = 1e3;
r_bb = 300;
beta = 100;
I_CQ = 2.22;
r_be = r_bb + (1+beta)*26/I_CQ

R_i = R_b + r_be;


%% 单直流电源不分压todo

%% 分压偏置todo
