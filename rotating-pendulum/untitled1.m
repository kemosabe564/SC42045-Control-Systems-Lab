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

params1 = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];
t = 0 : 0.001 : 10;
theta_init = [0 pi];


params_init = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];

params_lb = [-1.04, -1.06, -1.074, -0.90002, -14.8, -0.90077, -100, -1.03];
params_ub = [1.04, 1.06, 1.074, 0.90002, 14.8, 0.90077, 100, 1.03];

options = optimoptions(@lsqnonlin, 'Algorithm', 'trust-region-reflective');


OPT = optimset('MaxIter',25); % options
f = @(x)costfun(x, xpend, t, theta_init, params1); % anonymous function for passing extra input arguments to the costfunction
[bhat, fval]= lsqnonlin(f, params1, -1, [], options); % actual optimization

[params1 bhat], fval % true and final estimated parameter, final cost

figure(3);
params = params1;
y1 = sim('system_model_test', t, [], theta_init);

params = bhat;
y2 = sim('system_model', t, [], theta_init);
params = params1;
y3 = sim('system_model', t, [], theta_init);

plot(y2.tout, y1.yout{2}.Values.Data)
hold on
plot(y2.tout, y2.yout{2}.Values.Data)
plot(y3.tout, y3.yout{2}.Values.Data)
legend({'1','2', '3'});

function e = costfun(x, y, t, theta_init, params1)
% cost function for nonlinear parameter tuning
% x contains the candidate parameters, U is the experimental input signal
% and y is the experiemental output signal

assignin('base','params_init', x);              % assign bhat in workspace
params = x;
ym = sim('system_model', t, [], theta_init);

ym = ym.yout{2}.Values.Data;
% simulate nonlinear model using current candidate parameter
                                        % the nonlinear model is built on
                                        % top of the real system, but of
                                        % course in this case there is no
                                        % noise
params = params1;
y = sim('system_model_test', t, [], theta_init);
y = y.yout{2}.Values.Data;

e = y - ym;                               % residual (error)

% you can comment the below line to speed up
% figure(4); stairs(t,[y ym]);           % intermediate fit
%pause
end