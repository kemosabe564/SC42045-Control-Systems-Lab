clc
clear
close all

%% 
%matrices as given in the assignment

function theta_dd   = get_theta_dt_dt(u, theta_1, theta_2, theta_d_1, theta_d_2)

% constant variables
g = 9.81;
l_1 = 0.1;
l_2 = 0.1;
m_1 = 0.125;
m_2 = 0.05;
params = [-0.001, 0.077, 0.2, 0.00004, 20.684, 0.0004, 15, 0.03];
% params = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];

% varying variables
c_1_0 = params(1);
c_2_0 = params(2);
I_1_0 = params(3);
I_2_0 = params(4);
b_1_0 = params(5);
b_2_0 = params(6);
k_m_0 = params(7);
tau_e_0 = params(8);


% calculate other variables
P_1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
P_2 = m_2 * c_2_0 * c_2_0 + I_2_0;
P_3 = m_2 * l_1 * c_2_0;

g_1 = (m_1 * c_1_0 + m_2 * l_1) * g;
g_2 = m_2 * c_2_0 * g;


% construct the vector for matrix calculation

% theta_vec = [theta_1; theta_2];
theta_d_vec = [theta_d_1; theta_d_2];
% theta_d_d_vec = [theta_1; theta_2];
T = k_m_0 * u;
T_vec = [T; 0];
theta_dd = zeros(2, 1);

% matrix
M = [P_1 + P_2 + 2 * P_3 * cos(theta_2) P_2 + P_3 * cos(theta_2);
    P_2 + P_3 * cos(theta_2)            P_2];

C = [b_1_0 - P_3 * theta_d_2 * sin(theta_2)  -P_3 * (theta_d_1 + theta_d_2) * sin(theta_2);
    P_3 * theta_d_1 * sin(theta_2)           b_2_0];

G = [-g_1 * sin(theta_1) - g_2 * sin(theta_1 + theta_2);
     -g_2 * sin(theta_1 + theta_2)];

M_inv = inv(M);

theta_dd = M_inv * T_vec - M_inv * C * theta_d_vec- M_inv * G;