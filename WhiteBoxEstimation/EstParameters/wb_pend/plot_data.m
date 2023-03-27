clear,clc
load('xbeam.mat')
load('theta_2.mat')
load('xpend.mat')

%% plot all together
figure(1),clf,hold on
subplot(3,1,1)
    plot(xbeam,'DisplayName','x-beam')
    legend()
subplot(3,1,2)
    plot(xpend,'DisplayName','x-pend')
    legend()
subplot(3,1,3)
    plot(theta_2,'DisplayName','theta-2')
    legend()
    