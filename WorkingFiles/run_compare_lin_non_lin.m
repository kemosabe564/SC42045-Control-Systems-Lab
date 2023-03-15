clear,clc
%% load the linear system
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
t = 0:0.05:10;

u = 0.01*sin(2*pi*t); % test input!

simulink_input = timeseries(u,t); 

%sim('compare_lin_non_lin.slx')