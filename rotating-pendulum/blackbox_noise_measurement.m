clear
close all
clc

y = 0.25;
y = y / pi * 180
y = 0.37;
y = y / pi * 180

L = 5000;

Ts = 0.001; 
Fs = 1 / Ts;
t = 0 : Ts : (L * Ts);
f1 = 2;

u = chirp(t, 0, 5, 35);
plot(t, u)

[xbeam1, xpend1] = one_run(u, L);

% xpend1 = xpend1 - mean(xpend1);
% xbeam1 = xbeam1 - mean(xbeam1);
% 
% xpend1 = (xpend1 - adin_offs(2)) / adin_gain(2);
% xbeam1 = (xbeam1 - adin_offs(1)) / adin_gain(1);
% 
% figure(5); stairs([xbeam1; xpend1]'); ylabel('Beam, Pendulum');
% 
% sigPower = sum(abs(xbeam1 - xbeam).^2) / length((xbeam1 - xbeam));
% 
% SNR_10 = 10 * log10 (sigPower/noisePower_beam);

% The maximum frequency is 35 Hz, the suitable amplitude is 1.5 for keeping the
% error smaller than 1% and maintaining SNR larger than 50
