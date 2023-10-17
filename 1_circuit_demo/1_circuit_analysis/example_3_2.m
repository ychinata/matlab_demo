
% 2021.10.26
% Fundamentals of Electric Circuits, 6e



clear; clc;
A = [3 -2 -1; 
    -4, 7, -1;
    2 -3 1];
B = [12 0 0]';
V = A \ B; % inv(V)*B

C = [1 1 -1;
    1 -2 0;
    0 10 2];
D = [0 0 20]';
I = C \ D;
I