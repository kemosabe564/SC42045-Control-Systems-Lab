clear
clc
close all

hwinit

test = 1;

load("calib_data\adin_gain.mat")
load("calib_data\adin_offs.mat")

% logging data
if test == 1   
    time_step = 0.001;

    RunTime = 5;
    t = 0 : time_step : RunTime;
    f = 1;
    u = 0.2*sin(2*pi*f*t); 
    
%     L = 10000;
%     
%     Period = 5000;
%     NumPeriod = L / Period;
%     Range_sin = [-0.1 0.1];
%     Band = [0.0005 0.003];
%     
%     [u, freq] = idinput([Period 1 NumPeriod], 'sine', Band, Range_sin, 5);
    u = 0.0*sin(2*pi*f*t) + t - t + 0.5;
    figure(1)
    plot(t', u)
    xlabel("t");
    ylabel("value");
    title("input signal")
    simulink_input = timeseries(u, t);
    sinulink_output = sim('rotpentemplate_whitebox.slx');
end 

theta_1 = theta1{1}.Values.Data;
theta_2 = theta2{1}.Values.Data;

theta_1 = unwrap(theta_1);
theta_2 = unwrap(theta_2);

theta_1 =  (theta_1 - adin_offs(1)) / adin_gain(1);
theta_2 =  (theta_2 - adin_offs(2)) / adin_gain(2);

% theta_1 = detrend(theta_1);
% theta_2 = detrend(theta_2);

figure(2)
subplot(1, 2, 1)
plot(t', theta_1)

subplot(1, 2, 2)
plot(t', theta_2)

y = [theta_1 theta_2];



U = [0 0];
init_theta_1 = theta_1(1); init_theta_2 = theta_1(2);
simulink_input = timeseries(u, t);


params_init = [9.81000000000000	0.100000000000000	0.100000000000000	0.125000000000000	0.0427081525989623	-0.0300000000000000	0.0772672857219547	0.6	2.33251405747988e-05	10	2.33496413219481e-05	40	0.0900000000000000];
% params_lb = [9.81, 0.1, 0.1, 0.125, 0.045, -0.05, 0.05, 0.02, 1.33e-05, 2,  1.33e-05, 10, 0.09];
% params_ub = [9.81, 0.1, 0.1, 0.125, 0.05, -0.02, 0.08, 0.12, 5.33e-05, 10, 5.33e-05, 80, 0.2];
% params_init = [9.81000000000000	0.100000000000000	0.100000000000000	0.125000000000000	0.0450000000000234	-0.0200000001640045	0.0697894928621977	0.0200000067218735	3.79892135721832e-05	8.99999982716079	5.32997120989256e-05	56.8704976916019	0.0900000000000730];

params_lb = [9.81, 0.1, 0.1, 0.125, 0.05, -0.05, 0.08, 0.01, 4.33e-05, 2,  4.33e-05, 30, 0.02];
params_ub = [9.81, 0.1, 0.1, 0.125, 0.05, -0.02, 0.08, 0.12, 4.33e-05, 10, 4.33e-05, 80, 0.2];
params_hat = params_init;

% ym = sim('Copy_of_nonlinear_model1.mdl');
%     
% ym = [ym.nonlinearSim(:, 1) ym.nonlinearSim(:, 2)];
% subplot(1, 2, 1)
% plot(t', ym(:, 1))
% 
% subplot(1, 2, 2)
% plot(t', ym(:, 2))

OPT = optimset('MaxIter', 25); % options
f = @(x)costfun(x, y, t); % anonymous function for passing extra input arguments to the costfunction
[params_hat, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization
% [params_init params_hat], fval % true and final estimated parameter, final cost


% function e = costfun(x, y, t, U)
%     
%     assignin('base', 'params_hat', x);              % assign bhat in workspace
%     params = x;
%     U = [U params];
%     ym = sim('whitebox_nonlinear_model_2021', t, [], U);
%     
%     ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];
%     
%     ym = detrend(ym);
%     
%     % e = y(:, 1) - ym(:, 1);                               % residual (error)
%     % e = (y(:, 2) - ym(:, 2));                               % residual (error)
%     e = y - ym;
% 
%     figure(3); stairs(t, [y(:, 1) ym(:, 1)]); 
%     xlabel("t"); ylabel("radian")
%     title("real-time comparison")
%     figure(4); stairs(t, [y(:, 2) ym(:, 2)]); 
%     xlabel("t"); ylabel("radian")
%     title("real-time comparison")
% 
% end


