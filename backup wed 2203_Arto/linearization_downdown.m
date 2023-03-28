% NOTE: Run white-box first to get accurate values for parameters used in
% Simulink model
l1 = 0.1; l2 = 0.1;
m1 = 0.125; m2 = 0.0493;
I1 = 0.0888; I2 = 9.5326e-05;
b1 = 7.7210; b2 = 2.337424773114795e-05;
c1 = -0.0320; c2 = 0.053232610186913;
km = 53.049364666321930; tau_e = 0.014999999999983;
h = 0.001;

% Obtained already placed analysis points
io = getlinio('dbl_pendulum_linearized_dd');

% Linearize model around [0, 0] operating point
linsys = linearize('dbl_pendulum_linearized_dd',io);

% Obtain state-space representation and matrices
A = linsys.A;
B = linsys.B;
C = linsys.C;
D = linsys.D;

linsys.statename  % {th1, th2, T, th1d, th2d}
linsys.outputname % {th1, th2}
linsys.inputname  % u

% check observability
Obs = obsv(linsys);
Obsrank = rank(Obs);
if Obsrank ~= length(A)
    fprintf('System not fully observable!\n')
    unobsv = length(A) - Obsrank;
else
    fprintf('System fully observable!\n')
end

% check controllability
Ctr = ctrb(linsys);
Ctrrank = rank(Ctr);
if Ctrrank ~= length(A)
    fprintf('System not fully controllable!\n')
    unco = length(A) - Ctrrank;
else
    fprintf('System fully controllable!\n')
end

% Convert to discrete, where dt is the discrete time-step (in seconds)
h = 0.001;
discretized_sys = c2d(linsys,h);
A_discr = discretized_sys.A;
B_discr = discretized_sys.B;
C_discr = discretized_sys.C;
D_discr = discretized_sys.D;



p= [-1,-2,-3,-4,-5];
K = place(A,B,p);
p_obs = 2*[-5,-10,-15,-20,-25];
%p_obs = [-10,-20];
L = place(A',C',p_obs);