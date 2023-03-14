clc
clear
close all

%% load data
load("calib_data\adin_gain.mat")
load("calib_data\adin_offs.mat")

load("white-box data\wb_beam\xbeam.mat")
load("white-box data\wb_beam\xpend.mat")

xpend = (xpend - adin_offs(2)) / adin_gain(2);
xbeam = (xbeam - adin_offs(1)) / adin_gain(1); %this is a comment

t = 0 : 0.001 : 15;
xbeam = unwrap(xbeam);
% start_point = 639;
% t = t(start_point: start_point + 10000) - t(start_point);
% xpend = xpend(start_point: start_point + 10000);
t = t(1:15000);

figure(1);
plot(t, xbeam);

t = 0 : 0.001 : 15-0.001;
U = [0 1];
init_theta_1 = pi; 
init_theta_2 = pi/2;

%% linear system

x0 = [init_theta_1;0;init_theta_2;0]; %[theta_1; theta_1_d; theta_2; _theta_2_d] (?????)

A = [0 1 0 0;
    ? ? ? ?;
    0 0 0 1;
    ? ? ? ?;];

B = [0;
     ?;
     0;
     ?;]

C = [1 0 0 0;
     0 0 1 0;]; % because we want to see theta_1 and theta_2

D = zeros(2,1);



%% run simulink






















