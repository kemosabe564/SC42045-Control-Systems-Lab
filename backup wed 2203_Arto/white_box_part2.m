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
fprintf('FPGA setup %d,  version %d', model, version);
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

%% Run exeperiment again to get values for theta1 
ramp = @(t) t + 0.2;

% Define input
T = 10;
h = 0.001;
time_vector = [h:h:T]';

step_vector = ramp(time_vector); 
step_vector(step_vector>ramp(3)) = 0;

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
figure(3); hold on; stairs(tm, xbeam); stairs(tm, xpend);
title('Experimental output angles'); ylabel('Angles [rad]'); legend({'\theta_1', '\theta_2'}); xlabel('time [s]')

%% Perform white box identification on theta 1
% set the initial values and the true parameters
paramsbeam0 =         [-0.04,  0.074,   4,   50,    0.01];
%                       c1      I1     b1      km     tau_e                                              
paramsbeam0_size = length(paramsbeam0);

% scale parameters for analysis
normalized_paramsbeam0 = paramsbeam0./paramsbeam0;

% Intital paramater variables for true model
l1 = truepars(1); l2 = truepars(2);
m1 = truepars(3); m2 = truepars(4);
c1 = paramsbeam0(1); c2 = truepars(6);
I1 = paramsbeam0(2); I2 = truepars(8);
b1 = paramsbeam0(3); b2 = truepars(10);
km = paramsbeam0(4); tau_e = paramsbeam0(5);

% Assign initital conditions
th1_0 = xbeam(1);
th2_0 = xpend(1);

% % Get initital non-zero point
% cross=find(xbeam > th1_0 + 0.1);
% init_point = cross(1);
init_point = 1;

input = -input;

% use lsqnonlin to converge towards true parameters
options = optimset('MaxIter', 25);
cost_fun_with_custom_input = @(x)costfun_dbl_pend_final_beam(x, [time_vector input], xbeam, xpend, init_point);
params = lsqnonlin(cost_fun_with_custom_input, normalized_paramsbeam0, [0.8 0.8 0.2 0.8 0.5], [1.2 1.2 5 1.2 1.5], options);

% Rescale obtained parameters
params = params.*paramsbeam0;

fprintf('initial km : %f, final km : %f, initital b1 : %f, final b1 : %f\n', [truepars(11) params(4) truepars(9) params(3)])
fprintf('initial c1 : %f, final c1 : %f, initital I1 : %f, final I1 : %f, initital tau : %f, final tau : %f\n', [truepars(5) params(1) truepars(7) params(2) truepars(12) params(5)])


truepars(5) = params(1);
truepars(7) = params(2);
truepars(11) = params(4);
truepars(9) = params(3);
truepars(12) = params(5);



%% Show results and plot output curves
l1 = truepars(1);  l2 = truepars(2);
m1 = truepars(3);  m2 = truepars(4);
c1 = truepars(5);  c2 = truepars(6);
I1 = truepars(7);  I2 = truepars(8);
b1 = truepars(9);  b2 = truepars(10);
km = truepars(11); tau_e = truepars(12);

tm = sim('dbl_pendulum_model_beam.slx', time_vector, [], [time_vector input]);

sz = size(theta1m);
theta1m = reshape(theta1m, [sz(3), 1]);
theta2m = reshape(theta2m, [sz(3), 1]);


figure(5);
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

annotc1 = sprintf('old c1 : %f, new c1 : %f', [-0.04 c1]);
annotc2 = sprintf('old c2 : %f, new c2 : %f', [0.06 c2]);
annotb1 = sprintf('old b1 : %f, new b1 : %f', [4.8 b1]);
annotb2 = sprintf('old b2 : %f, new b2 : %f', [0.0002 b2]);
annotI1 = sprintf('old I1 : %f, new I1 : %f', [0.074 I1]);
annotI2 = sprintf('old I2 : %f, new I2 : %f', [0.00012 I2]);
annotkm = sprintf('old km : %f, new km : %f', [50 km]);
annottaue = sprintf('old \tau_e : %f, new \tau_e : %f', [0.03 tau_e]);
annotation('textbox', [0.75, 0.7, 0.1, 0.1], 'String', annotc1)
annotation('textbox', [0.75, 0.6, 0.1, 0.1], 'String', annotc2)
annotation('textbox', [0.75, 0.5, 0.1, 0.1], 'String', annotI1)
annotation('textbox', [0.75, 0.4, 0.1, 0.1], 'String', annotI2)
annotation('textbox', [0.75, 0.3, 0.1, 0.1], 'String', annotb1)
annotation('textbox', [0.75, 0.2, 0.1, 0.1], 'String', annotb2)
annotation('textbox', [0.75, 0.1, 0.1, 0.1], 'String', annotkm)
annotation('textbox', [0.75, 0, 0.1, 0.1], 'String', annottaue)

% Results: (OLD -> SEE WORKSPACE AFTER RUNNING SCRIPT)
% c1 = -0.0399
% c2 = 0.00385
% I1 = 0.073
% I2 = 0.000108
% b1 = 4.272
% b2 = 0.000151
% km = 2.121