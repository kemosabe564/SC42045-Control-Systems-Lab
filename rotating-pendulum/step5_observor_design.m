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

%% load the ss model

% load the data
load('System.mat')
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


%% observer K design
 
Pole1 = -202;
Pole2 = -203;
Pole3 = -204;
Pole4 = -205;
Pole5 = -220;
J = [Pole1 Pole2 Pole3 Pole4 Pole5];
clear Pole1 Pole2 Pole3 Pole4 Pole5

A_ = A';
B_ = C';
C_ = B';
D_ = D';
G_ = ss(A_, B_, C_, D_);
disp("system matrix: ")
disp(G_)

pole(G_)
Ke = place(A_, B_, 1*J)';%number in front of the J is the scaling 

save('step5_observor.mat','Ke')


%% test the observer
RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 1;

% test input
u = 0.1*sin(2*pi*f*t); 


simulink_input = timeseries(u,t); 

sinulink_output = sim('step5_observor_test');

y1 = sinulink_output.oberver_nonlinear_output;
y2 = sinulink_output.observer_output;

subplot(2, 2, 1)
plot(t, y1(:, 1)')
xlabel("t"); ylabel("\theta_1")
title("nonlinear-model")

subplot(2, 2, 2)
plot(t, y1(:, 2)')
xlabel("t"); ylabel("\theta_2")
title("nonlinear-model")

subplot(2, 2, 3)
plot(t, y2(:, 1)')
xlabel("t"); ylabel("\theta_1")
title("observer")

subplot(2, 2, 4)
plot(t, y2(:, 2)')
xlabel("t"); ylabel("\theta_2")
title("observer")


%% MSE compare

% MSE for observer
sum(y1(:, 1)' - y2(:, 1)').^2 / length(y1(:, 1)')

sum(y1(:, 2)' - y2(:, 2)').^2 / length(y1(:, 1)')

