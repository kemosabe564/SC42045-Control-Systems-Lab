% clear,clc
close all
%% load the linear system

linearize_operating_point

load('System.mat')

%% set initial conditions

theta_1_0 = x_op(1);
theta_d_1_0 = x_op(2);
theta_2_0 = x_op(3);
theta_d_2_0 = x_op(4);
T_0 = x_op(5);

%% run the simulink

RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 2;

u = 0.2*sin(2*pi*f*t); % test input!

% u = [u; zeros(1, length(t))];

simulink_input = timeseries(u,t); 

sinulink_output = sim('compare_lin_non_lin.slx');

%% plot the result
t_in = sinulink_output.tout;
y1 = sinulink_output.yout{1}.Values.Data;
y2 = sinulink_output.yout{2}.Values.Data;
y3 = sinulink_output.yout{3}.Values.Data(1,1,:);
y4 = sinulink_output.yout{4}.Values.Data(1,1,:);

y3 = y3(1,:)';
y4 = y4(1,:)';
figure;

subplot(2,2,1)
plot(t_in, y1)
xlabel("t"); ylabel("\theta_1")
title("nonlinear-model")

subplot(2,2,2)
plot(t_in, y2)
xlabel("t"); ylabel("\theta_2")
title("nonlinear-model")

subplot(2,2,3)
plot(t_in, y3+pi)
xlabel("t"); ylabel("\theta_1")
title("linear-model")

subplot(2,2,4)
plot(t_in, y4)
xlabel("t"); ylabel("\theta_2")
title("linear-model")

sum(y1 - y3 - pi).^2 / length(y1)

sum(y2 - y4).^2 / length(y1)