% Func: calc Q point of base-V_CC bias
% h00421956
% 2022.3.17

%%%%%%% input para %%%%%%%%
% example 2.2.1 fuzhitong_6e
% U_CC = 20; % V
% R_b = 470; % kOhm
% R_c = 6; % kOhm
% R_L = 4; % kOhm
% beta = 45;
% loadFlag = 1;
%%%%%%%%%%%%%%%%%
function[I_BQ, r_be_kOhm, A_u] = calc_bias_base_V_CC(U_CC,R_b,R_c,R_L,beta,loadFlag)
    U_BEQ = 0.7; % V
    % calculate
    I_BQ = (U_CC - U_BEQ) / R_b;
    r_be_kOhm = (300 + 26 / I_BQ) / 1000; % kOhm

    % R'_L
    if (loadFlag == 1)
        R_L_prime = (R_L * R_c) / (R_L + R_c);
    else
        R_L_prime = R_c;
    end

    A_u = - beta * R_L_prime / r_be_kOhm;

%%%%%%% input para %%%%%%%%
% [I_BQ,r_be,A_u]
end
