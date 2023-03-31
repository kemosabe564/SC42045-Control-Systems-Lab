% Perform black box estimation

%clear all; clc; close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% design input excitation signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T = 9.999;    % length of experiment
% si = 0.001;   % sampling interval
% ts = 10;    % estimated settling time of the process
% A = 1;      % amplitude of GBN
% U = [h*(0:T/h)' gbn(T,ts,A,h,1)]; % input signal (first colum contains
%                                   % sampling instants, second actual input signal)
% inpsig = U(:,2); 
Period = 5000;
NumPeriod = 2;
Range = [-2 2];
Band = [0.001 0.01];
[inpsig,freq] = idinput([Period 1 NumPeriod],'sine',Band,Range,20);
Ts = 0.001;
freq = freq/Ts;
%inpsig = iddata([],inpsig,Ts,'TimeUnit','seconds');
plot(inpsig)

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
    fugiboard('Write', h, 0, 1, [inpsig(X) 0.0]);
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
figure(1); stairs([xbeam; xpend]');
title('Experimental output angles'); ylabel('Angles [rad]'); legend({'\theta_1', '\theta_2'}); xlabel('time [s]')


%% Black box
ny = 2; % number of outputs
nu = 1; % number of inputs
 
yb = [xbeam' xpend'];
%ub = U(:,2);
inpsig = u;
data = iddata(yb,inpsig,Ts);

%na = 3*eye(2); % note: na must be ny-by-ny!\
na = [3 0;0 30];
%nb = 3*ones(2,1); % nb must be ny-by-nu 
nb = [2;6];
nc = 4*ones(2,1); % nc must be ny-by-1
nd = 3*ones(2,1); % nd must be ny-by-1
nf = 3*ones(2,1); % nf must be ny-by-nu
%nk = 0*ones(2,1); % nk must be ny-by-nu
nk = [0;1];

arxsys = arx(data,[na nb nk],'Ts', Ts)
% armaxsys = armax(data,[na nb nc nk], 'Ts', Ts);
% oesys = oe(data,[nb nf nk],'Ts', Ts);
% bjsys = bj(data,[nb nc nd nf nk],'Ts', Ts);

%% Plot to compare

% figure(1)
% %stem(t,y(1,:)','.')
% plot(t,y(1,:)')
% hold on
% %figure(2)
% %stem(t,y(2,:)','.')
% plot(t,y(2,:)')
% xlabel('Time')
% ylabel('Angle')
% legend('theta1','theta2')
% title('Linearized model')
% grid

figure(3)
%compare(data,arxsys,armaxsys,oesys,bjsys);
compare(data,arxsys);