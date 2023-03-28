%% Input signal for black box experiment

Ts = 0.001;
Fs = 1/Ts;
T = 10;
t = Ts*(Ts:T/Ts)';
N = length(t);
time = Ts*(Ts:T/Ts)';

f = 0.1;
%u = sin(2*pi*f*t);

Period = 5000;
NumPeriod = 2;
Range = [-2 2];
Band = [0.001 0.01];
[u,freq] = idinput([Period 1 NumPeriod],'sine',Band,Range,20);
Ts = 0.001;
freq = freq/Ts;
f = 0.75;
%testu = [zeros(1,4000) 0.25*ones(1,1000) -0.25*ones(1,1000) zeros(1,4000)];
testu = 0.5*sin(2*pi*f*time);
figure(1)
plot(time,testu)

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
% Start in pi -pi/2 (right) position
for X=1:steps 
    fugiboard('Write', h, 0, 1, [testu(X)*2 0.0]);
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
offset = [1.185896,1.195229];
slope = [1.208265,1.209528];
% Unwrap data
xbeam = unwrap(xbeam);
xpend = unwrap(xpend);
[xbeam, xpend] = calib(xbeam, xpend, offset, slope);
% Get time to start comparing
[M,I] = max(xpend);

%% Plot experimental outputs
figure(2); stairs([xbeam; xpend]');
title('Experimental output angles'); ylabel('Angles [rad]'); legend({'\theta_1', '\theta_2'}); xlabel('time [s]')

%% Calculate power of the signals
arxmod = sim(oesys,testu);
figure(3)
plot(time,arxmod(:,1),time,xbeam)
xlabel('Time (s)')
ylabel('Angle (radians)')
title('Beam')
legend('Model','Measurement')
figure(4)
plot(time,arxmod(:,2),time,xpend)
xlabel('Time (s)')
ylabel('Angle (radians)')
title('Pendulum')
legend('Model','Measurement')