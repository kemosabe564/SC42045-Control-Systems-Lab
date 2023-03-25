clear,clc
close all
% in this file, we will first use the equations from the assignment to
% symbollically linearize the system. We will then linearize around an
% operating point.

%% symbolic values:
syms theta_1 theta_2 theta_d_1 theta_d_2 u T_d T

%% parameters:
% given correct parameters:
g = 9.81;
l_1 = 0.1;
l_2 = 0.1;
m_1 = 0.125;
m_2 = 0.05;

% white-box parameters:
% %params = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];    %given wrong: 
% params_init = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 10.27570530021582, 2.78577414601457e-05, 65.9998023466922, 0.01300000000002200];

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

% T = k_m_0 * u - tau_e_0 * T_d;

% symbolic states
theta_d_vec = [theta_d_1; theta_d_2]; 
T_vec = [T; 0];

% assignment matrices
M = [P1 + P2 + 2 * P3 * cos(theta_2) P2 + P3 * cos(theta_2);
    P2 + P3 * cos(theta_2)            P2];

C = [b_1_0 - P3 * theta_d_2 * sin(theta_2)  -P3 * (theta_d_1 + theta_d_2) * sin(theta_2);
    P3 * theta_d_1 * sin(theta_2)           b_2_0];

G = [-g1 * sin(theta_1) - g2 * sin(theta_1 + theta_2);
     -g2 * sin(theta_1 + theta_2)];

%% rewrite to theta_dd = f(x,u)
M_inv = inv(M);
theta_dd = M_inv * T_vec - M_inv * C * theta_d_vec - M_inv * G;  %#ok<MINV> 

disp(theta_dd)

% make matlab function for use in NON LINEAR simulink model! (cool idea,
% but simulink is stupid, so it does not work.)
% NonLinFunc = matlabFunction(theta_dd);

%% Take derivative for A matrix
%see notebook for comments.

col1 = diff(theta_dd, 'theta_1');
col2 = diff(theta_dd, 'theta_d_1');
col3 = diff(theta_dd, 'theta_2');
col4 = diff(theta_dd, 'theta_d_2');
col5 = diff(theta_dd, 'T');


A_2 = [col1(1), col2(1), col3(1), col4(1), col5(1)];
A_4 = [col1(2), col2(2), col3(2), col4(2), col5(2)];

A = [0 1 0 0 0;
     A_2;
     0 0 0 1 0;
     A_4;
     0 0 0 0 -1/tau_e_0]; 

B_2 = diff(theta_dd(1), 'u');
B_4 = diff(theta_dd(2), 'u');

B = [0;
     B_2;
     0;
     B_4;
     k_m_0/tau_e_0]; % from T = k_m_0 * u - tau_e_0 * T_d;

% we now have the symbolic linearized matrices!

%% Linearize around operating point

% operating point
theta_1_0 = pi;
theta_2_0 = 0; % works for 0 or pi, why not for 0.1???
x_op = [theta_1_0; 0; theta_2_0; 0; 0];

% substitute the operating in the linearized sybmolic matrix
A = subs(A, [theta_1 theta_d_1 theta_2 theta_d_2 T], x_op');
B = subs(B, [theta_1 theta_d_1 theta_2 theta_d_2 T], x_op');

% to prevent enormous fractions:
A = double(A);
B = double(B);

disp(A)

disp(B)

C = [1 0 0 0 0;
     0 0 1 0 0;]; % because we want to see theta_1 and theta_2

D = zeros(2,1);

%% we save these to a file.

save('step4_linearized_system.mat','A','B','C','D','x_op','params')
% this can be used in other files easily, with all the right values.

rank(ctrb(A, B))

rank(obsv(A, C))

% both rand are 5, it's controllable and observable


%% compare the performance of linearized model

params = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 10.27570530021582, 2.78577414601457e-05, 65.9998023466922, 0.01300000000002200];

RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 1;

u = 0.1*sin(2*pi*f*t); % test input!

% u = [u; zeros(1, length(t))];

simulink_input = timeseries(u,t); 

sinulink_output = sim('step4_1_compare_lin_non_lin.slx');

%% plot the result
t_in = sinulink_output.tout;
y1 = sinulink_output.yout{1}.Values.Data;
y2 = sinulink_output.yout{2}.Values.Data;
y3 = sinulink_output.yout{3}.Values.Data(1,1,:);
y4 = sinulink_output.yout{4}.Values.Data(1,1,:);
y5 = sinulink_output.yout{5}.Values.Data;
y6 = sinulink_output.yout{6}.Values.Data;

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