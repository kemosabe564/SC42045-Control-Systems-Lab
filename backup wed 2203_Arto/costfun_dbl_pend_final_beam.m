function err = costfun_dbl_pend_final_beam(params, u, y1, y2, I)
% Get initial guesses from workspace for normalization
param_size = 0;
assignin('base', 'paramsbeam0_size', param_size);
init_params = zeros(1,param_size);
init_params = evalin('base', 'paramsbeam0');

% Move variables into parameter names
params = params.*init_params; % Rescale parameters before giving to model

assignin('base', 'c1', params(1));
assignin('base', 'I1', params(2));
assignin('base', 'b1', params(3));
assignin('base', 'km', params(4));
assignin('base', 'tau_e', params(5));

% Call model and exctract output
tm = sim('dbl_pendulum_model_beam.slx',u(:,1),[],u);


% reshape arrays to display them
sz = size(theta1m);
theta1m = reshape(theta1m, [sz(3), 1]);
y1 = y1;


interval = 5000;

% Output of function is error between the two
err = y1(I:I+interval) - theta1m(I:I+interval);

% Dynamic plot updated at each iteration
figure(4);
clf
hold on;
stairs([0:1:interval],y1(I:I+interval), 'r', 'LineWidth',2);
stairs([0:1:interval],theta1m(I:I+interval), 'b');
legend({'theta 1', 'theta1 (estim)'})

