load('./data/round 1/u.mat')
u = u(1:end-1);

state = run_simulation(beam_params,pend_params,t,u,NonLinFunc,delta_t,state_init);


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