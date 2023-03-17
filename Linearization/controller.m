clear,clc
close all

%% load the ss model

% load the data
load('System.mat')

theta_1_0 = x_op(1);
theta_d_1_0 = x_op(2);
theta_2_0 = x_op(3);
theta_d_2_0 = x_op(4);
T_0 = x_op(5);

% form a state-space model
inputs = {'u'};
outputs = {'theta_1 theta_2'};
G = ss(A, B, C, D, 'inputname', inputs, 'outputname', outputs);

disp("system matrix: ")
disp(G)

% with the following, we can discretize the system
% h = 0.001;
% H = c2d(G, h);
% G = d2c(H)

% plot the impulse response of the lineaized system
t = 0 : 0.01 : 10;
figure;
impulse(G, t)

% display the eigenvalue of the ss model, Routh-Hurwitz
disp("eig(A): ")
pole(G)
% give the same result
% disp("eig(A): ")
% eig(A)

% check the stability via Lyapunov function
P = lyap(A, eye(5))

% conclusion: the system is stable at this initial condition, but the
% performance is not good, e.g. the raising time is too long

%% pole placement
 
P1 = -3 + 0.1092i;
P2 = -3 - 0.1092i;
P3 = -6;
P4 = -7;
P5 = -8;
J = [P1 P2 P3 P4 P5];
clear P1 P2 P3 P4 P5


K1 = place(A, B, J);
K2 = acker(A, B, J);

% both method give the same output, K1 = K2
K = K1;
disp('K = ');
disp(K)
clear K1 K2

Ac = (A - B*K);

G1 = ss(Ac, B, C, D);

pole(G1)

figure;
impulse(G1, t)


%% observer K design

A_ = A';
B_ = C';
C_ = B';
D_ = D';
G_ = ss(A_, B_, C_, D_);
disp("system matrix: ")
disp(G_)

pole(G_)
Ke = place(A_, B_, J)';

%% LQR

Q = eye(5);
R = eye(1);
K_lqr = lqr(A, B, Q, R);

disp("K_lqr: ")
disp(K_lqr)