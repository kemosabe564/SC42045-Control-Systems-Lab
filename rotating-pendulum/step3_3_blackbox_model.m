clear
close all
% clc

load("black-box data\round 8\xbeam.mat")
load("black-box data\round 8\xpend.mat")
load("black-box data\round 8\u.mat")

load("calib_data\wb_adin_gain.mat")
load("calib_data\wb_adin_offs.mat")

xpend = (xpend - adin_offs(2)) / adin_gain(2);
xbeam = (xbeam - adin_offs(1)) / adin_gain(1);
L = 10000;
u = u(1:L);

y = xpend;
y = unwrap(y);
figure
y = y';
y = y -mean(y);
y = detrend(y);
plot(y,'r')
hold on

plot(u,'b')
grid on

data = iddata(y, u);


% use OE model
% OE.sys = oe(data, [4, 5, 1]);
% figure
% resid(data, OE.sys) % G is perfect but H is not

% use BJ model


BJ.sys = bj(data, [7, 5, 5, 7, 0]);
figure
resid(data, BJ.sys) % all are perfect

sys = BJ.sys;

bode(sys)
step(sys)
zpk(sys)
% d2c(sys)

compare(data, sys)

y_est = sim(sys, data(:, [], :));

cost_func = 'MSE';
y1 = y_est.y;
yref = data.y;
fit = goodnessOfFit(y1, yref, cost_func)
value = fpe(sys)


% t = 0:0.001:(10-0.001);
% figure;
% plot(t', [y y_est.y])


% M = bj([y u],[4 3 3 4 1]); 
% [A,B,C,D,F] = polydata(M);  % Retrieve polynomial coeff
% H = tf(C,D,1); 
% G = tf(B,F,1); 
% [Phiu,w] = pwelch(u);  % Estimate input power spectrum
% [Gmag,~] = bode(G,w);
% [Hmag,~] = bode(H,w);  
% 
% sigma_ehat = M.Report.Fit.MSE; % Estimate variance of e(t)
% Phiv = squeeze(Hmag).^2*sigma_ehat; 
% Phiy = squeeze(Gmag).^2.*Phiu+Phiv;

% figure;
% loglog(w,Phiv,'linewidth',2); 
% hold on; 
% loglog(w,Phiv./Phiu,'linewidth',2); 
% loglog(w,Phiv./Phiy,'linewidth',2);


% validation

save('step3_3_blackbx_system.mat', 'sys');