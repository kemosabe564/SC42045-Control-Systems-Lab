clear
close all
% in this file, we will first use the equations from the assignment to
% symbollically linearize the system. We will then linearize around an
% operating point.

%% symbolic values:
syms theta_1 theta_2 theta_d_1 theta_d_2 u T_d T

%% parameters:
% given correct parameters:


% white-box parameters:
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
% syms c_1_0 c_2_0 I_1_0 I_2_0 b_1_0 b_2_0 k_m_0 tau_e_0


%% paper equations
% calculate variables for in assignment matrices
P1 = m1 * c1 * c1 + m2 * l1 * l1 + I1;
P2 = m2 * c2 * c2 + I2;
P3 = m2 * l1 * c2;

g1 = (m1 * c1 + m2 * l1) * g;
g2 = m2 * c2 * g;

% T = k_m_0 * u - tau_e_0 * T_d;

% symbolic states
theta_d_vec = [theta_d_1; theta_d_2]; 
T_vec = [T; 0];

% assignment matrices
M = [P1 + P2 + 2 * P3 * cos(theta_2) P2 + P3 * cos(theta_2);
    P2 + P3 * cos(theta_2)            P2];

C = [b1 - P3 * theta_d_2 * sin(theta_2)  -P3 * (theta_d_1 + theta_d_2) * sin(theta_2);
    P3 * theta_d_1 * sin(theta_2)           b2];

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
     0 0 0 0 -1/tau_e]; 

B_2 = diff(theta_dd(1), 'u');
B_4 = diff(theta_dd(2), 'u');

B = [0;
     B_2;
     0;
     B_4;
     km/tau_e]; % from T = k_m_0 * u - tau_e_0 * T_d;

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
% this can be used in other files easily, with all the right values.

rank(ctrb(A, B))

rank(obsv(A, C))

% both rand are 5, it's controllable and observable


%% compare the performance of linearized model


RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10;
f = 5;

u = 0.9*sin(2*pi*f*t); % test input!

% u = [u; zeros(1, length(t))];

simulink_input = timeseries(u,t); 

sinulink_output = sim('step4_1_compare_lin_non_lin1.mdl');

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

subplot(1,2,1)
plot(t_in, y3 + 0.03)
hold on
plot(t_in, y5-pi)
xlabel("Time [s]"); ylabel("Angle [rad]")
title('\theta_1 Comparison', 'FontSize', 10)
legend({'Linear', 'Nonlinear'})

subplot(1,2,2)
plot(t_in, y4)
hold on
plot(t_in, y6)
xlabel("Time [s]"); ylabel("Angle [rad]")
title('\theta_2 Comparison', 'FontSize', 10)
legend({'Linear', 'Nonlinear'})


%% NMSE compare

immse(y1, y3 + pi) / std(y3+pi)

immse(y2, y4) / std(y4)
