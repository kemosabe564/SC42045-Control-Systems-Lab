close all
clear
clc

load("sys.mat")


load("black-box data\round 7\xbeam.mat")
load("black-box data\round 7\xpend.mat")
load("black-box data\round 7\u.mat")

load("calib_data\adin_gain.mat")
load("calib_data\adin_offs.mat")

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


compare(data, sys)

y_est = sim(sys, data(:, [], :));

cost_func = 'NRMSE';
y = y_est.y;
yref = data.y;
fit = goodnessOfFit(y, yref, cost_func)
value = fpe(sys)
