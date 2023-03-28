% close all
% clc
% clear



% hwinit
% 
% test = 0;
% 
% RunTime = 15;
% time_step = 0.001;
% t = 0 : 0.001 : RunTime-0.001;
% f = 1;
% % logging data
% if test == 1   
%     
%     u = 0.0*sin(2*pi*f*t); 
%     
%     L = 10000;
%     
%     Period = 5000;
%     NumPeriod = L / Period;
%     Range_sin = [-0.5 0.5];
%     Band = [0.0005 0.003];
%     
%     [u, freq] = idinput([Period 1 NumPeriod], 'sine', Band, Range_sin, 5);
%     u = 0.0*sin(2*pi*f*t); 
% 
%     figure(1)
%     plot(t', u)
%     xlabel("t");
%     ylabel("value");
%     title("input signal")
%     simulink_input = timeseries(u, t);
%     sinulink_output = sim('rotpentemplate_whitebox.slx');
% end 
% t = 0 : 0.001 : RunTime-0.001;
% theta_1 = theta1{1}.Values.Data;
% theta_2 = theta2{1}.Values.Data;
% 
% theta_1 = unwrap(theta_1);
% theta_2 = unwrap(theta_2);
% 
% theta_1 = detrend(theta_1);
% theta_2 = detrend(theta_2);
% 
% figure(2)
% subplot(1, 2, 1)
% plot(t', theta_1)
% 
% subplot(1, 2, 2)
% plot(t', theta_2)
% 
% y = [theta_1 theta_2];
% 
% t = 0 : 0.001 : 10;
% theta_2 = theta_2(2513: 2513 + 10000);
% figure(2)
% subplot(1, 2, 1)
% plot(t', theta_2)
% theta_2 = detrend(theta_2);
% subplot(1, 2, 2)
% plot(t', theta_2)
% 
% 
RunTime = 10;
time_step = 0.001;

load("white-box data\wb_pend\theta_2.mat")
t = 0 : 0.001 : 10;
f = 1;
u = 0.0*sin(2*pi*f*t); 

% intercept the right period of data




% save('theta_2.mat', 'theta_2');



init_theta_1 = pi; init_theta_2 = pi/2;

y = theta_2;

simulink_input = timeseries(-u, t);


% params_init = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 10.27570530021582, 2.78577414601457e-05, 65.9998023466922, 0.01300000000002200];
% params_lb = [9.81, 0.1, 0.1, 0.125, 0.03, -0.05, 0.03, 0.02, 0.000001, 2, 0.000001, 10, 0.005];
% params_ub = [9.81, 0.1, 0.1, 0.125, 0.06, -0.03, 0.09, 0.12, 0.00005, 30, 0.00005, 80, 0.09];
params_init = [9.81, 0.1, 0.1, 0.125, 0.05, -0.03, 0.075, 0.12, 0.00002, 30, 0.000022, 80, 0.09];
params_lb = [9.81, 0.1, 0.1, 0.125, 0.04, -0.03, 0.03, 0.12, 0.000001, 30, 0.000001, 80, 0.09];
params_ub = [9.81, 0.1, 0.1, 0.125, 0.06, -0.03, 0.09, 0.12, 0.00005, 30, 0.00005, 80, 0.09];
params_hat = params_init;


% 
ym = sim('Copy_of_nonlinear_model1');
ym = [ym.nonlinearSim(:, 1) ym.nonlinearSim(:, 2)];

ym = ym(:, 2);
% ym = [ym.nonlinearSim(:, 1) ym.nonlinearSim(:, 2)];
% hold on
% stairs(t, [ym(:, 2)]); 


OPT = optimoptions(@lsqnonlin, 'Display', 'iter'); % options
f = @(x)costfun(x, y, t); % anonymous function for passing extra input arguments to the costfunction
[params_best, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization
% [params_best, fval]= lsqnonlin(f, params_init); % actual optimization

save('params_pend.mat', 'params_best');

%9.81000000000000	0.100000000000000	0.100000000000000	0.125000000000000	0.0427081525989623	-0.0300000000000000	0.0772672857219547	0.120000000000000	2.33251405747988e-05	30	2.33496413219481e-05	80	0.0900000000000000