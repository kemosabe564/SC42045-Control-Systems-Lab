%% find the poles

config = "UU";

if config == "UU"
%get poles from LQR to start with up-up
pole_pend1_start = -2.84;
pole_pend2_start = -9.82;
pole_beam1_start = -12.76;
pole_beam2_start = -32.00;
poleT_start = -406.96;

elseif config == "DU"
%get poles from LQR to start with downup
pole_pend1_start = -8.02 + 4.43i;
pole_pend2_start = -8.02 - 4.43i;
pole_beam1_start = -20.45;
pole_beam2_start = -36.38;
poleT_start = -406.80;

elseif config == "DD"
%get poles from LQR to start with downdown
pole_pend1_start = -4.57 + 5.51i;
pole_pend2_start = -4.57 - 5.51i;
pole_beam1_start = -21.45 + 6.09i;
pole_beam2_start = -21.45 - 6.09i;
poleT_start = -406.94;
end

%%
% beam
%eigenfreq 
omega_eig_beam = sqrt(pole_beam1_start*pole_beam2_start);
%dampening term
damp_beam = (pole_beam1_start+pole_beam2_start)/(2*omega_eig_beam);

%pendulum
%eigenfreq 
omega_eig_pend = sqrt(pole_pend1_start*pole_pend2_start);
%dampening term
damp_pend = (pole_pend1_start+pole_pend2_start)/(2*omega_eig_pend);

%torque
tau = -1/poleT_start;

%settling time?
tss= 4*tau;

if config == "UU"
    save('Pole_Placement_Params_UU.mat', "omega_eig_beam", "damp_beam", "omega_eig_pend", "damp_pend", "tss")
elseif config == "DU"
    save('Pole_Placement_Params_DU.mat', "omega_eig_beam", "damp_beam", "omega_eig_pend", "damp_pend", "tss")
elseif config == "DD"
    save('Pole_Placement_Params_DD.mat', "omega_eig_beam", "damp_beam", "omega_eig_pend", "damp_pend", "tss")
end
