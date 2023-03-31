%% Get the LINEAR system

x_operating = [theta_1_Op; theta_1_d_Op; theta_2_Op; theta_2_d_Op; T_Op];

% load the jacobian:
load('../4.linearize_system/Jacobian.mat')

A = double(subs(A,[theta_1,theta_d_1,theta_2,theta_d_2,T],x_operating'));
B = double(subs(B,[theta_1,theta_d_1,theta_2,theta_d_2,T],x_operating'));

save('System_matrices','A','B','C','D','x_operating')
