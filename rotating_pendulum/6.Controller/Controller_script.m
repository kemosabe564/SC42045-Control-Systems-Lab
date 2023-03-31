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
    Q = diag([1100, 0.001, 1100, 0.001, 0.001]);
    Q(3,1) = 1000;
    Q(1,3) = 1000;
    R = 200;
elseif strcmp(set_position,'downup') % works
    Q = diag([400, 0.1, 200, 0.001, 0.01]);
    Q(3,1) = 100;
    Q(1,3) = 100;
    R = 10;
elseif strcmp(set_position,'upup') % does not work yet
    Q = diag([300, 10, 100, 1, 0.01]);
    Q(3,1) = 200;
    Q(1,3) = 200;
    R = 20000;
end


% somewhat works for upup
%     Q = diag([300, 10, 100, 1, 0.010]);
%     Q(3,1) = 200;
%     Q(1,3) = 200;
%     R = 20000;


N = zeros(5,1);
sys = ss(A,B,C,D);
[L,~,Poles] = lqr(sys,Q,R);

%% setup simulink
hwinit
time_step = 0.001;
RunTime = 40;

%% run simulink
sim('ControllerPhysical.slx');
