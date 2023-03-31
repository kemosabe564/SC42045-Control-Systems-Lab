clear,clc
%% setup
hwinit

time_step = 0.001;
RunTime = 5-0.001;

t = 0 : time_step : RunTime;
f = 1;
u = 0.0*sin(2*pi*f*t);
simulink_input = timeseries(u, t);

%% first run
disp("place the beam/pend to 180/0 and press Enter")
waitforbuttonpress();

sim('rotpentemplate_calibrate.slx');

figure(1),clf
subplot(2,1,1)
    plot(t,setup_theta1)
    title('theta_1')
subplot(2,1,2)
    plot(t,setup_theta2)
    title('theta_2')

beam_temp_1 = sum(setup_theta1)/length(setup_theta1);
pend_temp_1 = sum(setup_theta2)/length(setup_theta2);

%% second run
disp("place the beam/pend to 0/180 and press Enter")
waitforbuttonpress();

sim('rotpentemplate_calibrate.slx');

figure(2),clf
subplot(2,1,1)
    plot(t,setup_theta1)
    title('theta_1')
subplot(2,1,2)
    plot(t,setup_theta2)
    title('theta_2')

beam_temp_2 = sum(setup_theta1)/length(setup_theta1);
pend_temp_2 = sum(setup_theta2)/length(setup_theta2);

% angle = gamma_1 * (voltage) + gamma_0
%% fix beam
%gamma_0_beam = beam_temp_2;
%gamma_1_beam = (beam_temp_1 - beam_temp_2) / pi;

gamma_1_beam = pi / (beam_temp_1 - beam_temp_2);
gamma_0_beam = -beam_temp_2;

%% fix pend
% gamma_0_pend = pend_temp_1;
% gamma_1_pend = (pend_temp_2 - pend_temp_1) / pi;

gamma_1_pend = pi / (pend_temp_2 - pend_temp_1);
gamma_0_pend = -pend_temp_1;

%% save

adin_offs = [gamma_0_beam gamma_0_pend];
adin_gain = [gamma_1_beam gamma_1_pend];

adin_offs
adin_gain

save('adin_offs.mat', 'adin_offs');
save('adin_gain.mat', 'adin_gain');