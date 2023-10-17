% Func: calc Q point of voltage-divider bias
% h00421956
% 2022.3.17
clc; clear;
%%%%%%% input para %%%%%%%%
% example 2.2.2 fuzhitong_6e
% U_CC = 12; % V
% R_b_1 = 20; % kOhm, up
% R_b_2 = 10; % kOhm, down
% R_c = 2; % kOhm
% R_L = 4; % kOhm
% R_e = 2; % kOhm
% beta = 37.5;
% loadFlag = 0;

% example 2.2.3 fuzhitong_6e
U_CC = 12; % V
R_b_1 = 20; % kOhm, up
R_b_2 = 10; % kOhm, down
R_c = 2; % kOhm
R_L = 6; % kOhm
R_e = 2; % kOhm
beta = 40;
loadFlag = 1;
%%%%%%%%%%%%%%%%%
U_BEQ = 0.7; % V
% calculate static para
U_BQ = R_b_2 / (R_b_1 + R_b_2) * U_CC;
I_EQ = (U_BQ - U_BEQ) / R_e;
I_CQ = I_EQ; % I_CQ = beta / (beta+1) * I_EQ
U_CEQ = U_CC - I_CQ * (R_c + R_e);
I_BQ = I_CQ / beta;


r_be_kOhm = (300 + 26 / I_BQ) / 1000; % kOhm
% r_be_kOhm = 1;

% R'_L
if (loadFlag == 1)
    R_L_prime = (R_L * R_c) / (R_L + R_c);
else
    R_L_prime = R_c;
end

% calculate dynamic para
r_i = 1 / (1/R_b_1 + 1/R_b_2 + 1/r_be_kOhm);
% r_i = r_be_kOhm;
%
r_o = R_c;
A_u = - beta * R_L_prime / r_be_kOhm;

%%%%%%% input para %%%%%%%%
% [U_BQ,I_CQ,U_CEQ,I_BQ,r_be,A_u]
U_BQ
I_CQ
U_CEQ
I_BQ
r_be_kOhm
r_i
A_u
