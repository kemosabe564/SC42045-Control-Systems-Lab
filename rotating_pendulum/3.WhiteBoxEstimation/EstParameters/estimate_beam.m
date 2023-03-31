clear,clc
% instead of the old version with a simulink model, we simply use a
% function as defined in "NonLinModel.m"

%% get data
% new data:
load('../../X.GetData/Data/Run3.mat');
xbeam = meas_theta1';
xpend = meas_theta2';

%original:
% load('./data/round 1/u.mat')
% u = u(1:end-1);
% load('./data/round 1/xbeam.mat')
% load('./data/round 1/xpend.mat')

delta_t =  0.001;
t = 0 : delta_t: 10-delta_t; 

% choose data size
simulation_T = 3;
t = t(1:simulation_T/delta_t);
u = u(1:simulation_T/delta_t);
xbeam = xbeam(1:simulation_T/delta_t);
xpend = xpend(1:simulation_T/delta_t);

% get non-lin function:
load('../../2.NonLinearSystem/NonLinFunc.mat')

%% fix data 
% the measurement data seems to be offset by certain values. I THINK 
% that we would use the values of:
load('../calib_data/adin_gain.mat')
load('../calib_data/adin_offs.mat')

xbeam = (xbeam + adin_offs(1))*adin_gain(1);
xpend = (xpend + adin_offs(2))*adin_gain(2);
% that SEEMS to work: (but should be checked)
% figure(1),clf
% subplot(2,1,1)
%     plot(u,'DisplayName','u')
%     xlim([0 10000])
%     legend()
% subplot(2,1,2),hold on
%     plot(xbeam,'DisplayName','xbeam')
%     plot(xpend,'DisplayName','xpend')
%     legend()
%     xlim([0 10000])

%% get initial values:

init_theta_1 = xbeam(1);
init_theta_1_d = 0; % (xbeam(2)-xbeam(1))/(t(2)-t(1)); % not very accurate, but probably good enough.
init_theta_2 = xpend(1);
init_theta_2_d = 0; %(xpend(2)-xpend(1))/(t(2)-t(1)); % not very accurate, but probably good enough.

state_init = [init_theta_1;init_theta_1_d;init_theta_2;init_theta_2_d;0];

y_meas = [xbeam; xpend];

%% set parameters
% pendulum parameters found earlier:
load("Pendulum Estimate.mat")
pend_params = [c_2,I_2,b_2];

% initial beam parameters:
%                   [c_1_0, I_1_0,  b_1_0,  k_m_0,  tau_e_0]
beam_params_init =  [-0.04, 0.074,  4.8,    50,     0.03]; %original
%beam_params_init =  [-0.0286,  0.02,    7,    46,     0.03]; % other group

beam_params_lb =    [-0.06,  0.000,  0,  -50, 0.00];
beam_params_ub =    [ 0.00,  2.00,  50,  80,    0.9];

%% simulate using original Parameters:
state = run_simulation(beam_params_init,pend_params,t,u,NonLinFunc,delta_t,state_init);

%% plot
figure(1),clf
subplot(3,1,1),hold on
    title('Input')
    plot(t,u,'DisplayName','input u');
    ylabel('Input (voltage)')
subplot(3,1,2),hold on
    legend()
    title('Beam')
    plot(t,y_meas(1,:),'DisplayName','Measurements')
    plot(t,state(1,:),'DisplayName','Initial Parameters')
    ylabel('theta_1 (rad)')
subplot(3,1,3),hold on
    legend()
    title('Pendulum')
    plot(t,y_meas(2,:),'DisplayName','Measurements')
    plot(t,state(3,:),'DisplayName','Initial Parameters')
    ylabel('theta_2 (rad)')
    xlabel('time (s)')

%% parameter optimization
f = @(beam_params)costfun(beam_params,pend_params,y_meas,t,u,NonLinFunc,delta_t,state_init);

OPT = optimset('Display','iter');
params_hat = lsqnonlin(f, beam_params_init, beam_params_lb, beam_params_ub, OPT);
% params_hat = fmincon(f, beam_params_init,[],[],[],[],beam_params_lb,beam_params_ub,[],OPT); 

state = run_simulation(params_hat,pend_params,t,u,NonLinFunc,delta_t,state_init);

%% Show results
figure(1)   
subplot(3,1,2)
    plot(t,state(1,:),'--','DisplayName','Estimated Parameters')
subplot(3,1,3)
    plot(t,state(3,:),'--','DisplayName','Estimated Parameters')
    
c_1 = params_hat(1);
I_1 = params_hat(2);
b_1 = params_hat(3);
k_m = params_hat(4);
tau_e = params_hat(5);

disp('Estimated Parameters:')
    disp(['c_1 = ', num2str(params_hat(1))])
    disp(['I_1 = ', num2str(params_hat(2))])
    disp(['b_1 = ', num2str(params_hat(3))])
    disp(['k_m = ', num2str(params_hat(4))])
    disp(['tau_e = ', num2str(params_hat(5))])

save('Beam Estimate','c_1','I_1','b_1', 'k_m','tau_e')

%% Functions:
function cost = costfun(beam_params,pend_params,y_meas,t,u,NonLinFunc,delta_t,state_init)
    state = run_simulation(beam_params,pend_params,t,u,NonLinFunc,delta_t,state_init);
    e_th_1 = y_meas(1,:) - state(1,:); 
%     e_th_2 = y_meas(2,:) - state(3,:);
    
%     e = y_meas - [state(1,:) state(3,:)];

%    cost = [e_th_1;e_th_2];
%     cost = sum(e_th_1.^2) + sum(e_th_2.^2);
    cost = e_th_1.^2;
end

function state = run_simulation(beam_params,pend_params,t,u,NonLinFunc,delta_t,state_init)
    c_1 = beam_params(1);
    I_1 = beam_params(2);
    b_1 = beam_params(3);
    k_m = beam_params(4);
    tau_e = beam_params(5);

    c_2 = pend_params(1);
    I_2 = pend_params(2);
    b_2 = pend_params(3);
    
    state = zeros(5,length(t)); %[theta_1;theta_1_d;theta_2;theta_2_d;T]
    state(:,1) = state_init;

    for k = 1:length(t)-1
        % states:
        theta_1 = state(1,k);
        theta_d_1 = state(2,k);
        theta_2 = state(3,k);
        theta_2_d = state(4,k);
        T = state(5,k);
        % input:
        u_k = u(k);

        % evolve state:
        x_d = NonLinFunc(I_1,I_2,T,b_1,b_2,c_1,c_2,k_m,tau_e,theta_1,theta_2,theta_d_1,theta_2_d,u_k);
        state(:,k+1) = state(:,k) + x_d*delta_t;
    end
   % plot(t,state(1,:),':','HandleVisibility','off')
end




