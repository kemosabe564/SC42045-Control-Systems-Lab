clear
close all
clc

% load("noise measurement\xbeam.mat")
% load("noise measurement\xpend.mat")
% 
% load("calib_data\adin_gain.mat")
% load("calib_data\adin_offs.mat")
% 
% % xpend = xpend - mean(xpend);
% % xbeam = xbeam - mean(xbeam);
% 
% xpend = (xpend - adin_offs(2)) / adin_gain(2);
% xbeam = (xbeam - adin_offs(1)) / adin_gain(1);
% 
% noisePower_beam = sum(abs(xbeam).^2) / length(xbeam);
% 
% noisePower_pend = sum(abs(xpend).^2) / length(xpend);



% t = 0 : 0.001 : 2*pi;
% y1 = 0.99 * t;
% y2 = sin(t);
% 
% plot(t, [y1; y2]);
% intersect(y1, y2)
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