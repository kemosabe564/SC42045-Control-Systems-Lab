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
steps = 20000;
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
% Start in pi -pi/2 (right) position
for X=1:steps 
    fugiboard('Write', h, 0, 1, [0 0.0]);
    data = fugiboard('Read', h);
    xstat(X) = data(1);
    xreltime(X) = data(2);
    xpos1(X) = data(3);
    xpos2(X) = data(4);
    xcurr(X) = data(5);
    xbeam(X) = data(6);
    xpend(X) = data(7);
    xdigin(X) = data(8);
    t = bt + (0.001 * X);
    %t = toc + 0.005;
    while (toc < t); end;
end
toc;


%% Correct output angles after calibration
offset = [1.2028, 1.1955];
gain = [1.2030, 1.2126];
[xbeam, xpend] = calib(xbeam, xpend, offset, gain);
% Unwrap data
xbeam = unwrap(xbeam);
xpend = unwrap(xpend);
% Get time to start comparing
[M,I] = max(xpend);
%% Plot experimental outputs
figure(1); 
stairs([xbeam; xpend]');
xlabel('Time/s');
ylabel('Angle/rad');
title('Outputs from the Setup');
legend({'\theta_1', '\theta_2'}); 

%% Perform white box identification on theta 2
truepars = [0.1, 0.1, 0.125, 0.05, -0.04, 0.06, 0.074, 0.00012, 4.8, 0.0002, 50, 0.03];
paramspend0 = [0.1, 0.05, 0.06, 0.0001, 0.00002];
%               l2   m2     c2     I2     b2                                             
paramspend0_size = length(paramspend0);

% Define zero input
T = 20;    % length of experiment
h = 0.001;   % sampling interval of 1 ms to match experimental sampling time
time_vector = [h:h:T]';
step_vector = zeros(size(time_vector)); % Initialize with zeros
input = step_vector;

% scale parameters for analysis
normalized_paramspend0 = paramspend0./paramspend0;

% Intital paramater variables for true model
l1 = truepars(1);  l2 = truepars(2);
m1 = truepars(3);  m2 = truepars(4);
c1 = truepars(5);  c2 = truepars(6);
I1 = truepars(7);  I2 = truepars(8);
b1 = truepars(9);  b2 = truepars(10);
km = truepars(11); tau_e = truepars(12);

% Assign initital conditions
th1_0 = xbeam(1);
th2_0 = xpend(1);

% use lsqnonlin to converge towards true parameters
options = optimset('MaxIter', 25);
cost_fun_with_custom_input = @(x)costfun_dbl_pend_final_pend(x, [time_vector input], xbeam, xpend, I);
params = lsqnonlin(cost_fun_with_custom_input, normalized_paramspend0, [0 0.8 0 0 0], [2 1.2 2 2 2], options);

% Rescale obtained parameters
params = params.*paramspend0;


% Display and reassign obtained parameters
fprintf('initial c2 : %f, final c2 : %f, initial I2 : %f, final I2 : %f, initial b2 : %f, final b2 : %f \n', [truepars(6) params(3) truepars(8) params(4) truepars(10) params(5)])
fprintf('initial l2 : %f, final l2 : %f, initial m2 : %f, final m2 : %f \n', [truepars(2) params(1) truepars(4) params(2)])
truepars(6) = params(3); 
truepars(10) = params(5);
truepars(8) = params(4);
truepars(2) =  params(1);
truepars(4) = params(2);
