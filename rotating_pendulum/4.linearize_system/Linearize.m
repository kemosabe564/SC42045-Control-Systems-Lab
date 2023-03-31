clear
%% get non-linear model
load('../2.NonLinearSystem/NonLinFunc.mat','system_f')
load('../3.WhiteBoxEstimation/EstParameters/Beam Estimate.mat')
load('../3.WhiteBoxEstimation/EstParameters/Pendulum Estimate.mat')
% fill in with parameters:

%% linearize system
Params = [I_1,I_2,b_1,b_2,c_1,c_2,k_m,tau_e];
syms theta_1 theta_d_1 theta_2 theta_d_2 T u I_1 I_2 b_1 b_2 c_1 c_2 k_m tau_e

system_f = subs(system_f,[I_1,I_2,b_1,b_2,c_1,c_2,k_m,tau_e],Params);
states = [theta_1,theta_d_1,theta_2,theta_d_2,T];

A = jacobian(system_f,states);
B = jacobian(system_f,u);
C = [1 0 0 0 0;
     0 0 1 0 0];
D = [0;0];
%% save system

save("Jacobian.mat",'A','B','C','D','theta_1','theta_d_1','theta_2','theta_d_2','T','u');

%% compare the lineaization result
% test input!
RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 1;
u = 0.1*sin(2*pi*f*t); 
simulink_input = timeseries(u,t); 

params = Params;
g = 9.81;
l1 = 0.1;
l2 = 0.1;
m1 = 0.125;
m2 = 0.05;
params = [0 0 0 0 0 params];
c1 = params(6);
c2 = params(7);
I1 = params(8);
I2 = params(9);
b1 = params(10);
b2 = params(11);
km = params(12);
tau_e = params(13);
% syms c_1_0 c_2_0 I_1_0 I_2_0 b_1_0 b_2_0 k_m_0 tau_e_0


%% paper equations
% calculate variables for in assignment matrices
P1 = m1 * c1 * c1 + m2 * l1 * l1 + I1;
P2 = m2 * c2 * c2 + I2;
P3 = m2 * l1 * c2;

g1 = (m1 * c1 + m2 * l1) * g;
g2 = m2 * c2 * g;
% initial state
theta_1_0 = pi;
theta_2_0 = 0;
op = [theta_1_0; 0; theta_2_0; 0; 0];

% get the double datatype
A = subs(A, [theta_1 theta_d_1 theta_2 theta_d_2 T], op');
B = subs(B, [theta_1 theta_d_1 theta_2 theta_d_2 T], op');
A = double(A);
B = double(B);
C = double(C);
D = double(D);
% 
% % check the rank, both rand are 5, it's controllable and observable
% rank(ctrb(A, B))
% rank(obsv(A, C))
% 
% % simulate 
% sinulink_output = sim('step4_1_compare_lin_non_lin1');
% 
% % plot the result
% t_in = sinulink_output.tout;
% 
% theta_1_nonlin = sinulink_output.nonlin.Data(:, 1);
% theta_2_nonlin = sinulink_output.nonlin.Data(:, 2);
% theta_1_lin = sinulink_output.nonlin.Data(:, 1);
% theta_2_lin = sinulink_output.nonlin.Data(:, 2);
% 
% subplot(1, 2, 1)
% plot(t', theta_1_nonlin)
% hold on
% plot(t', theta_1_lin + 0.1)
% 
% subplot(1, 2, 2)
% plot(t', theta_2_nonlin)
% hold on
% plot(t', theta_2_lin + 0.1)


RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 1;

u = 0.1*sin(2*pi*f*t); % test input!

% u = [u; zeros(1, length(t))];

simulink_input = timeseries(u,t); 

sinulink_output = sim('step4_1_compare_lin_non_lin2.mdl');

%% plot the result
t_in = sinulink_output.tout;
y1 = sinulink_output.yout{1}.Values.Data;
y2 = sinulink_output.yout{2}.Values.Data;
y3 = sinulink_output.yout{3}.Values.Data(1,1,:);
y4 = sinulink_output.yout{4}.Values.Data(1,1,:);
y5 = sinulink_output.yout{5}.Values.Data;
y6 = sinulink_output.yout{6}.Values.Data;

% y1 = y1(1,:)';
% y2 = y2(1,:)';
y3 = y3(1,:)';
y4 = y4(1,:)';
figure;

subplot(3,2,1)
plot(t_in, y1)
xlabel("t"); ylabel("\theta_1")
title("nonlinear-model")

subplot(3,2,2)
plot(t_in, y2)
xlabel("t"); ylabel("\theta_2")
title("nonlinear-model")

subplot(3,2,3)
plot(t_in, y3+pi)
xlabel("t"); ylabel("\theta_1")
title("linear-model")

subplot(3,2,4)
plot(t_in, y4)
xlabel("t"); ylabel("\theta_2")
title("linear-model")

subplot(3,2,5)
plot(t_in, y5)
xlabel("t"); ylabel("\theta_1")
title("nonlinear-model")

subplot(3,2,6)
plot(t_in, y6)
xlabel("t"); ylabel("\theta_2")
title("nonlinear-model")


%% MSE compare

% MSE for our model
sum(y1 - y3 - pi).^2 / length(y1)

sum(y2 - y4).^2 / length(y1)

% MSE for their model (this model could be kept later)
sum(y5 - y3 - pi).^2 / length(y1)

sum(y6 - y4).^2 / length(y1)