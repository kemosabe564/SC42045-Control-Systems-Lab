clc
close all

hwinit

test = 1;
RunTime = 10;
time_step = 0.001;
t = 0 : 0.001 : 10-0.001;
f = 1;
u = 0.5*sin(2*pi*f*t); 

L = 10000;

Period = 5000;
NumPeriod = L / Period;
Range_sin = [-0.5 0.5];
Band = [0.0005 0.003];

[u, freq] = idinput([Period 1 NumPeriod], 'sine', Band, Range_sin, 5);

figure(1)
plot(t', u)
xlabel("t");
ylabel("value");
title("input signal")
simulink_input = timeseries(u, t);

% logging data
if test == 1    
    sinulink_output = sim('rotpentemplate_whitebox.slx');
end 

theta_1 = theta1{1}.Values.Data;
theta_2 = theta2{1}.Values.Data;

theta_1 = detrend(theta_1);
theta_2 = detrend(theta_2);

figure(2)
subplot(1, 2, 1)
plot(t', theta_1)

subplot(1, 2, 2)
plot(t', theta_2)



U = [0 0];
init_theta_1 = pi; init_theta_2 = 0;

y = [theta_1 theta_2];

simulink_input = timeseries(-u, t);


params_init = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00002, 50, 0.03];
% params_init = [-0.0400000000000000	0.0870000574985959	0.0740000000000000	6.80902785103868e-05	4.80000000000000	9.99997774924231e-05	50	0.0300000000000000];
% params_init = [-0.04, 0.077, 0.074, 0.00006, 4.8, 0.00006, 50, 0.03];

% params_lb = [-0.5, 0.06, -0.5, 0.00002, 0, 0.0002, 0, 0];
% params_ub = [ 0.5, 0.06,  0.5, 0.00002, 6, 0.0002, 55, 0.05];
params_lb = [-0.05, 0.05, 0.06, 0.000005, 2, 0.000005, 10, 0.005];
params_ub = [-0.03, 0.07, 0.08, 0.00005, 30, 0.00005, 50, 0.05];

OPT = optimset('MaxIter', 25); % options
f = @(x)costfun(x, y, t, U); % anonymous function for passing extra input arguments to the costfunction
[params_hat, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization
% [params_init params_hat], fval % true and final estimated parameter, final cost

% good for the beam
% -0.0300000411438343	0.0608809269863771	0.0600002933629279	4.19557047350708e-05	7.59863698200564	5.02530622708186e-06	49.9999982573319	0.00500068334824114
% -0.0300000121036330	0.0679408434466040	0.0600000000017210	1.73885618127026e-05	8.19570530021582	7.72636191514716e-06	49.9998023466922	0.00500000000002200

function e = costfun(x, y, t, U)

assignin('base', 'params_hat', x);              % assign bhat in workspace
% x
params = x;
% params
U = [U params];
ym = sim('wb_system_model_2021', t, [], U);

ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];

ym = detrend(ym);

e = y(:, 1) - ym(:, 1);                               % residual (error)
% e = (y(:, 2) - ym(:, 2));                               % residual (error)

figure(3); stairs(t, [y(:, 1) ym(:, 1)]); 
xlabel("t"); ylabel("radian")
title("real-time comparison")
figure(4); stairs(t, [y(:, 2) ym(:, 2)]); 
xlabel("t"); ylabel("radian")
title("real-time comparison")

end