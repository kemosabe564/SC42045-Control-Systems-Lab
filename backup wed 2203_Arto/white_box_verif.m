%% Call pendulum and define pendulum handle
clear x*;
fugiboard('CloseAll');
h=fugiboard('Open', 'pendulum1');
h.WatchdogTimeout = 1;
fugiboard('SetParams', h);
fugiboard('Write', h, 0, 0, [0 0]);  % dummy write to sync interface board
fugiboard('Write', h, 4+1, 1, [0 0]);  % get version, reset position, activate relay
data = fugiboard('Read', h);
model = bitshift(data(1), -4);
version = bitand(data(1), 15);
disp(sprintf('FPGA setup %d,  version %d', model, version));
fugiboard('Write', h, 0, 1, [0 0]);  % end reset


%% Inititalize output data arrays
pause(0.1); % give relay some time to act
steps = 10000;
xstat = zeros(1,steps);
xreltime = zeros(1,steps);
xpos1 = zeros(1,steps);
xpos2 = zeros(1,steps);
xcurr = zeros(1,steps);
xbeam = zeros(1,steps);
xpend = zeros(1,steps);
xdigin = zeros(1,steps);
tic;
bt = toc;

%% Run exeperiment to get experimental output
omegak = [0.5, 2, 3];
Ak = [0.7, 1.1, 1.6];
cosfun = @(t) Ak(1).*(1-cos(omegak(1).*t)) ...
    + Ak(2).*(1-cos(omegak(2).*t)) ...
    + Ak(3).*(1-cos(omegak(3).*t)) ...
    + 0.1.*t;

% Define input
T = 10;
h = 0.001;
time_vector = [h:h:T]';

step_vector = cosfun(time_vector); 

input = -step_vector/max(step_vector);

offset = [1.185896,1.195229];
slope = [1.208265,1.209528];

tm = sim('white_box_beam.slx', time_vector, [], [time_vector input]);

xbeam = Theta1;
xpend = Theta2;
%% Correct output angles after calibration
% Unwrap data
xbeam = unwrap(xbeam);
xpend = unwrap(xpend);

%% Plot experimental outputs
figure(1); stairs([xbeam; xpend]');
title('Experimental output angles'); ylabel('Angles [rad]'); legend({'\theta_1', '\theta_2'}); xlabel('time [s]')

%% Define input and initital conditions
% Assign initital conditions
th1_0 = xbeam(1);
th2_0 = xpend(1);

input = - input;

%% Show results and plot output curves
tm = sim('dbl_pendulum_model.slx', time_vector, [], [time_vector input]);

sz = size(theta1m);
theta1m = reshape(theta1m, [sz(3), 1]);
theta2m = reshape(theta2m, [sz(3), 1]);

figure(2);
clf
hold on;
stairs(tm,xbeam, 'r', 'LineWidth',2);
stairs(tm,theta1m, 'b');
stairs(tm,xpend,'c', 'LineWidth',2);
stairs(tm,theta2m, 'g');
title('Comparison of the experimental data with the simulink model using white-box parameters')
xlabel('Time [s]')
ylabel('Angle [rad]')
legend({'\theta_1', '\theta_1 (model)', '\theta_2', '\theta_2 (model)'})

annotl1 = sprintf('old l1 : %f, new l1 : %f', [0.1 l1]);
annotl2 = sprintf('old l2 : %f, new l2 : %f', [0.1 l2]);
annotm1 = sprintf('old m1 : %f, new m1 : %f', [0.125 m1]);
annotm2 = sprintf('old m2 : %f, new m2 : %f', [0.05 m2]);
annotc1 = sprintf('old c1 : %f, new c1 : %f', [-0.04 c1]);
annotc2 = sprintf('old c2 : %f, new c2 : %f', [0.06 c2]);
annotb1 = sprintf('old b1 : %f, new b1 : %f', [4.8 b1]);
annotb2 = sprintf('old b2 : %f, new b2 : %f', [0.0002 b2]);
annotI1 = sprintf('old I1 : %f, new I1 : %f', [0.074 I1]);
annotI2 = sprintf('old I2 : %f, new I2 : %f', [0.00012 I2]);
annotkm = sprintf('old km : %f, new km : %f', [50 km]);
annottaue = sprintf('old tau_e : %f, new tau_e : %f', [0.03 tau_e]);
annotation('textbox', [0.6, 0, 0.1, 0.1], 'String', annotl1)
annotation('textbox', [0.6, 0.15, 0.1, 0.1], 'String', annotl2)
annotation('textbox', [0.6, 0.3, 0.1, 0.1], 'String', annotm1)
annotation('textbox', [0.6, 0.45, 0.1, 0.1], 'String', annotm2)
annotation('textbox', [0.6, 0.6, 0.1, 0.1], 'String', annotc1)
annotation('textbox', [0.6, 0.75, 0.1, 0.1], 'String', annotc2)
annotation('textbox', [0.8, 0, 0.1, 0.1], 'String', annotI1)
annotation('textbox', [0.8, 0.15, 0.1, 0.1], 'String', annotI2)
annotation('textbox', [0.8, 0.3, 0.1, 0.1], 'String', annotb1)
annotation('textbox', [0.8, 0.45, 0.1, 0.1], 'String', annotb2)
annotation('textbox', [0.8, 0.6, 0.1, 0.1], 'String', annotkm)
annotation('textbox', [0.8, 0.68, 0.1, 0.1], 'String', annottaue)
% saveas(gcf, 'White box results.pdf')