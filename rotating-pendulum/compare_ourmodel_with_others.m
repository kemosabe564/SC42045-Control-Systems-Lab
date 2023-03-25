clear 
close all
clc

RunTime = 10;
time_step = 0.001;

g = 9.81;
l_1 = 0.1;
l_2 = 0.1;
m_1 = 0.125;
m_2 = 0.05;

params = [-0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 10.27570530021582, 2.78577414601457e-05, 65.9998023466922, 0.01300000000002200];  %found via white-box
c_1_0 = params(1);
c_2_0 = params(2);
I_1_0 = params(3);
I_2_0 = params(4);
b_1_0 = params(5);
b_2_0 = params(6);
k_m_0 = params(7);
tau_e_0 = params(8);
% syms c_1_0 c_2_0 I_1_0 I_2_0 b_1_0 b_2_0 k_m_0 tau_e_0

%% paper equations
% calculate variables for in assignment matrices
P1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
P2 = m_2 * c_2_0 * c_2_0 + I_2_0;
P3 = m_2 * l_1 * c_2_0;

g1 = (m_1 * c_1_0 + m_2 * l_1) * g;
g2 = m_2 * c_2_0 * g;

t = 0 : 0.001 : 10;
f = 1;
u = 0.1*sin(2*pi*f*t); 
simulink_input = timeseries(u, t);

init_theta_1 = 0; init_theta_2 = 0;

params = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 10.27570530021582, 2.78577414601457e-05, 65.9998023466922, 0.01300000000002200];



out = sim("nonlinear.slx");


% params = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0300000121036330, 0.0303451968350115, 0.1000000000017210, 1.00882387117299e-05, 10.27570530021582, 1.78577414601457e-05, 65.9998023466922, 0.01300000000002200];


out1 = sim('nonlinear_model');

figure;
plot(t, out1.nonlinearSim(:, 1) + 0.01)
hold on
plot(t, out.nonlinearSim(:, 1))

figure;
plot(t, out1.nonlinearSim(:, 2) + 0.5)
hold on
plot(t, out.nonlinearSim(:, 2))
