clear 
close all
clc
L = 20000;

Period = 5000;
NumPeriod = L + Period / Period;
Range = [-1 1];
Band = [0.001 0.01];

% [u,freq] = idinput([Period 1 NumPeriod], 'sine', Band, Range, 2);

[u,freq] = idinput(L + Period, 'prbs', Band, Range, 2);
% u = idinput(L);
% Sample time in hours
Ts = 0.001; 
Fs = 1 / Ts;
freq = freq/Ts;
t = Ts : Ts : L/1000;
u = u(Period : end);
% plot(t', u, '.')



figure;
u1 = iddata([], u, Ts, 'TimeUnit', 'seconds');
plot(u1)


[xbeam, xpend] = one_run(u, L);




Y = fft(xbeam);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
figure;
plot(f,P1) 
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

figure;
pwelch(xbeam,[],[],[],Fs); %[] length of window to be used


save('xbeam.mat', 'xbeam');
save('xpend.mat', 'xpend');
save('u.mat', 'u');