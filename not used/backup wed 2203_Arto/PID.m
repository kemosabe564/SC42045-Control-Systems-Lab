%% Inititalize output data arrays
pause(0.1); % give relay some time to act
steps = 10000;
xstat = zeros(1,steps);
xreltime = zeros(1,steps);
xpos1 = zeros(1,steps);
xpos2 = zeros(1,steps);
xcurr = zeros(1,steps);
xbeam = zeros(1,steps);
xpend = zeros(1,steps);
xdigin = zeros(1,steps);
tic;
bt = toc;
h = 0.001;
%% Run exeperiment to get experimental output
offset = [1.185896,1.195229];
slope = [1.208265,1.209528];

tm = sim('pendulum_controller_dd.slx');