params_hat = [-0.001 0.077 0.2 0.00004 20.684 0.00004 15 0.03];

t = 0 : 0.001 : 15-0.001;
U = [0 1];


params = params_hat;
U1 = [U params];
y2 = sim('system_model_2021', t, [], U1);

u0 = [1];
y0 = [pi; 0];
x0 = [pi; 0];

[x0, u0] = trim('system_model_2021', x0, u0, y0, [], [2], []);

[A, B, C, D] = linmod('system_model_2021', x0, u0);
