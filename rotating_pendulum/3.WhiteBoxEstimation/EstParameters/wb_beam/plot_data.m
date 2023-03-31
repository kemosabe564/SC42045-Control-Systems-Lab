clear,clc
load('xbeam.mat')
load('xpend.mat')

%% plot all together
figure(1),clf,hold on
subplot(2,1,1)
    plot(xbeam,'DisplayName','x-beam')
    legend()
subplot(2,1,2)
    plot(xpend,'DisplayName','x-pend')
    legend()
    