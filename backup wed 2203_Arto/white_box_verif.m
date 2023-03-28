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
freq = [0.5, 1.6, 3];
Am = [0.7, 1.1, 2.4];
cosfun = @(t) Am(1).*(cos(freq(1).*t)) ...
            + Am(2).*(1-sin(freq(2).*t)) ...
            + Am(3).*(1-cos(freq(3).*t)) ...
            + 0.1.*t;

% Define input
T = 10;
h = 0.001;
time_vector = [h:h:T]';

step_vector = cosfun(time_vector); 

input = -step_vector/max(step_vector);

offset = [1.2028, 1.1955];
gain = [1.2030, 1.2126];

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

c2 = 0.046090; I2 = 0.000099;
b2 = 0.000027; 
l2 = 0.100000; m2 = 0.046955; 


%% Show results and plot output curves
tm = sim('dbl_pendulum_model.slx', time_vector, [], [time_vector input]);

sz = size(theta1m);
theta1m = reshape(theta1m, [sz(3), 1]);
theta2m = reshape(theta2m, [sz(3), 1]);

figure(2);
clf

subplot(1, 2, 1)
stairs(tm,xbeam, 'LineWidth',2);
hold on;
stairs(tm,theta1m, 'LineWidth',2);
title('\theta_1 Data Comparison between the Setup and Nonlinear Model')
xlabel('Time/s')
ylabel('Angle/rad')
legend({'\theta_1', '\theta_1 estimation'})

subplot(1, 2, 2)
stairs(tm,xpend, 'LineWidth',2);
hold on;
stairs(tm,theta2m,  'LineWidth',2);
title('\theta_2 Data Comparison between the Setup and Nonlinear Model')
xlabel('Time/s')
ylabel('Angle/rad')
legend({'\theta_2', '\theta_2 estimation'})

%% MSE
sum((xbeam - theta1m).^2) / length(theta1m)

sum((xpend - theta2m).^2) / length(theta2m)

% annotl1 = sprintf('old l1 : %f, new l1 : %f', [0.1 l1]);
% annotl2 = sprintf('old l2 : %f, new l2 : %f', [0.1 l2]);
% annotm1 = sprintf('old m1 : %f, new m1 : %f', [0.125 m1]);
% annotm2 = sprintf('old m2 : %f, new m2 : %f', [0.05 m2]);
% annotc1 = sprintf('old c1 : %f, new c1 : %f', [-0.04 c1]);
% annotc2 = sprintf('old c2 : %f, new c2 : %f', [0.06 c2]);
% annotb1 = sprintf('old b1 : %f, new b1 : %f', [4.8 b1]);
% annotb2 = sprintf('old b2 : %f, new b2 : %f', [0.0002 b2]);
% annotI1 = sprintf('old I1 : %f, new I1 : %f', [0.074 I1]);
% annotI2 = sprintf('old I2 : %f, new I2 : %f', [0.00012 I2]);
% annotkm = sprintf('old km : %f, new km : %f', [50 km]);
% annottaue = sprintf('old tau_e : %f, new tau_e : %f', [0.03 tau_e]);
% annotation('textbox', [0.6, 0, 0.1, 0.1], 'String', annotl1)
% annotation('textbox', [0.6, 0.15, 0.1, 0.1], 'String', annotl2)
% annotation('textbox', [0.6, 0.3, 0.1, 0.1], 'String', annotm1)
% annotation('textbox', [0.6, 0.45, 0.1, 0.1], 'String', annotm2)
% annotation('textbox', [0.6, 0.6, 0.1, 0.1], 'String', annotc1)
% annotation('textbox', [0.6, 0.75, 0.1, 0.1], 'String', annotc2)
% annotation('textbox', [0.8, 0, 0.1, 0.1], 'String', annotI1)
% annotation('textbox', [0.8, 0.15, 0.1, 0.1], 'String', annotI2)
% annotation('textbox', [0.8, 0.3, 0.1, 0.1], 'String', annotb1)
% annotation('textbox', [0.8, 0.45, 0.1, 0.1], 'String', annotb2)
% annotation('textbox', [0.8, 0.6, 0.1, 0.1], 'String', annotkm)
% annotation('textbox', [0.8, 0.68, 0.1, 0.1], 'String', annottaue)
% saveas(gcf, 'White box results.pdf')