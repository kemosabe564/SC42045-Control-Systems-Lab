params = [-0.04, 0.06, 0.074, 0.00102, 4.8, 0.00077, 50, 0.03];
% h = 0.001;
u = 1:1:10;
[x1]=sim('system_model', %time vector, [], (time vector, input values);
plot(x1.tout, x1.yout{2}.Values.Data)


params = [-0.04, 0.06, 0.074, 0.00602, 4.8, 0.00077, 50, 0.03];

[x1]=sim('system_model', u);
hold on
plot(x1.tout, x1.yout{2}.Values.Data)