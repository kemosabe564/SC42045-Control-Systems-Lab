clear 
close all
clc

load("noise measurement\xbeam.mat")
load("noise measurement\xpend.mat")

load("calib_data\wb_adin_gain.mat")
load("calib_data\wb_adin_offs.mat")
xbeam0 = xbeam;
xpend0 = xpend;
% xpend = xpend - mean(xpend);
% xbeam = xbeam - mean(xbeam);

% xpend = (xpend - adin_offs(2)) / adin_gain(2);
% xbeam = (xbeam - adin_offs(1)) / adin_gain(1);

noisePower_beam = sum(abs(xbeam0 - mean(xbeam0)).^2) / length(xbeam0);

noisePower_pend = sum(abs(xpend0 - mean(xpend0)).^2) / length(xpend0);


L = 10000;

Period = 5000;
NumPeriod = L / Period + Period / Period;
Range_sin = [-0.3 0.3];
Range_prbs = [-0.8 0.8];
Band = [0.0001 0.009];

[u,freq] = idinput([Period 1 NumPeriod], 'sine', Band, Range_sin, 20);

% [u,freq] = idinput(L + Period, 'prbs', Band, Range_prbs, 5);
% u = idinput(L);
% Sample time in hours
time_step = 0.001; 
Fs = 1 / time_step;
freq = freq/time_step
t = 0 : time_step : L/1000;
u = u(Period : end);
% plot(t', u, '.')
RunTime = 10;


figure;
u1 = iddata([], u, time_step, 'TimeUnit', 'seconds');
plot(u1)


% [xpend, xbeam] = step3_blackbox_one_single_run(u, L);

hwinit

simulink_input = timeseries(-u, t);
simulink_output = sim('rotpentemplate_whitebox');

xbeam = theta1{1}.Values.Data';
xpend = theta2{1}.Values.Data';


% Y = fft(xbeam);
% 
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% 
% f = Fs*(0:(L/2))/L;
% figure;
% plot(f,P1) 
% title("Single-Sided Amplitude Spectrum of X(t)")
% xlabel("f (Hz)")
% ylabel("|P1(f)|")
% 
% figure;
% pwelch(xbeam,[],[],[],Fs); %[] length of window to be used
% 

save('xbeam.mat', 'xbeam');
save('xpend.mat', 'xpend');
save('u.mat', 'u');




% sigPower = sum(abs(xbeam - (xbeam0-mean(xbeam0))).^2) / length((xbeam - (xbeam0-mean(xbeam0))));
% SNR_10 = 10 * log10 (sigPower/noisePower_beam);
SNR = snr(xbeam(2:end) - (xbeam0-mean(xbeam0)), (xbeam0-mean(xbeam0)));
SNR1 = snr(xpend(2:end) - (xpend0-mean(xpend0)), (xpend0-mean(xpend0)));