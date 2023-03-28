clear 
close all
clc

hwinit


RunTime = 10-0.001;
time_step = 0.001;

g = 9.81;
l_1 = 0.1;
l_2 = 0.1;
m_1 = 0.125;
m_2 = 0.0487;

params = [-0.0286, 0.0624, 0.0169, 6.81e-5, 6.9742, 2.89e-05, 46.1069, 0.0308];		

% params = [-0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 10.27570530021582, 2.78577414601457e-05, 65.9998023466922, 0.01300000000002200];  %found via white-box
c_1_0 = params(1);
c_2_0 = params(2);
I_1_0 = params(3);
I_2_0 = params(4);
b_1_0 = params(5);
b_2_0 = params(6);
k_m_0 = params(7);
tau_e_0 = params(8);
% syms c_1_0 c_2_0 I_1_0 I_2_0 b_1_0 b_2_0 k_m_0 tau_e_0

%% paper equations
% calculate variables for in assignment matrices
P1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
P2 = m_2 * c_2_0 * c_2_0 + I_2_0;
P3 = m_2 * l_1 * c_2_0;

g1 = (m_1 * c_1_0 + m_2 * l_1) * g;
g2 = m_2 * c_2_0 * g;

t = 0 : 0.001 : 10-0.001;
f = 1;
u = 0.1*sin(2*pi*f*t); 

load('black-box data/round 1/u.mat')
u = u(1:end-1);

simulink_input = timeseries(u, t);

init_theta_1 = pi; init_theta_2 = 0;

params = [9.81, 0.1, 0.1, 0.125, 0.0487, -0.0286, 0.0624, 0.0169, 6.81e-5, 6.9742, 2.89e-05, 46.1069, 0.0308];

load("tate.mat")

% out = sim("nonlinear");


% params = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0300000121036330, 0.0303451968350115, 0.1000000000017210, 1.00882387117299e-05, 10.27570530021582, 1.78577414601457e-05, 65.9998023466922, 0.01300000000002200];


out1 = sim('nonlinear_model1');

figure;
plot(t, out1.nonlinearSim(:, 1) + 0.01)
hold on
% plot(t, out.nonlinearSim(:, 1))
hold on
plot(t, tate(1, :))
legend on

figure;
plot(t, out1.nonlinearSim(:, 2) + 0.01)
hold on
% plot(t, out.nonlinearSim(:, 2))
hold on
plot(t, tate(3, :))
legend on


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




