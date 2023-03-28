clear 
close all
clc

hwinit_raw

time_step = 0.001;
RunTime = 5-0.001;

t = 0 : time_step : RunTime;
f = 1;
u = 0.0*sin(2*pi*f*t);
simulink_input = timeseries(u, t);

% we could use the following to create the effect of stop and continue
disp("place the beam/pend to 180/0 and press Enter")
waitforbuttonpress();


sinulink_output = sim('rotpentemplate_whitebox.slx');

figure;
plot(t, setup_theta1')
hold on
plot(t, setup_theta2')

beam_temp_1 = sum(setup_theta1)/length(setup_theta1);
pend_temp_1 = sum(setup_theta2)/length(setup_theta2);

disp("place the beam/pend to 0/180 and press Enter")
waitforbuttonpress();


sinulink_output = sim('rotpentemplate_whitebox.slx');

figure;
plot(t, setup_theta1')
hold on
plot(t, setup_theta2')

beam_temp_2 = sum(setup_theta1)/length(setup_theta1);
pend_temp_2 = sum(setup_theta2)/length(setup_theta2);

% angle = gamma_1 * (voltage) + gamma_0
% for the beam
gamma_0_beam = beam_temp_2;
gamma_1_beam = (beam_temp_1 - beam_temp_2) / pi;

% gamma_1_beam = pi / (beam_temp_1 - beam_temp_2);
% gamma_0_beam = -beam_temp_2;

% for the pend
gamma_0_pend = pend_temp_1;
gamma_1_pend = (pend_temp_2 - pend_temp_1) / pi;

% gamma_1_pend = pi / (pend_temp_2 - pend_temp_1);
% gamma_0_pend = -pend_temp_1;

adin_offs = [gamma_0_beam gamma_0_pend];
adin_gain = [gamma_1_beam gamma_1_pend];

adin_offs
adin_gain

save('adin_offs.mat', 'adin_offs');
save('adin_gain.mat', 'adin_gain');

% %% test the calib
% 
% hwinit
% 
% % we could use the following to create the effect of stop and continue
% disp("place the beam/pend to 180/0 and press Enter")
% waitforbuttonpress();
% 
% sinulink_output = sim('rotpentemplate_whitebox.slx');
% 
% figure;
% plot(t, setup_theta1')
% hold on
% plot(t, setup_theta2')
% 
% 
% disp("place the beam/pend to 0/180 and press Enter")
% waitforbuttonpress();
% 
% sinulink_output = sim('rotpentemplate_whitebox.slx');
% 
% figure;
% plot(t, setup_theta1')
% hold on
% plot(t, setup_theta2')