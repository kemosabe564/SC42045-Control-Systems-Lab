clear,clc
%% get data
%load("./wb_pend/theta_2.mat")
load('../../X.GetData/Data/Run_pend_only1.mat')

theta_2 = meas_theta2(455:end);

delta_t =  0.001;
t = 0 : delta_t: length(theta_2)*delta_t-delta_t;

% get non-lin function:
load('../../2.NonLinearSystem/NonLinFunc.mat')

%% get starting point

init_theta_2 = theta_2(1);
init_theta_2_d = (theta_2(2)-theta_2(1))/(t(2)-t(1)); % ugly solution, but best I could do with the faulty data.

state_init = [init_theta_2;init_theta_2_d];

y_meas = theta_2;

%% initial parameters
% paramters:         [c_2_0,  I_2_0,    b_2_0]
pend_params_init = [0.06, 0.00012, 0.0002]; %original
%pend_params_init = [0.06, 6.81e-5, 1.346e-4]; % other group

pend_params_lb =     [0.02,   0.00000,  0.0000001];
pend_params_ub =     [0.08,   0.00024,  0.001];

%% simulate using original Parameters:
state = run_simulation(pend_params_init,t,NonLinFunc,delta_t, state_init);

%disp(costfun(pend_params_init, y_meas, t, NonLinFunc, delta_t, state_init));

figure(1),clf,hold on,grid on
    legend()
    plot(t,y_meas,'DisplayName','Measurements')
    plot(t,state(1,:),'DisplayName','Initial Parameters')
    title('Physical Measurements and simulation values of Theta_2')
    xlabel('time (s)')
    ylabel('theta_2 (rad)')
    legend()

%% parameter optimization
f = @(pend_params)costfun(pend_params, y_meas, t, NonLinFunc, delta_t, state_init);

OPT = optimset('Display','iter');
% useless matrices, but needed for fmincon

% params_hat = lsqnonlin(f, pend_params_init, pend_params_lb, pend_params_ub, OPT); 
params_hat = fmincon(f, pend_params_init,[],[],[],[],pend_params_lb,pend_params_ub,[],OPT); 

state = run_simulation(params_hat,t,NonLinFunc,delta_t, state_init); 

%% Show results
figure(1)   
    plot(t,state(1,:),'DisplayName','Estimated Parameters')
    ylim([-1.5 1.5])

c_2 = params_hat(1);
I_2 = params_hat(2);
b_2 = params_hat(3);

disp('Estimated Parameters:')
    disp(['c_2 = ', num2str(params_hat(1))])
    disp(['I_2 = ', num2str(params_hat(2))])
    disp(['b_2 = ', num2str(params_hat(3))])

save('Pendulum Estimate','c_2','I_2','b_2')

%% Function:
function cost = costfun(params, y_meas, t, NonLinFunc, delta_t, state_init)
    state = run_simulation(params,t,NonLinFunc,delta_t, state_init);
    e = y_meas' - state(1,:);
    cost = sum(e.^2);
end

function state = run_simulation(params,t,NonLinFunc,delta_t,state_init)
    c_1 = 0;
    c_2 = params(1);
    I_1 = 0;
    I_2 = params(2);
    b_1 = 0;
    b_2 = params(3);
    k_m = 0;
    tau_e = 0;
    
    state = zeros(2,length(t)); %[theta_2;theta_2_d] (A.k.a. we ignore the beam and the motor in this optimization: only pendulum)
    state(:,1) = state_init;

    for k = 1:length(t)-1
        theta_1 = pi; % we lock the beam:
        theta_d_1 = 0;
        T = 0; % we ignore the motor.
        u = 0; % we have no input.
        
        theta_2 = state(1,k);
        theta_2_d = state(2,k);
        
        x_d = NonLinFunc(I_1,I_2,T,b_1,b_2,c_1,c_2,k_m,tau_e,theta_1,theta_2,theta_d_1,theta_2_d,u);
        theta_2_dd = x_d(4);

        state(:,k+1) = state(:,k) + [theta_2_d;theta_2_dd]*delta_t;
    end
   % plot(t,state(1,:),':','HandleVisibility','off')
end





