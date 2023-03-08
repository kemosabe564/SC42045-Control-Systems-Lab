Period = 5000;
NumPeriod = 2;
Range = [-1 1];
Band = [0.001 0.1];

[u,freq] = idinput([Period 1 NumPeriod], 'sine', Band, Range, 20);


% Sample time in hours
Ts = 0.001; 
freq = freq/Ts
t = Ts : Ts : 10;
plot(t', u, '.')

figure;
u1 = iddata([], u, Ts, 'TimeUnit', 'seconds');
plot(u1)

params_hat = [-0.04, 0.077, 0.074, 0.00004, 4.8, 0.00004, 50, 0.03];


% t1 = 0 : Ts : Ts;
% init_theta_1 = pi; init_theta_2 = pi/2;
% y = [init_theta_1 init_theta_2];
% for i = 1 : 300
%     U = [0 1 params_hat];
%     init_theta_1 = y(i, 1); init_theta_2 = y(i, 2);
%     y3 = sim('system_model_2021', t1, [], U);
%     
%     temp = [y3.yout{1}.Values.Data(end) y3.yout{2}.Values.Data(end)]
%     
%     y = [y; temp]
% end

