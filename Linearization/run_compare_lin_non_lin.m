clear,clc
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
f = 1;

u = 0.01*sin(2*pi*f*t); % test input!

% u = [u; zeros(1, length(t))];

simulink_input = timeseries(u,t); 

sinulink_output = sim('compare_lin_non_lin.slx');

%% plot the result
t_in = sinulink_output.tout;
y1 = sinulink_output.yout{1}.Values.Data;

figure;

plot(t_in, y1)

