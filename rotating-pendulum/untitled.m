params = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00077, 50, 0.03];
t = 0 : 0.001 : 10;
init_theta_1 = pi; init_theta_2 = pi/2;
U = [0 0 params];
y1 = sim('system_model1', t, [], U);
% y2 = sim('system_model_biased', t, [], U);
% 
plot(y1.tout, y1.yout{2}.Values.Data)
% hold on
% plot(y2.tout, y2.yout{2}.Values.Data)

% figure;
% plot(y2.tout, y2.yout{2}.Values.Data)
% hold on
% 
% params = [-0.04, 0.06, 0.014, 0.00002, 4.8, 0.00077, 50, 0.03];
% for i = 1: 1: 3
% params = params - 0.00001;
% t = 0 : 0.001 : 10;
% init_theta_1 = 0; init_theta_2 = pi;
% U = [0 2];
% y1 = sim('system_model', t, [], U);
% % y2 = sim('system_model_biased', t, [], U);
% plot(y1.tout, y1.yout{2}.Values.Data)
% end





