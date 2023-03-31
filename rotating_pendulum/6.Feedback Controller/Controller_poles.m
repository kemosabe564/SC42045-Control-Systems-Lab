clear,clc
%% load the observer data
set_position = 'downup';

if strcmp(set_position,'downdown')
    theta_1_Op = pi;
    theta_2_Op = 0;
elseif strcmp(set_position,'downup')
    theta_1_Op = pi;
    theta_2_Op = pi;
elseif strcmp(set_position,'upup')
    theta_1_Op = 0;
    theta_2_Op = 0;
end

theta_1_d_Op = 0;
theta_2_d_Op = 0;
T_Op = 0;

run('../5.Observer/set_operating_point.m');
run('../5.Observer/get_observer_matrix.m')

load('../5.Observer/System_matrices.mat')
load('../5.Observer/ObserverMatrix.mat')

theta_1_0 = theta_1_Op;
theta_2_0 = theta_2_Op;

%% make controller gain L

if strcmp(set_position,'downdown') % works
    omega_eig_beam = 22.30;
    damp_beam = -0.962;
    omega_eig_pend = 7.16;
    damp_pend = -0.64;
    tss = 0.0098;
    z1_gain = 0.0;


elseif strcmp(set_position,'downup') % works
    %original values
%     omega_eig_beam = 27.28;
%     damp_beam = -1.04;
%     omega_eig_pend = 9.16;
%     damp_pend = -0.88;
%     tss =  0.0098;
    %after tuning
    omega_eig_beam = 27.28;
    damp_beam = -3.04;
    omega_eig_pend = 9.16;
    damp_pend = -0.88;
    tss =  0.0098;
    z1_gain = 0.9;

elseif strcmp(set_position,'upup') % does not work yet
    omega_eig_beam = 20.21;
    damp_beam = -1.21;
    omega_eig_pend = 5.28;
    damp_pend = -1.20;
    tss =  0.0098;
    z1_gain = 0.5;
    

end
pole_pend1_start = omega_eig_pend*(damp_pend + sqrt(damp_pend^2 -1));
pole_pend2_start = omega_eig_pend*(damp_pend - sqrt(damp_pend^2 -1));

pole_beam1_start = omega_eig_beam*(damp_beam + sqrt(damp_beam^2 -1));
pole_beam2_start = omega_eig_beam*(damp_beam - sqrt(damp_beam^2 -1));

tau = tss/4;
poleT_start =-1/tau; 

% get poles from params

%place the poles in the controller gain
L = place(A,B,[pole_pend1_start,pole_pend2_start,pole_beam1_start,pole_beam2_start,poleT_start]);




%% setup simulink
hwinit
time_step = 0.001;
RunTime = 10;

%% run simulink
sim('ControllerPhysical.slx');

%%
%calculateMSE
ref_0 = zeros(length(theta_1_measurement.Data),1);
% MSE_theta_1 = immse(ref_0,theta_1_measurement.Data) / (max(theta_1_measurement.Data) - min(theta_1_measurement.Data));
% MSE_theta_2 = immse(ref_0,theta_2_measurement1.Data) / (max(theta_2_measurement1.Data) - min(theta_2_measurement1d.Data));
NMSE_theta_1 = (immse(ref_0,theta_1_measurement.Data) / std((theta_1_measurement.Data)))*100
NMSE_theta_2 = (immse(ref_0,theta_2_measurement1.Data) / std((theta_1_measurement.Data)))*100