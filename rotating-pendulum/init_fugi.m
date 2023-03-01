% fugiboard('CloseAll');
% h=fugiboard('Open', 'Pendulum1');
% h.WatchdogTimeout = 0.5;
% fugiboard('SetParams', h);

% initialize FPGA
close all;
clear x*;
clear;
fugiboard('CloseAll');
h=fugiboard('Open', 'pendulum1');
h.WatchdogTimeout = 1;
fugiboard('SetParams', h);
fugiboard('Write', h, 0, 0, [0 0]);  % dummy write to sync interface board
fugiboard('Write', h, 4+1, 1, [0 0]);  % get version, reset position, activate relay
data = fugiboard('Read', h);         % get version info from FPGA
model = bitshift(data(1), -4);
version = bitand(data(1), 15);
disp(sprintf('FPGA setup %d,  version %d', model, version));
fugiboard('Write', h, 0, 1, [0 0]);  % end reset

pause(0.1); % give relay some time to act
