function err = costfun_dbl_pend_final(params, u, y1, y2)
% Get initial guesses from workspace for normalization
param_size = 0;
assignin('base', 'params0_size', param_size);
init_params = zeros(1,param_size);
init_params = evalin('base', 'params0');

% Move variables into parameter names
params = params.*init_params; % Rescale parameters before giving to model
assignin('base', 'c1', params(1));
assignin('base', 'c2', params(2));
assignin('base', 'I1', params(3));
assignin('base', 'I2', params(4));
assignin('base', 'b1', params(5));
assignin('base', 'b2', params(6));
assignin('base', 'km', params(7));

% Call model and exctract output
tm = sim('dbl_pendulum_model.slx',u(:,1),[],u);


% reshape arrays to display them
sz = size(theta1m);
theta1m = reshape(theta1m, [sz(3), 1]);
theta2m = -reshape(theta2m, [sz(3), 1]);
theta1m(end) = [];
theta2m(end) = [];
tm(end) = [];
y1 = y1';
y2 = y2';

theta = cat(1,y1,y2);
thetam = cat(1,theta1m,theta2m);

% Output of function is error between the two
% err = theta(500:end-5000) - thetam(500:end-5000);
err = theta(end-8000:end) - thetam(end-8000:end);
figure(1);
clf
hold on;
stairs(tm,y1, 'r', 'LineWidth',2);
stairs(tm,theta1m, 'b');
stairs(tm,y2,'c', 'LineWidth',2);
stairs(tm,theta2m, 'g');
legend({'theta 1', 'theta1 (estim)', 'theta2', 'theta2 (estim)'})

