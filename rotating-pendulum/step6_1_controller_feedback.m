clear
clc
close all

%% setup for Simulink
RunTime = 10;
time_step = 0.001;

params = [-0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 7.27570530021582, 2.78577414601457e-05, 50.9998023466922, 0.01300000000002200];  %found via white-box

g = 9.81;
l_1 = 0.1;
l_2 = 0.1;
m_1 = 0.125;
m_2 = 0.05;

c_1_0 = params(1);
c_2_0 = params(2);
I_1_0 = params(3);
I_2_0 = params(4);
b_1_0 = params(5);
b_2_0 = params(6);
k_m_0 = params(7);
tau_e_0 = params(8);
params = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0320000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 7.27570530021582, 2.78577414601457e-05, 50.9998023466922, 0.01300000000002200];
P1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
P2 = m_2 * c_2_0 * c_2_0 + I_2_0;
P3 = m_2 * l_1 * c_2_0;

g1 = (m_1 * c_1_0 + m_2 * l_1) * g;
g2 = m_2 * c_2_0 * g;

%% load the ss model and setup

% load the data
load('step4_linearized_system.mat')
params = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0400000121036330, 0.0303451968350115, 0.1000000000017210, 1.00882387117299e-05, 10.27570530021582, 1.78577414601457e-05, 50.9998023466922, 0.01500000000002200];

theta_1_0 = x_op(1);
theta_d_1_0 = x_op(2);
theta_2_0 = x_op(3);
theta_d_2_0 = x_op(4);
T_0 = x_op(5);

x_op_relative = [0; 0; 0; 0; 0];

% form a state-space model
inputs = {'u'};
outputs = {'theta_1 theta_2'};
G = ss(A, B, C, D, 'inputname', inputs, 'outputname', outputs);

disp("system matrix: ")
disp(G)

% plot the impulse response of the lineaized system
t = 0 : 0.01 : 10;
figure;
impulse(G, t)

% display the eigenvalue of the ss model, Routh-Hurwitz
disp("eig(A): ")
pole(G)

% check the stability via Lyapunov function
P = lyap(A, eye(5))

% conclusion: the system is stable at this initial condition, but the
% performance is not good, e.g. the raising time is too long

%% load the oberser

load("step5_observor.mat")

%% pole placement
 
Pole1 = -202;
Pole2 = -203;
Pole3 = -204;
Pole4 = -205;
Pole5 = -220;
J = [Pole1 Pole2 Pole3 Pole4 Pole5];
clear Pole1 Pole2 Pole3 Pole4 Pole5


K1 = place(A, B, 0.1*J);%number in front of the J is the scaling 

% both method give the same output, K1 = K2
K = K1;
disp('K = ');
disp(K);
clear K1 K2

Ac = (A - B*K);

G1 = ss(Ac, B, C, D);

pole(G1)

figure;
impulse(G1, t)


%% LQR

% Q = eye(5);

Q = diag([1e4, 1, 1e4, 1, 1]);

R = 1 * eye(1);

K_lqr = lqr(A, B, Q, R);

disp("K_lqr: ")
disp(K_lqr)

A_lqr = (A - B*K_lqr);

G_Lqr = ss(A_lqr, B, C, D);

pole(G_Lqr)

figure;
impulse(G_Lqr, t)
