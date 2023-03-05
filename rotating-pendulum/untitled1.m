% load("white-box data\1\xbeam.mat")
% load("white-box data\1\xpend.mat")
% load("calib_data\adin_gain.mat")
% load("calib_data\adin_offs.mat")
% 
% % figure(1); stairs([xpend]'); ylabel('Beam, Pendulum');
% 
% xpend = (xpend - adin_offs(2)) / adin_gain(2);
% xbeam = (xbeam - adin_offs(1)) / adin_gain(1);
% 
% xpend(xpend > pi) = xpend(xpend > pi) - 2*pi;
% xpend = xpend /pi * 180;
% xpend = xpend(1 : 10001);
clear
close all

% params = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];
t = 0 : 0.001 : 10;
U = [0 1];
init_theta_1 = 0; init_theta_2 = pi;


params_init = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];

params_lb = [-1, -1, -1, -1, -15, -1, -100, -1];
params_ub = -params_lb;

options = optimoptions(@lsqnonlin, 'Algorithm', 'trust-region-reflective');

% params = params_init;
y = sim('system_model_biased', t, [], U);
y = [y.yout{1}.Values.Data y.yout{2}.Values.Data];


OPT = optimset('MaxIter', 3); % options
f = @(x)costfun(x, y, t, U); % anonymous function for passing extra input arguments to the costfunction
[params_hat, fval]= lsqnonlin(f, params_init, -Inf, Inf, OPT); % actual optimization

% [params_init params_hat], fval % true and final estimated parameter, final cost

figure(3);
params = params_init;
y1 = sim('system_model_biased', t, [], U);

params = params_hat;
y2 = sim('system_model', t, [], U);
params = params_init;
y3 = sim('system_model', t, [], U);

plot(y1.tout, y1.yout{2}.Values.Data)
hold on
plot(y2.tout, y2.yout{2}.Values.Data)
plot(y3.tout, y3.yout{2}.Values.Data)
legend({'biased model', 'ideal model with init param', 'ideal model with init param hat'});

function e = costfun(x, y, t, U)

assignin('base', 'params_hat', x);              % assign bhat in workspace
x
params = x;
% params
ym = sim('system_model', t, [], U);

ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];

e = (y - ym);                               % residual (error)
% sum(e)

end