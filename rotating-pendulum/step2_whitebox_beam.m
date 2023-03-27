% clc
% close all
% 
% hwinit
% 
% test = 0;
% 
% 
% % logging data
% if test == 1   
%     RunTime = 10;
%     time_step = 0.001;
%     t = 0 : 0.001 : 10-0.001;
%     f = 1;
%     u = 0.5*sin(2*pi*f*t); 
%     
%     L = 10000;
%     
%     Period = 5000;
%     NumPeriod = L / Period;
%     Range_sin = [-0.5 0.5];
%     Band = [0.0005 0.003];
%     
%     [u, freq] = idinput([Period 1 NumPeriod], 'sine', Band, Range_sin, 5);
%     
%     figure(1)
%     plot(t', u)
%     xlabel("t");
%     ylabel("value");
%     title("input signal")
%     simulink_input = timeseries(u, t);
%     sinulink_output = sim('rotpentemplate_whitebox.slx');
% end 
% 
% theta_1 = theta1{1}.Values.Data;
% theta_2 = theta2{1}.Values.Data;
% 
% theta_1 = detrend(theta_1);
% theta_2 = detrend(theta_2);
% 
% figure(2)
% subplot(1, 2, 1)
% plot(t', theta_1)
% 
% subplot(1, 2, 2)
% plot(t', theta_2)
% 
% y = [theta_1 theta_2];
% 
% 
% 
% U = [0 0];
% init_theta_1 = pi; init_theta_2 = 0;
% simulink_input = timeseries(-u, t);
% 
% 
% params_init = [-0.04, 0.06, 0.074, 0.00002, 4.8, 0.00002, 50, 0.03];
% params_init = [-0.0498576317395758	0.0521631168583715	0.0200000124162358	4.99977419538987e-05	13.1935018802278	4.99999998860365e-05	79.7956857573053	0.00500301580478141];
% params_init = [-0.0499559295297077	0.0303451968350115	0.0200000000018710	3.27503197051762e-05	2.03233069797987	3.99999999753543e-05	11.9094873772847	0.00997036421877500];
% % params_lb = [-0.5, 0.06, -0.5, 0.00002, 0, 0.0002, 
% params_lb = [-0.05, 0.03, 0.02, 0.000001, 2, 0.000001, 10, 0.005];
% params_ub = [-0.03, 0.09, 0.12, 0.00005, 30, 0.00005, 80, 0.09];
% 
% OPT = optimset('MaxIter', 25); % options
% f = @(x)costfun(x, y, t, U); % anonymous function for passing extra input arguments to the costfunction
% [params_hat, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization
% % [params_init params_hat], fval % true and final estimated parameter, final cost
% 
% % good for the beam
% % -0.0300000411438343	0.0608809269863771	0.0600002933629279	4.19557047350708e-05	7.59863698200564	5.02530622708186e-06	49.9999982573319	0.00500068334824114
% % -0.0300000121036330	0.0679408434466040	0.0600000000017210	1.73885618127026e-05	8.19570530021582	7.72636191514716e-06	49.9998023466922	0.00500000000002200
% 
% function e = costfun(x, y, t, U)
%     
%     assignin('base', 'params_hat', x);              % assign bhat in workspace
%     params = x;
%     U = [U params];
%     ym = sim('whitebox_nonlinear_model_2021', t, [], U);
%     
%     ym = [ym.yout{1}.Values.Data ym.yout{2}.Values.Data];
%     
%     ym = detrend(ym);
%     
%     % e = y(:, 1) - ym(:, 1);                               % residual (error)
%     % e = (y(:, 2) - ym(:, 2));                               % residual (error)
%     e = y - ym;
% 
%     figure(3); stairs(t, [y(:, 1) ym(:, 1)]); 
%     xlabel("t"); ylabel("radian")
%     title("real-time comparison")
%     figure(4); stairs(t, [y(:, 2) ym(:, 2)]); 
%     xlabel("t"); ylabel("radian")
%     title("real-time comparison")
% 
% end


clear
close all

RunTime = 10;
time_step = 0.001;

load("white-box data\wb_pend\theta_2.mat")
t = 0 : 0.001 : 10;
f = 1;
u = 0.0*sin(2*pi*f*t); 

% intercept the right period of data

theta_2 = theta_2(2441: 2441 + 10000);
figure(2)
subplot(1, 2, 1)
plot(t', theta_2)

subplot(1, 2, 2)
plot(t', theta_2)



init_theta_1 = pi; init_theta_2 = -pi/2;

y = theta_2;

simulink_input = timeseries(-u, t);


% params_init = [9.81, 0.1, 0.1, 0.125, 0.05, -0.0300000121036330, 0.0813451968350115, 0.1000000000017210, 2.00882387117299e-05, 10.27570530021582, 2.78577414601457e-05, 65.9998023466922, 0.01300000000002200];
% params_lb = [9.81, 0.1, 0.1, 0.125, 0.03, -0.05, 0.03, 0.02, 0.000001, 2, 0.000001, 10, 0.005];
% params_ub = [9.81, 0.1, 0.1, 0.125, 0.06, -0.03, 0.09, 0.12, 0.00005, 30, 0.00005, 80, 0.09];
params_init = [9.81, 0.1, 0.1, 0.125, 0.05, -0.03, 0.06, 0.12, 0.00002, 30, 0.00002, 80, 0.09];
params_lb = [9.81, 0.1, 0.1, 0.125, 0.05, -0.03, 0.03, 0.12, 0.000001, 30, 0.000001, 80, 0.09];
params_ub = [9.81, 0.1, 0.1, 0.125, 0.05, -0.03, 0.09, 0.12, 0.00005, 30, 0.00005, 80, 0.09];


g = params_init(1);
l_1 = params_init(2);
l_2 = params_init(3);
m_1 = params_init(4);
m_2 = params_init(5);


c_1_0 = params_init(6);
c_2_0 = params_init(7);
I_1_0 = params_init(8);
I_2_0 = params_init(9);
b_1_0 = params_init(10);
b_2_0 = params_init(11);
k_m_0 = params_init(12);
tau_e_0 = params_init(13);


P1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
P2 = m_2 * c_2_0 * c_2_0 + I_2_0;
P3 = m_2 * l_1 * c_2_0;

g1 = (m_1 * c_1_0 + m_2 * l_1) * g;
g2 = m_2 * c_2_0 * g;

params = params_init;

OPT = optimset('MaxIter', 25); % options
f = @(x)costfun(x, y, t); % anonymous function for passing extra input arguments to the costfunction
[params_hat, fval]= lsqnonlin(f, params_init, params_lb, params_ub, OPT); % actual optimization




function e = costfun(x, y, t)
    
    assignin('base', 'params', x);              % assign bhat in workspace

    params = x
    g = params(1);
    l_1 = params(2);
    l_2 = params(3);
    m_1 = params(4);
    m_2 = params(5);

    c_1_0 = params(6);
    c_2_0 = params(7);
    I_1_0 = params(8);
    I_2_0 = params(9);
    
    
    P1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
    P2 = m_2 * c_2_0 * c_2_0 + I_2_0;
    P3 = m_2 * l_1 * c_2_0;
    
    g1 = (m_1 * c_1_0 + m_2 * l_1) * g;
    g2 = m_2 * c_2_0 * g;
    ym = sim('nonlinear_model');
    
    ym = [ym.nonlinearSim(:, 1) ym.nonlinearSim(:, 2)];
    
    ym = detrend(ym);
    
    % e = y(:, 1) - ym(:, 1);                               % residual (error)
    e = (y - ym(:, 2)');                               % residual (error)
%     e = y - ym;
%     ym(:, 2)'

%     figure(3); stairs(t, [y(:, 1) ym(:, 1)]); 
%     xlabel("t"); ylabel("radian")
%     title("real-time comparison")
    figure(4); stairs(t, [y ym(:, 2)]); 
    xlabel("t"); ylabel("radian")
    title("real-time comparison")

end