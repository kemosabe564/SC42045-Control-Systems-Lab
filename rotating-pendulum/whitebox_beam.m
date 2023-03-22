clc
clear
close all

load("calib_data\wb_adin_gain.mat")
load("calib_data\wb_adin_offs.mat")

load("white-box data\wb_beam\xbeam.mat")
load("white-box data\wb_beam\xpend.mat")
xbeam = unwrap(xbeam);

xpend = (xpend - adin_offs(2)) / adin_gain(2);
xbeam = (xbeam - adin_offs(1)) / adin_gain(1);

t = 0 : 0.001 : 15;
% start_point = 639;
% t = t(start_point: start_point + 10000) - t(start_point);
% xpend = xpend(start_point: start_point + 10000);
t = t(1:15000);

figure(1);
plot(t, xbeam);

t = 0 : 0.001 : 15-0.001;
U = [0 1];
init_theta_1 = pi; init_theta_2 = pi/2;

SIMULATION = false;

if SIMULATION == true
    % generate the biased one
    y = sim('wb_system_model_biased_2021', t, [], U);
    y = [y.yout{1}.Values.Data y.yout{2}.Values.Data];
else
    y = xbeam';
end

params_init = [-0.04, 0.06, 0.074, 0.00002, 10, 0.0002, 50, 0.03];
% params_init = [-0.0400000000000000	0.0870000574985959	0.0740000000000000	6.80902785103868e-05	4.80000000000000	9.99997774924231e-05	50	0.0300000000000000];

% params_lb = [-0.5, 0.06, -0.5, 0.00002, 0, 0.0002, 0, 0];
% params_ub = [ 0.5, 0.06,  0.5, 0.00002, 6, 0.0002, 55, 0.05];
params_lb = [-0.1, 0.06, 0.001, 0.00002, 4.8, 0.0002, 10, 0.005];
params_ub = [-0.001, 0.06, 0.2, 0.00002 , 40, 0.0002 , 55, 0.05];

OPT = optimset('MaxIter', 25); % options
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
plot(y2.tout, y2.yout{1}.Values.Data)
plot(y3.tout, y3.yout{1}.Values.Data)
xlabel("t"); ylabel("radian")
title("whitebox estimation comparison")
legend({'real measurement', 'expected value with param hat', 'expected value with init param'});

% P = [-0.00100003933833602	0.0600000000000000	0.199999999999978	2.00000000000000e-05	20.6480157903686	0.000200000000000000	15.0001033572793	0.0300000000000000];




function e = costfun(x, y, t, U)

assignin('base', 'params_hat', x);              % assign bhat in workspace
% x
params = x;
% params
U = [U params];
ym = sim('wb_system_model_2021', t, [], U);

ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];

e = (y - ym(:, 1));                               % residual (error)
% e = (y(:, 2) - ym(:, 2));                               % residual (error)
% e = y - ym;


% sum(e)
% figure(2); stairs(t, [y(:, 2) ym(:, 2)]); 
figure(2); stairs(t, [y ym(:, 1)]); 
xlabel("t"); ylabel("radian")
title("real-time comparison")

end