function err = costfun_dbl_pend_final_pend(params, u, y1, y2, I)
% Get initial guesses from workspace for normalization
param_size = 0;
assignin('base', 'paramspend0_size', param_size);
init_params = zeros(1,param_size);
init_params = evalin('base', 'paramspend0');

% Move variables into parameter names
params = params.*init_params; % Rescale parameters before giving to model

assignin('base', 'l2', params(1));
assignin('base', 'm2', params(2));
assignin('base', 'c2', params(3));
assignin('base', 'I2', params(4));
assignin('base', 'b2', params(5));

% Call model and exctract output
tm = sim('dbl_pendulum_model.slx',u(:,1),[],u);


% reshape arrays to display them
sz = size(theta1m);
theta1m = reshape(theta1m, [sz(3), 1]);
theta2m = reshape(theta2m, [sz(3), 1]);
y1 = y1';
y2 = y2';
[Max, tmax] = max(theta2m);


interval = 15000;
% Output of function is error between the two
err = y2(I:I+interval) - theta2m(tmax:tmax+interval); % Dont measure static data to neglect stiction

% Dynamic plot updated at each iteration
figure(2);
clf
hold on;
stairs([0:1:interval],y2(I:I+interval), 'r', 'LineWidth',2);
stairs([0:1:interval],theta2m(tmax:tmax+interval), 'b');
legend({'theta 2', 'theta2 (estim)'})

