clear,clc
%% setup simulink
hwinit
h = 0.001;
time_step = h;
RunTime = 5-0.001;
t = 0 : h : RunTime;  

%% setup input
f1 = 5;
a1 = -0.4;
f2 = 2;
a2 = 0.6;

%u = a1*sin(pi*f1*t) + a2*sin(pi*f2*t);
%u = 0;

ramp_end = 0.5;

u = t*ramp_end/RunTime;

%% run
simulink_input = timeseries(u, t);
sim('get_data_sym.slx');

meas_theta1 = unwrap(meas_theta1);
meas_theta2 = unwrap(meas_theta2);

%% plot

figure(1),clf
subplot(3,1,1)
    plot(t,u)
    title('input')
subplot(3,1,2)
    plot(t,meas_theta1)
    title('theta_1')
subplot(3,1,3)
    plot(t,meas_theta2)
    title('theta_2')

%% save data
runNR = '3';

save(append('./Data/Run',runNR),'u','meas_theta1','meas_theta2')