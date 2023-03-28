% initialize FPGA
fugihandle = fugiboard('Open', 'Pendulum1');

fugihandle.WatchdogTimeout = 0.5;
fugiboard('SetParams', fugihandle);
fugiboard('Write', fugihandle, 0, 0, 0, 0);  % dummy write to sync interface board
fugiboard('Write', fugihandle, 5, 1, 0, 0);  % reset position, activate relay
data = fugiboard('Read', fugihandle);        % get version info from FPGA
model = bitshift(data(1), -5); 
version = bitand(data(1), 31);
disp(sprintf('FPGA setup %d, version %d', model, version)); % for the B&P it should say 1 1, or else there is a problem
fugiboard('Write', fugihandle, 0, 1, 0, 0);  % end reset
pause(0.1);                         % give relay some time to respond

num_steps = 240;
han = fugihandle;
%calibration(240, han)
% Initialize the two sensor arrays
sensor1_vals = zeros(2, 1);
sensor2_vals = zeros(2, 1);

% Get the first measurement (second pendulum at pi radians)
fprintf('Please position the double pendulum with the first arm at 0 radians and second arm at rest (pi radians) and confirm.\n');
input('Press enter when ready.');
[xb1, xp1] = measure_angles(num_steps, han);
    
sensor1_vals(1) = mean(xb1);
sensor2_vals(1) = mean(xp1);

% Get the second measurement (both pendulums at rest)
fprintf('Please position the double pendulum with both arms at rest and confirm.\n');
input('Press enter when ready.');

[xb2, xp2] = measure_angles(num_steps, han);
    

sensor1_vals(2) = mean(xb2);
sensor2_vals(2) = mean(xp2);

% Calculate the calibration values for each sensor
slope = [pi / diff(sensor1_vals), -pi / diff(sensor2_vals)];
offset = [sensor1_vals(1), sensor2_vals(2)];
% figure(1); stairs([xb1; xp1]'); title('Uncalibrated angles');ylabel('Beam, Pendulum'); legend({'Beam', 'Pendulum'})
% figure(2); stairs([xb2; xp2]'); title('Uncalibrated angles');ylabel('Beam, Pendulum'); legend({'Beam', 'Pendulum'})
% figure(3); stairs([xb1 - offset(1); xp2 - offset(2)]');title('Calibrated angles'); ylabel('Beam, Pendulum'); legend({'Beam', 'Pendulum'})
% figure(4); stairs([(xb2 - offset(1))*slope(1);(xp1 - offset(2))*slope(2)]');title('Calibrated angles'); ylabel('Beam, Pendulum'); legend({'Beam', 'Pendulum'})
axis equal
% Print the calibration values to the console
fprintf('Calibration complete.\n');
fprintf('Sensor 1: slope = %f, offset = %f\n', slope(1), offset(1));
fprintf('Sensor 2: slope = %f, offset = %f\n', slope(2), offset(2));
