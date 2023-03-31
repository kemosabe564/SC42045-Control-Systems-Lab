clear,clc

%% load data
round = 1;

load('./round '+string(round)+'/u')
load('./round '+string(round)+'/xbeam')
load('./round '+string(round)+'/xpend')

figure(2),clf
subplot(2,1,1)
    plot(u,'DisplayName','u')
    xlim([0 10000])
    legend()
subplot(2,1,2),hold on
    plot(xbeam,'DisplayName','xbeam')
    plot(xpend,'DisplayName','xpend')
    legend()
    xlim([0 10000])