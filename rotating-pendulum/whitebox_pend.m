clc
close all

% hwinit
% 
% test = 1;
% RunTime = 15;
% time_step = 0.001;
% t = 0 : 0.001 : 15-0.001;
% f = 1;
% u = 0.0*sin(2*pi*f*t); 
% 
% 
% figure(1)
% plot(t', u)
% xlabel("t");
% ylabel("value");
% title("input signal")
% simulink_input = timeseries(u, t);
% 
% % logging data
% if test == 1    
%     sinulink_output = sim('rotpentemplate_whitebox.slx');
% end 


load("white-box data\wb_pend\theta_2.mat")

% theta_1 = theta1{1}.Values.Data;
% theta_2 = theta2{1}.Values.Data;

% theta_1 = detrend(theta_1);
% theta_2 = detrend(theta_2);
% 
t = 0 : 0.001 : 10;
f = 1;
u = 0.0*sin(2*pi*f*t); 

theta_2 = theta_2(2441: 2441 + 10000);
figure(2)
subplot(1, 2, 1)
plot(t', theta_2)

subplot(1, 2, 2)
plot(t', theta_2)



U = [0 0];
init_theta_1 = pi; init_theta_2 = -pi/2;

y = [theta_2];

simulink_input = timeseries(-u, t);


params_init = [-0.04, 0.067, 0.074, 0.00002, 4.8, 0.00002, 50, 0.03];
% params_init = [-0.0400000000000000	0.0870000574985959	0.0740000000000000	6.80902785103868e-05	4.80000000000000	9.99997774924231e-05	50	0.0300000000000000];
% params_init = [-0.04, 0.077, 0.074, 0.00006, 4.8, 0.00006, 50, 0.03];

% params_lb = [-0.5, 0.06, -0.5, 0.00002, 0, 0.0002, 0, 0];
% params_ub = [ 0.5, 0.06,  0.5, 0.00002, 6, 0.0002, 55, 0.05];
params_lb = [-0.03, 0.077, 0.06, 0.000005, 8, 0.000005, 50, 0.005];
params_ub = [-0.03, 0.083, 0.06, 0.00005, 8, 0.00005, 50, 0.005];

OPT = optimset('MaxIter', 25); % options
f = @(x)costfun(x, y, t, U); % anonymous function for passing extra input arguments to the costfunction
[params_hat, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization
% [params_init params_hat], fval % true and final estimated parameter, final cost

% good for the beam
% -0.0300000121036330	0.0679408434466040	0.0600000000017210	1.73885618127026e-05	8.19570530021582	7.72636191514716e-06	49.9998023466922	0.00500000000002200
% -0.0300000000000000	0.0803451968350115	0.0600000000000000	2.90882387117299e-05	8	4.78577414601457e-05	50	0.00500000000000000
function e = costfun(x, y, t, U)

assignin('base', 'params_hat', x);              % assign bhat in workspace
% x
params = x;
% params
U = [U params];
ym = sim('wb_system_model_2021', t, [], U);

ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];

ym = detrend(ym);

e = y - ym(:, 2);                               % residual (error)

figure(4); stairs(t, [y ym(:, 2)]); 
xlabel("t"); ylabel("radian")
title("real-time comparison")

end