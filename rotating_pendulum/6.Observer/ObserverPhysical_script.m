clear, clc
%% load the observer data

% load the system, SET THE OPERATING POINT IN THE "SimObserver.m" FILE!
% load('../simulateObserver/System_matrices.mat')
% load('../simulateObserver/ObserverMatrix.mat')
load('./System_matrices.mat')
load('./ObserverMatrix.mat')
% theta_1_Op = x_operating(1);
theta_1_Op = pi;
theta_2_Op = x_operating(3);

%% setup simulink
hwinit

load('../X.GetData/Data/Run1.mat')
time_step = 0.001;
t = 0 : time_step : length(u)*time_step-time_step;
simulink_input = timeseries(u,t); 
RunTime = t(end);
data_length = length(u);

%% run simulink
sim('ObserverPhysical.slx');

obs_output = obs_output.Data(:, :);
setup_output = setup_output.Data(:, :)';

theta_1 = setup_output(1, :);
theta_2 = setup_output(2, :);
theta_1_d = [0 setup_output(1, 2:end) - setup_output(1, 1:end-1)]/time_step;
theta_2_d = [0 setup_output(2, 2:end) - setup_output(2, 1:end-1)]/time_step;
t = 0:time_step:data_length*time_step-time_step;

%% plot results

figure(1),clf;

subplot(1,4,1)

    plot(t,theta_1)
    hold on
    plot(t,obs_output(1,:))
    title('$$\theta_1$$', 'Interpreter', 'latex', 'FontSize', 20)
%     ylabel('Setup Measurements')
    ylabel('Angle [rad]',  'FontSize', 20)
    xlabel('Time [s]',  'FontSize', 20)
    legend({'Setup', 'Observer'}, 'FontSize', 10)
    grid on
    
subplot(1,4,2)

    plot(t,theta_1_d)
    hold on
    plot(t,obs_output(2,:), 'LineWidth', 2)
    title('$$\dot{\theta_1}$$', 'Interpreter', 'latex', 'FontSize', 20)
    xlabel('Time [s]', 'FontSize', 20)
    ylabel('Velocity [rad/s]',  'FontSize', 20)
    legend({'Setup', 'Observer'}, 'FontSize', 10)
    grid on

subplot(1,4,3)

    plot(t,theta_2)
    hold on
    plot(t,obs_output(3,:))
    title('$$\theta_2$$', 'Interpreter', 'latex',  'FontSize', 20)
    xlabel('Time [s]', 'FontSize', 20)
    ylabel('Angle [rad]',  'FontSize', 20)
    legend({'Setup', 'Observer'}, 'FontSize', 10)
    grid on

subplot(1,4,4)

    plot(t,theta_2_d)
    hold on
    plot(t,obs_output(4,:), 'LineWidth', 2)
    title('$$\dot{\theta_2}$$', 'Interpreter', 'latex', 'FontSize', 20)
    xlabel('Time [s]', 'FontSize', 20)
    ylabel('Velocity [rad/s]',  'FontSize', 20)
    legend({'Setup', 'Observer'}, 'FontSize', 10)
    grid on

%% NMSE compare

immse(theta_1, obs_output(1,:)) / std(theta_1)

immse(theta_2, obs_output(3,:)) / std(theta_2)

snr(obs_output(1,:), theta_2_d - obs_output(1,:))

snr(obs_output(2,:), theta_1_d - obs_output(2,:))

