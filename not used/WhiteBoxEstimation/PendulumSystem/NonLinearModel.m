clear,clc
close all
% in this file, we will first use the equations from the assignment to
% symbollically linearize the system. We will then linearize around an
% operating point.

%% symbolic values:
syms theta_1 theta_2 theta_d_1 theta_d_2 u T_d T% state symbolics
syms c_1 c_2 I_1 I_2 b_1 b_2 k_m tau_e % parameter symbolics

%% given correct parameters:
g = 9.81;
l_1 = 0.1;
l_2 = 0.1;
m_1 = 0.125;
m_2 = 0.046955;

%% paper equations
% calculate variables for in assignment matrices
P1 = m_1 * c_1 * c_1 + m_2 * l_1 * l_1 + I_1;
P2 = m_2 * c_2 * c_2 + I_2;
P3 = m_2 * l_1 * c_2;

g1 = (m_1 * c_1 + m_2 * l_1) * g;
g2 = m_2 * c_2 * g;

T_equation = T == k_m * u - tau_e * T_d; % written like this because of subs() below.

% symbolic states
theta_d_vec = [theta_d_1; theta_d_2]; 
T_vec = [T; 0];

% assignment matrices
M = [P1 + P2 + 2 * P3 * cos(theta_2), P2 + P3 * cos(theta_2);
    P2 + P3 * cos(theta_2),            P2];
M_inv = inv(M);

C = [b_1 - P3 * theta_d_2 * sin(theta_2)  -P3 * (theta_d_1 + theta_d_2) * sin(theta_2);
    P3 * theta_d_1 * sin(theta_2)           b_2];

G = [-g1 * sin(theta_1) - g2 * sin(theta_1 + theta_2);
     -g2 * sin(theta_1 + theta_2)];

%% rewrite to x_d = f(x,u)

% theta_dd = f(x):
theta_dd = M_inv * T_vec - M_inv * C * theta_d_vec - M_inv * G;  %#ok<MINV> 
theta_dd = subs(theta_dd,T_d,T_equation); % so we have a function of T, not T_d.

T_d = solve(T_equation,T_d);

% combine all to a system equation x_d = f(x,u)
system_f = [theta_d_1;theta_dd(1);theta_d_2;theta_dd(2);T_d];

% Make matlab function of this Non-Linear function, so we can use it in the
% whitebox estimator, and the other scripts.
NonLinFunc = matlabFunction(system_f);

disp(NonLinFunc);

%% Save this to file
save('NonLinFunc.mat','NonLinFunc')
% this can be used in other files easily, with all the right values.












