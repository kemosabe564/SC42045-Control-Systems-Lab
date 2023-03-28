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
Ke = place(A_, B_, 0.5*J)';%number in front of the J is the scaling 

save('step5_observor.mat','Ke')


%% test the observer
RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 1;

% test input
u = 0.3*sin(2*pi*f*t); 


simulink_input = timeseries(u,t); 

sinulink_output = sim('step5_observor_test1.mdl');

y1 = sinulink_output.oberver_nonlinear_output;
y2 = sinulink_output.observer_output;

figure;
subplot(2, 2, 1)
plot(t, y1(:, 1)' - pi)
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
sum((y1(:, 1)' - pi - y2(:, 1)').^2) / length(y1(:, 1)')

sum((y1(:, 2)' - y2(:, 2)').^2) / length(y1(:, 2)')



%% test on setup

hwinit

sinulink_output1 = sim('step5_setup_obsservor_test1.mdl');

y3 = oberver_setup_output;
y4 = observer_output;
figure;
subplot(2, 2, 1)
plot(t, y3(:, 1)' - pi)
xlabel("t"); ylabel("\theta_1")
title("setup")

subplot(2, 2, 2)
plot(t, y3(:, 2)')
xlabel("t"); ylabel("\theta_2")
title("setup")

subplot(2, 2, 3)
plot(t, y4(:, 1)')
xlabel("t"); ylabel("\theta_1")
title("observer")

subplot(2, 2, 4)
plot(t, y4(:, 2)')
xlabel("t"); ylabel("\theta_2")
title("observer")


%% MSE compare

% MSE for observer
sum((y3(:, 1)' - pi - y4(:, 1)').^2) / length(y3(:, 1)')

sum((y3(:, 2)' - y4(:, 2)').^2) / length(y3(:, 2)')
