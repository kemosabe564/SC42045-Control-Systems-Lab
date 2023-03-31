clear,clc
%% other group parameters:

% I_1 = 0.0169;
% b_1 = 6.9742;
% c_1 = -0.0286;
% k_m = 46.1069;
% tau_e = 0.0308;
I_1 = 0.059419;
b_1 = 6.963791;
c_1 = -0.035339;
k_m = 48.346306;
tau_e = 0.005076;

save('Beam Estimate.mat','I_1','b_1','c_1','k_m','tau_e')

% b_2 = 1.346e-4;
% c_2 = 0.06;
% I_2 = 6.81e-5;
b_2 = 0.000020;
c_2 = 0.059106;
I_2 = 0.000088;

save('Pendulum Estimate.mat','b_2','c_2','I_2')

beam_params = [I_1,b_1,c_1,k_m,tau_e];
pend_params = [b_2,c_2,I_2];

%% get initial values:

load('./data/round 1/u.mat')
u = u(1:end-1);
load('./data/round 1/xbeam.mat')
load('./data/round 1/xpend.mat')
delta_t =  0.001;
t = 0 : delta_t: 10-delta_t; 

init_theta_1 = xbeam(1);
init_theta_1_d = 0;
init_theta_2 = xpend(1);
init_theta_2_d = 0;

state_init = [init_theta_1;init_theta_1_d;init_theta_2;init_theta_2_d;0];

y_meas = [xbeam; xpend];

%% run simulation:
load('../../2.NonLinearSystem/NonLinFunc.mat')
state = run_simulation(beam_params,pend_params,t,u,NonLinFunc,delta_t,state_init);

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

%% functions
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


