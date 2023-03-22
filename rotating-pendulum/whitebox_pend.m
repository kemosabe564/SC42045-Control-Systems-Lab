clc
clear
close all

load("white-box data\wb_pend\xbeam.mat")
load("white-box data\wb_pend\xpend.mat")
load("calib_data\wb_adin_gain.mat")
load("calib_data\wb_adin_offs.mat")

xpend = (xpend - adin_offs(2)) / adin_gain(2);
xbeam = (xbeam - adin_offs(1)) / adin_gain(1);

t = 0 : 0.001 : 15;
xpend = unwrap(xpend);
start_point = 639;
t = t(start_point: start_point + 10000) - t(start_point);
xpend = xpend(start_point: start_point + 10000);


figure(1);
plot(t, xpend);

t = 0 : 0.001 : 10;
U = [0 0];
init_theta_1 = pi; init_theta_2 = pi/2;

SIMULATION = false;

if SIMULATION == true
    % generate the biased one
    y = sim('wb_system_model_biased_2021', t, [], U);
    y = [y.yout{1}.Values.Data y.yout{2}.Values.Data];
else
    y = xpend';
end

params_init = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.0002, 50, 0.03];
params_init = [-0.0400000000000000	0.0870000574985959	0.0740000000000000	6.80902785103868e-05	4.80000000000000	9.99997774924231e-05	50	0.0300000000000000];
% params_init = [-0.04, 0.077, 0.074, 0.00006, 4.8, 0.00006, 50, 0.03];

% params_lb = [-0.5, 0.06, -0.5, 0.00002, 0, 0.0002, 0, 0];
% params_ub = [ 0.5, 0.06,  0.5, 0.00002, 6, 0.0002, 55, 0.05];
params_lb = [-0.04, 0.075, 0.074, 0.000025, 4.8, 0.000035, 50, 0.03];
params_ub = [-0.04, 0.079, 0.074, 0.000045, 4.8, 0.000045, 50, 0.03];

OPT = optimset('MaxIter', 50); % options
f = @(x)costfun(x, y, t, U); % anonymous function for passing extra input arguments to the costfunction
[params_hat, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization
% [params_init params_hat], fval % true and final estimated parameter, final cost

figure(1);
% params = params_init;
% y1 = sim('system_model_biased', t, [], U);
a = y';
params = params_hat;
U1 = [U params];
y2 = sim('wb_system_model_2021', t, [], U1);
params = params_init;
U1 = [U params];
y3 = sim('wb_system_model_2021', t, [], U1);

plot(t, a)
hold on
plot(y2.tout, y2.yout{2}.Values.Data)
% plot(y3.tout, y3.yout{2}.Values.Data)
xlabel("t"); ylabel("radian")
title("whitebox estimation comparison")
legend({'real measurement', 'expected value with param hat', 'expected value with init param'});

% params_hat = [-0.04, 0.077, 0.074, 0.00004, 4.8, 0.00004, 50, 0.03];


function e = costfun(x, y, t, U)

assignin('base', 'params_hat', x);              % assign bhat in workspace
% x
params = x;
% params
U = [U params];
ym = sim('wb_system_model_2021', t, [], U);

ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];

e = (y - ym(:, 2));                               % residual (error)
% e = (y(:, 2) - ym(:, 2));                               % residual (error)

% sum(e)
% figure(2); stairs(t, [y(:, 2) ym(:, 2)]); 
figure(2); stairs(t, [y ym(:, 2)]); 
xlabel("t"); ylabel("radian")
title("real-time comparison")

end