clear
clc
close all

%% setup for Simulink
RunTime = 10;
time_step = 0.001;

load("params.mat")
g = params(1);
l1 = params(2);
l2 = params(3);
m1 = params(4);
m2 = params(5);

c1 = params(6);
c2 = params(7);
I1 = params(8);
I2 = params(9);
b1 = params(10);
b2 = params(11);
km = params(12);
tau_e = params(13);

P1 = m1 * c1 * c1 + m2 * l1 * l1 + I1;
P2 = m2 * c2 * c2 + I2;
P3 = m2 * l1 * c2;

g1 = (m1 * c1 + m2 * l1) * g;
g2 = m2 * c2 * g;


%% load the ss model and setup

% load the data
load('step4_linearized_system.mat')

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
 
Pole1 = -50;
Pole2 = -60;
Pole3 = -70;
Pole4 = -80;
Pole5 = -75;
J = [Pole1 Pole2 Pole3 Pole4 Pole5];
clear Pole1 Pole2 Pole3 Pole4 Pole5


K1 = place(A, B, 1*J);%number in front of the J is the scaling 

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


hwinit