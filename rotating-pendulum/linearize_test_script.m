params; % a script with definition of system’s parameters


file = "system_model_2021"; % nonlinear Simulink model to be linearized

u0 = [pi; 0]; % initial input guess [input; disturbance]

y0 = [0 0]; % initial output guess

x0 = [pi 0]; % initial state guess

[x0,u0]=trim(file,x0,u0,y0,[],[2],[]);

[A,B,C,D] = linmod(file,x0,u0);
sys = ss(A,B,C,D); % make an LTI object

