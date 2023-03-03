load("white-box data\1\xbeam.mat")
load("white-box data\1\xpend.mat")
load("calib_data\adin_gain.mat")
load("calib_data\adin_offs.mat")

% figure(1); stairs([xpend]'); ylabel('Beam, Pendulum');

xpend = (xpend - adin_offs(2)) / adin_gain(2);
xbeam = (xbeam - adin_offs(1)) / adin_gain(1);

xpend(xpend > pi) = xpend(xpend > pi) - 2*pi;
xpend = xpend /pi * 180;
figure(1); stairs([xpend]'); ylabel('Beam, Pendulum');

params = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00007, 50, 0.03];
% params = [-0.04, 0.12, 0.074, 0.00001, 4.8, 0.00007, 50, 0.03];



tspan = [0 : 0.001: 20];
theta_0 = [pi; pi/2; 0; 0];
u = 1;
[t, theta] = ode45(@(t,theta) system_model_ode(t, theta, u, params), tspan, theta_0);

theta = theta*180/pi;
% stairs([xpend(134+1:end)]'); ylabel('Beam, Pendulum');
xpend = xpend(1630:end)';
t1 = t(1: 20001-(1630));
a = theta((1: 20001-(1630)), 2);
figure(2); plot(t1, theta((1: 20001-(1630)), 2));
hold on
plot(t1, xpend);

% % x0 = [100,-1];
% fun = @(param) ;
options = optimoptions(@lsqnonlin, 'Algorithm', 'trust-region-reflective');
params1 = lsqnonlin(@(err) fun(xpend, params), params, [], [], options);

function err = fun(xpend, params)
    tspan = [0 : 0.001: 20];
    theta_0 = [pi; pi/2; 0; 0];
    u = 1;
    [t, theta] = ode45(@(t,theta) system_model_ode(t, theta, u, params), tspan, theta_0);
    theta = theta*180/pi;
    a = theta((1: 20001-(1630)), 2);

    err = (xpend - a).^2;
end