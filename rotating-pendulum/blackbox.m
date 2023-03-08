clear
close all
clc

load("black-box data\round 1\xbeam.mat")
load("black-box data\round 1\xpend.mat")
load("black-box data\round 1\u.mat")

y = xpend;

figure
y = y';
y = y -mean(y);
y = detrend(y);
plot(y,'r')
hold on

plot(u,'b')
grid on

data=iddata(y, u);


% use OE model
OE.sys = oe(data, [5, 5, 1]);
figure
resid(data, OE.sys) % G is perfect but H is not

% use BJ model
BJ.sys = bj(data, [5, 5, 5, 5, 1]);
figure
resid(data, BJ.sys) % all are perfect

