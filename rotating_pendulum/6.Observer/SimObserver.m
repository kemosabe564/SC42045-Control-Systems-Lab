clear,clc

%% get matrices from operating point

% operating point:
theta_1_Op = 0;
theta_2_Op = 0;
theta_1_d_Op = 0;
theta_2_d_Op = 0;
T_Op = 0;

set_operating_point;
get_observer_matrix;

%% load test data
load('../X.GetData/Data/Run1.mat')
time_step = 0.001;
data_length = length(u);

theta_1 = meas_theta1;
theta_2 = meas_theta2;
theta_1_d = [0; meas_theta1(2:end) - meas_theta1(1:end-1)]/time_step;
theta_2_d = [0; meas_theta2(2:end) - meas_theta2(1:end-1)]/time_step;
t = 0:time_step:data_length*time_step-time_step;

x_0 = [theta_1(1);
      theta_1_d(1);
      theta_2(1);
      theta_2_d(1);
      0;];

y = [theta_1';theta_2'];

%% Run Observer

x_hat = zeros(5,data_length);
x_hat(:,1) = x_0;

for k = 1:data_length-1
    y_hat = C*x_hat(:,k);
    x_d = A*x_hat(:,k) + B*u(k) + Ke*(y(:,k)-y_hat);
    x_hat(:,k+1) = x_hat(:,k) + x_d*time_step;
end

%% plot results

figure(1),clf;

subplot(2,4,1)
    plot(t,theta_1)
    title('theta_1')
    ylabel('System measurements')
subplot(2,4,2)
    plot(t,theta_1_d)
    title('theta_1-dot')
subplot(2,4,3)
    plot(t,theta_2)
    title('theta_2')
subplot(2,4,4)
    plot(t,theta_2_d)
    title('theta_2-dot')

subplot(2,4,5)
    plot(t,x_hat(1,:))
    ylabel('Observer estimate')
subplot(2,4,6)
    plot(t,x_hat(2,:))
subplot(2,4,7)
    plot(t,x_hat(3,:))
subplot(2,4,8)
    plot(t,x_hat(4,:))






