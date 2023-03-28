%% Perform white box parameter estimation of rotational pendulum
clear all
% set the initial values and the true parameters
truepars = [0.1, 0.1, 0.125, 0.05, -0.04, 0.06, 0.074, 0.00012, 4.8, 0.0002, 50];
params0 = [-0.035, 0.055, 0.07, 0.0001, 4, 0.0001, 40];
%          c1        c2    I1    I2     b1   b2    km

params0_size = length(params0);

% scale parameters for analysis
normalized_params0 = params0./params0;

% Intital paramater variables for true model
l1 = truepars(1);
l2 = truepars(2);
m1 = truepars(3);
m2 = truepars(4);
c1 = truepars(5);
c2 = truepars(6);
I1 = truepars(7);
I2 = truepars(8);
b1 = truepars(9);
b2 = truepars(10);
km = truepars(11);

% Define input
T = 10;    % length of experiment
h = 0.001;   % sampling interval
time_vector = [0:h:T]';
% Define the temporary step input vector
step_vector = zeros(size(time_vector)); % Initialize with zeros
step_vector((time_vector >= 1) & (time_vector <= 1.5)) = 1; % Set amplitude to 1 between 1s and 2s

input = step_vector;

% call true system to get output
sim('dbl_pendulum.slx',time_vector,[],[time_vector input]);

% use lsqnonlin to converge towards true parameters
options = optimset('MaxIter', 500);
cost_fun_with_custom_input = @(x)costfun_dbl_pend_final(x, [time_vector input], theta1, theta2);
params = lsqnonlin(cost_fun_with_custom_input, normalized_params0, [], [], options);

% Rescale obtained parameters
params = params.*params0;

% display results and compare
truepars
params