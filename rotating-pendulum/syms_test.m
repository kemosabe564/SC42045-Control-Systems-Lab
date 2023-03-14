clear
close 
clc

syms theta_1 theta_2 theta_d_1 theta_d_2 u T_d

init_theta_1 = 1.5*pi; init_theta_2 = 0.1;

% constant variables
g = 9.81;
l_1 = 0.1;
l_2 = 0.1;
m_1 = 0.125;
m_2 = 0.05;
% params = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];
params = [-0.001, 0.077, 0.2, 0.00002, 20.684, 0.00002, 15, 0.03];

U = [u params];


% varying variables
u = U(1);
c_1_0 = U(2);
c_2_0 = U(3);
I_1_0 = U(4);
I_2_0 = U(5);
b_1_0 = U(6);
b_2_0 = U(7);
k_m_0 = U(8);
tau_e_0 = U(9);


% calculate other variables
P_1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
P_2 = m_2 * c_2_0 * c_2_0 + I_2_0;
P_3 = m_2 * l_1 * c_2_0;

g_1 = (m_1 * c_1_0 + m_2 * l_1) * g;
g_2 = m_2 * c_2_0 * g;







% T_prev = 0; T = 0;
% T_d = (T - T_prev)/0.001;


% construct the vector for matrix calculation

% theta_vec = [theta_1; theta_2];
theta_d_vec = [theta_d_1; theta_d_2];
% theta_d_d_vec = [theta_1; theta_2];
T = k_m_0 * u - tau_e_0 * T_d;
T_vec = [T; 0];
% theta_dd = zeros(2, 1);


% matrix
M = [P_1 + P_2 + 2 * P_3 * cos(theta_2) P_2 + P_3 * cos(theta_2);
    P_2 + P_3 * cos(theta_2)            P_2];

C = [b_1_0 - P_3 * theta_d_2 * sin(theta_2)  -P_3 * (theta_d_1 + theta_d_2) * sin(theta_2);
    P_3 * theta_d_1 * sin(theta_2)           b_2_0];

G = [-g_1 * sin(theta_1) - g_2 * sin(theta_1 + theta_2);
     -g_2 * sin(theta_1 + theta_2)];


M_inv = inv(M);

theta_dd = M_inv * T_vec - M_inv * C * theta_d_vec- M_inv * G;

theta_dd_A = - M_inv * C * theta_d_vec- M_inv * G;
theta_dd_B = M_inv * T_vec;

T_prev = T;

theta_dd
% y = sin(t1);
% 
% subs(y, pi/3)
% subs(T_d1, 0)
% subs(theta_dd, [theta_1 theta_2 theta_d_1 theta_d_2], [0, 0, 0, 0])
% subs(theta_dd, [T_d], [0])

% t = 0 : 0.001 : 10;
% U = [0 1];
% 
% y = sim('system_model', t, [], U);
% y = [y.yout{1}.Values.Data y.yout{2}.Values.Data];
% plot(t, y(:, 1)')
% f_2 = theta_dd(1);
% f_4 = theta_dd(2);
dtdd_dt1 = diff(theta_dd_A, 'theta_1');
dtdd_dt2 = diff(theta_dd_A, 'theta_2');
dtdd_dtd1 = diff(theta_dd_A, 'theta_d_1');
dtdd_dtd2 = diff(theta_dd_A, 'theta_d_2');

A_2 = [dtdd_dt1(1) dtdd_dtd1(1) dtdd_dt2(1) dtdd_dtd2(1)];
A_4 = [dtdd_dt1(2) dtdd_dtd1(2) dtdd_dt2(2) dtdd_dtd2(2)];

A = [0 1 0 0;
    A_2;
    0 0 0 1;
    A_4;]; 

B_2 = diff(theta_dd_B(1), 'u');
B_4 = diff(theta_dd_B(2), 'u');

B = [0;
     B_2;
     0;
     B_4;];

x0 = [init_theta_1; 0; init_theta_2; 0]; %[theta_1; theta_1_d; theta_2; _theta_2_d] (?????)

A

B

A = subs(A, [theta_1 theta_2 theta_d_1 theta_d_2], [init_theta_1, init_theta_2, 0, 0])

B = subs(B, [theta_1 theta_2 theta_d_1 theta_d_2], [init_theta_1, init_theta_2, 0, 0])
% 
A = double(A)

B = double(B)

C = [1 0 0 0;
     0 0 1 0;]; % because we want to see theta_1 and theta_2

D = zeros(2,1);