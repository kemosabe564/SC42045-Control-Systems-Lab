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