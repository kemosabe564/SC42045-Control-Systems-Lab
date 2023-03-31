%make plots
close all

figure();
plot(theta_1_measurement.Time,theta_1_measurement.Data);
hold on
plot(theta_2_measurement1.Time,theta_2_measurement1.Data);
title('Pole Placement Control in the up-up configuration');
xlabel('Time [s]');
ylabel('Angle [rad]');
legend('\theta_1','\theta_2');