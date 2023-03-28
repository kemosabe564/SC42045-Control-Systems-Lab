close all

hwinit
test = 1;
if test == 1
    sim('compare_setup_nonlinear')
end
load("params.mat")

t = 0 : 0.001 : 10;



figure;
subplot(1, 3, 1)
plot(t', (linear_output(:, 1)))
subplot(1, 3, 2)
plot(t', (nonlinear_output(:, 1)))
subplot(1, 3, 3)
plot(t', unwrap(setup_output(:, 1)))



figure;
subplot(1, 3, 1)
plot(t', (linear_output(:, 2)))
subplot(1, 3, 2)
plot(t', (nonlinear_output(:, 2)))
subplot(1, 3, 3)
plot(t', unwrap(setup_output(:, 2)))

%% MSE

disp(sum((linear_output(:, 1) + pi - setup_output(:, 1)).^2) / length(t))

disp(sum((linear_output(:, 2) - setup_output(:, 2)).^2) / length(t))

disp(sum((nonlinear_output(:, 1) - setup_output(:, 1)).^2) / length(t))

disp(sum((nonlinear_output(:, 2) - setup_output(:, 2)).^2) / length(t))