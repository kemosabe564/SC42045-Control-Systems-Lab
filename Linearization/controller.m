clear,clc

load('System.mat')

inputs = {'u'};
outputs = {'theta_1 theta_2'};

G = ss(A, B, C, D, 'inputname', inputs, 'outputname', outputs);

h = 0.001;

H = c2d(G, h);

% G = d2c(H)

G

% TF = ss2tf(A, B, C, D)

t1 = 0 : 0.01 : 10;
pole(G)
figure;
impulse(G, t1)

% PID not working

% Kp = 100;
% Ki = 1;
% Kd = 30;
% 
% C1 = pid(Kp, Ki, Kd);
% T1 = feedback(G, C1);
% 
% impulse(T1, t1)

% 
% P1 = -0.5 + 0.4i;
% P2 = -0.5 - 0.5i;
% P3 = -0.7 + 0.4i;
% P4 = -0.7 - 0.5i;
% P5 = -0.8 - 0.2i;
% 
% K = place(A, B, [P1, P2, P3, P4, P5]);
% 
% Ac = (A - B*K);
% 
% G1 = ss(Ac, B, C, D);
% 
% pole(G1)
% 
% figure;
% impulse(G1, t1)
% step(G1)