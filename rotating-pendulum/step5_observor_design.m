clear
clc
close all

%% setup for Simulink
RunTime = 3;
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
Pole2 = -65;
Pole3 = -60;
Pole4 = -55;
Pole5 = -50;
J = [Pole1 Pole2 Pole3 Pole4 Pole5];
clear Pole1 Pole2 Pole3 Pole4 Pole5

A_ = A';
B_ = C';
C_ = B';
D_ = D';
Ke = place(A_, B_, 3*J)';%number in front of the J is the scaling 

save('step5_observor.mat','Ke')


%% test the observer
RunTime = 5;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 1;

% test input
u = 0.3*sin(2*pi*f*t); 

hwinit

simulink_input = timeseries(u,t); 

simulink_output = sim('step5_setup_obsservor_test1.mdl');

nonlin = simulink_output.nonlinear(:, :);
obs = simulink_output.observer(:, :)';
lin = simulink_output.linear(:, :)';

figure;

k = 1;
subplot(5, 1, k);
plot(t', obs(:, 1) - pi);
hold on
plot(t', nonlin(:, k) - pi);
hold on
plot(t', lin(:, k));
xlabel("Time/s"); ylabel("Angle/rad")
title("\theta_1 comparison")
legend({'observer', 'nonlinear model', 'linear model'})

k = 2;
subplot(5, 1, k);
plot(t', obs(:, 1));
hold on
plot(t', nonlin(:, k));
hold on
plot(t', lin(:, k));
xlabel("Time/s"); ylabel("Angle/rad")
title("\theta_1 dot comparison")
legend({'observer', 'nonlinear model', 'linear model'})

k = 3;
subplot(5, 1, k);
plot(t', obs(:, 1));
hold on
plot(t', nonlin(:, k));
hold on
plot(t', lin(:, k));
xlabel("Time/s"); ylabel("Angle/rad")
title("\theta_2 comparison")
legend({'observer', 'nonlinear model', 'linear model'})

k = 4;
subplot(5, 1, k);
plot(t', obs(:, 1));
hold on
plot(t', nonlin(:, k));
hold on
plot(t', lin(:, k));
xlabel("Time/s"); ylabel("Angle/rad")
title("\theta_2 dot comparison")
legend({'observer', 'nonlinear model', 'linear model'})

k = 5;
subplot(5, 1, k);
plot(t', obs(:, 1));
hold on
plot(t', nonlin(:, k));
hold on
plot(t', lin(:, k));
xlabel("Time/s"); ylabel("Angle/rad")
title("T comparison")
legend({'observer', 'nonlinear model', 'linear model'})


% 
% figure;
% subplot(2, 2, 1)
% plot(t, y1(:, 1)' - pi)
% xlabel("t"); ylabel("\theta_1")
% title("nonlinear-model")
% 
% subplot(2, 2, 2)
% plot(t, y1(:, 2)')
% xlabel("t"); ylabel("\theta_2")
% title("nonlinear-model")
% 
% subplot(2, 2, 3)
% plot(t, y2(:, 1)')
% xlabel("t"); ylabel("\theta_1")
% title("observer")
% 
% subplot(2, 2, 4)
% plot(t, y2(:, 2)')
% xlabel("t"); ylabel("\theta_2")
% title("observer")
% 
% 
% % calculate the velocity
% 
% theta1_d_obs = sinulink_output.observer_states(:, 2);
% theta2_d_obs = sinulink_output.observer_states(:, 4);
% 
% theta1_d_model = (y1(:, 1) - circshift(y1(:, 1), 1)) / 0.001;
% theta2_d_model = (y1(:, 2) - circshift(y1(:, 2), 1)) / 0.001;
% theta1_d_model(1) = 0;
% theta2_d_model(1) = 0;
% figure;
% subplot(2, 2, 1)
% plot(t, theta1_d_model)
% xlabel("t"); ylabel("\theta_1 dot")
% title("model")
% 
% subplot(2, 2, 2)
% plot(t, theta2_d_model)
% xlabel("t"); ylabel("\theta_2 dot")
% title("model")
% 
% subplot(2, 2, 3)
% plot(t, theta1_d_obs)
% xlabel("t"); ylabel("\theta_1 dot")
% title("observer")
% 
% subplot(2, 2, 4)
% plot(t, theta2_d_obs)
% xlabel("t"); ylabel("\theta_2 dot")
% title("observer")


%% MSE compare

% MSE for observer
% sum((y1(:, 1)' - pi - y2(:, 1)').^2) / length(y1(:, 1)')
% 
% sum((y1(:, 2)' - y2(:, 2)').^2) / length(y1(:, 2)')



% %% test on setup
% 
% hwinit
% 
% 
% % test input
% u = 0.1*sin(2*pi*f*t); 
% 
% 
% simulink_input = timeseries(u,t);
% 
% sinulink_output = sim('step5_setup_obsservor_test1.mdl');
% 
% y3 = sinulink_output.oberver_setup_output;
% y4 = sinulink_output.observer_output;
% y5 = sinulink_output.observer_states(:, 2);
% y6 = sinulink_output.observer_states(:, 4);
% 
% xbeam_dot = (circshift(y3(:, 1), 1) - y3(:, 1)) / 0.001;
% xpend_dot = (circshift(y3(:, 2), 1) - y3(:, 2)) / 0.001;
% xbeam_dot(1) = 0;
% xpend_dot(1) = 0;
% figure;
% subplot(2, 2, 1)
% plot(t, y3(:, 1)' - pi)
% xlabel("t"); ylabel("\theta_1")
% title("setup")
% 
% subplot(2, 2, 2)
% plot(t, y3(:, 2)')
% xlabel("t"); ylabel("\theta_2")
% title("setup")
% 
% subplot(2, 2, 3)
% plot(t, y4(:, 1)')
% xlabel("t"); ylabel("\theta_1")
% title("observer")
% 
% subplot(2, 2, 4)
% plot(t, y4(:, 2)')
% xlabel("t"); ylabel("\theta_2")
% title("observer")
% 
% figure;
% subplot(2, 2, 1)
% plot(t, y5)
% xlabel("t"); ylabel("\theta_1 dot")
% title("setup")
% 
% subplot(2, 2, 2)
% plot(t, y6)
% xlabel("t"); ylabel("\theta_2 dot")
% title("setup")
% 
% subplot(2, 2, 3)
% plot(t, xbeam_dot)
% xlabel("t"); ylabel("\theta_1 dot")
% title("observer")
% 
% subplot(2, 2, 4)
% plot(t, xpend_dot)
% xlabel("t"); ylabel("\theta_2 dot")
% title("observer")
% 
% 
% %% MSE compare
% 
% % MSE for observer
% sum((y3(:, 1)' - pi - y4(:, 1)').^2) / length(y3(:, 1)')
% 
% sum((y3(:, 2)' - y4(:, 2)').^2) / length(y3(:, 2)')
% 
% sum((y5 - xbeam_dot).^2) / length(y3(:, 1)')
% 
% sum((y6 - xpend_dot).^2) / length(y3(:, 2)')
