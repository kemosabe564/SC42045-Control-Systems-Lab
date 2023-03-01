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



tspan = [0 : 0.001: 25];
theta_0 = [pi; pi/2; 0; 0];
u = 1;
[t, theta] = ode45(@system_model_ode, tspan, theta_0);

figure(2); plot(t, theta(:, 2)*180/pi);