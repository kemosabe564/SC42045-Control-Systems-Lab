clear
close all

t = 0 : 0.001 : 10;
U = [0 0];
init_theta_1 = pi; init_theta_2 = pi/2;

SIMULATION = true;

if SIMULATION == true
    % generate the biased one
    y = sim('system_model_biased', t, [], U);
    y = [y.yout{1}.Values.Data y.yout{2}.Values.Data];
end


params_init = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.0002, 50, 0.03];
% params_lb = [-0.5, 0.06, -0.5, 0.00002, 0, 0.0002, 0, 0];
% params_ub = [ 0.5, 0.06,  0.5, 0.00002, 6, 0.0002, 55, 0.05];
params_lb = [-0.04, 0.04, 0.074, 0.00001, 4.8, 0.0001, 35, 0.01];
params_ub = [-0.04, 0.08, 0.074, 0.0001 , 4.8, 0.001 , 55, 0.05];



% options = optimoptions(@lsqnonlin, 'Algorithm', 'trust-region-reflective');
OPT = optimset('MaxIter', 25); % options
f = @(x)costfun(x, y, t, U); % anonymous function for passing extra input arguments to the costfunction
[params_hat, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization
% [params_init params_hat], fval % true and final estimated parameter, final cost



figure(1);
% params = params_init;
% y1 = sim('system_model_biased', t, [], U);
a = y';
params = params_hat;
U1 = [U params];
y2 = sim('system_model', t, [], U1);
params = params_init;
U1 = [U params];
y3 = sim('system_model', t, [], U1);

plot(t, a(2,:))
hold on
plot(y2.tout, y2.yout{2}.Values.Data)
plot(y3.tout, y3.yout{2}.Values.Data)
legend({'biased model', 'ideal model with init param', 'ideal model with init param hat'});

function e = costfun(x, y, t, U)

assignin('base', 'params_hat', x);              % assign bhat in workspace
% x
params = x;
% params
U = [U params];
ym = sim('system_model', t, [], U);

ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];

e = (y(:, 2) - ym(:, 2));                               % residual (error)
% sum(e)
figure(2); stairs(t, [y(:, 2) ym(:, 2)]); 
end