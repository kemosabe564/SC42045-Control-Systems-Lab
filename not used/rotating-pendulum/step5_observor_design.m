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

%% load the ss model

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


%% observer K design
 
Pole1 = -70;
Pole2 = -71;
Pole3 = -75;
Pole4 = -76;
Pole5 = -72;
J = [Pole1 Pole2 Pole3 Pole4 Pole5];
clear Pole1 Pole2 Pole3 Pole4 Pole5

A_ = A';
B_ = C';
C_ = B';
D_ = D';
Ke = place(A_, B_, 0.5*J)';%number in front of the J is the scaling 

save('step5_observor.mat','Ke')


% %% test the observer
% RunTime = 1;
% time_step = 0.001;
% t = 0 : time_step : RunTime;
% f = 1;
% 
% % pretest
% 
% u = 0.0*sin(2*pi*2*f*t); 
% 
% hwinit
% 
% simulink_input = timeseries(-u,t); 
% 
% simulink_output = sim('step5_setup_obsservor_test1.mdl');
% 
% setup = simulink_output.setup(:, :);
% 
% theta_1_0 = sum(setup(:, 1)) / length(setup(:, 1));
% theta_2_0 = sum(setup(:, 2)) / length(setup(:, 1));
% 
% % test input
% Delay = 5;
% t_span = 5;
% RunTime = t_span + Delay;
% time_step = 0.001;
% t = 0 : time_step : RunTime;
% f = 1;
% 
% 
% u = 0.1*sin(2*pi*f*t) + 0.2*sin(3*pi*2*f*t) +  0.1*sin(2*pi*2*f*t); 
% 
% hwinit
% 
% simulink_input = timeseries(-u, t); 
% 
% simulink_output = sim('step5_setup_obsservor_test1.mdl');
% % 
% % t = t(Delay : end);
% % 
% nonlin = simulink_output.nonlinear(:, :);
% obs = simulink_output.observer(:, :)';
% lin = simulink_output.linear(:, :)';
% % 
% % nonlin = nonlin(Delay : end);
% % obs = obs(Delay : end);
% % lin = lin(Delay : end);
% 
% figure;
% 
% k = 1;
% subplot(5, 1, k);
% plot(t', (obs(:, k)));
% hold on
% plot(t', nonlin(:, k) - pi);
% hold on
% plot(t', lin(:, k));
% xlabel("Time/s"); ylabel("Angle/rad")
% title("\theta_1 comparison")
% legend({'observer', 'nonlinear model', 'linear model'})
% 
% k = 2;
% subplot(5, 1, k);
% plot(t', obs(:, k));
% hold on
% plot(t', nonlin(:, k));
% hold on
% plot(t', lin(:, k));
% xlabel("Time/s"); ylabel("Angle/rad")
% title("\theta_1 dot comparison")
% legend({'observer', 'nonlinear model', 'linear model'})
% 
% k = 3;
% subplot(5, 1, k);
% plot(t', (obs(:, k)));
% hold on
% plot(t', nonlin(:, k));
% hold on
% plot(t', lin(:, k));
% xlabel("Time/s"); ylabel("Angle/rad")
% title("\theta_2 comparison")
% legend({'observer', 'nonlinear model', 'linear model'})
% 
% k = 4;
% subplot(5, 1, k);
% plot(t', obs(:, k));
% hold on
% plot(t', nonlin(:, k));
% hold on
% plot(t', lin(:, k));
% xlabel("Time/s"); ylabel("Angle/rad")
% title("\theta_2 dot comparison")
% legend({'observer', 'nonlinear model', 'linear model'})
% 
% k = 5;
% subplot(5, 1, k);
% plot(t', obs(:, k));
% hold on
% plot(t', nonlin(:, k));
% hold on
% plot(t', lin(:, k));
% xlabel("Time/s"); ylabel("Angle/rad")
% title("T comparison")
% legend({'observer', 'nonlinear model', 'linear model'})
% 
% 
% %% MSE compare
% 
% % MSE for observer
% k = 1;
% sum((obs(:, k) - pi - nonlin(:, k)).^2) / length(obs(:, k))
% k = 2;
% sum((obs(:, k) - nonlin(:, k)).^2) / length(obs(:, k))
% k = 3;
% sum((obs(:, k) - nonlin(:, k)).^2) / length(obs(:, k))
% k = 4;
% sum((obs(:, k) - nonlin(:, k)).^2) / length(obs(:, k))
% k = 5;
% sum((obs(:, k) - nonlin(:, k)).^2) / length(obs(:, k))
% 
