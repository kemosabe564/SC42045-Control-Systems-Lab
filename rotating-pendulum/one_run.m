function [xpend, xbeam] = one_run()


%     close all;
%     clear x*;
    fugiboard('CloseAll');
    h=fugiboard('Open', 'pendulum1');
    h.WatchdogTimeout = 1;
    fugiboard('SetParams', h);
    fugiboard('Write', h, 0, 0, [0 0]);  % dummy write to sync interface board
    fugiboard('Write', h, 4+1, 1, [0 0]);  % get version, reset position, activate relay
    data = fugiboard('Read', h);
    model = bitshift(data(1), -4);
    version = bitand(data(1), 15);
    disp(sprintf('FPGA setup %d,  version %d', model, version));
    fugiboard('Write', h, 0, 1, [0 0]);  % end reset
    
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
    for X=1:steps

        fugiboard('Write', h, 0, 1, [1.0 0.0]);
        data = fugiboard('Read', h);
        xstat(X) = data(1);
        xreltime(X) = data(2);
        xpos1(X) = data(3);
        xpos2(X) = data(4);
        xcurr(X) = data(5);
        xbeam(X) = data(6);
        xpend(X) = data(7);
        xdigin(X) = data(8);
        t = bt + (0.001 * X);
        %t = toc + 0.005;
        while (toc < t); end;
    end

    toc;


    load("calib_data\adin_gain.mat");
    load("calib_data\adin_offs.mat");
    
    % figure(1); stairs([xpend]'); ylabel('Beam, Pendulum');
%     xpend = xpend /pi * 180;
%     xbeam = xbeam /pi * 180;    
%     xpend = (xpend - adin_offs(2)) / adin_gain(2);
%     xbeam = (xbeam - adin_offs(1)) / adin_gain(1);
%     xpend = (xpend - 60) / 0.84 - 21;
%     xbeam = (xbeam - 69) / 0.81;



    figure(3); stairs([xbeam; xpend]'); ylabel('Beam, Pendulum');
    sum(xbeam)/steps
    sum(xpend)/steps
end