clear;
close all;

% params

tspan = [0 : 0.01: 50];
theta_0 = [pi; -pi/2; 0; 0];
u = 1;
[t, theta] = ode45(@system_model_ode, tspan, theta_0);

plot(t, theta(:, 2)*180/pi);
% ylim([-360, 360])