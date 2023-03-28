
function moveto(ang)

    clear x*;
    fugiboard('CloseAll');
    h=fugiboard('Open', 'pendulum1');
    h.WatchdogTimeout = 1;
    fugiboard('SetParams', h);
    fugiboard('Write', h, 0, 0, [0 0]);  % dummy write to sync interface board
    fugiboard('Write', h, 4+1, 1, [0 0]);  % get version, reset position, activate relay
    data = fugiboard('Read', h);
    model = bitshift(data(1), -4);
    version = bitand(data(1), 15);
    fprintf('FPGA setup %d,  version %d', model, version);
    fugiboard('Write', h, 0, 1, [0 0]);  % end reset
    
    %% Inititalize output data arrays
    pause(0.1); % give relay some time to act
    steps = 5000;
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

    offset = [1.185896,1.195229];
    slope = [1.208265,1.209528];
    
    %ang = (pi/180)*ang;

    [xbeam, xpend] = measure_angles(1, h);
    t = 0;
    %% Run exeperiment to get experimental output
    % Start in pi -pi/2 (right) position
    for X=1:steps 

        [xbeam, xpend] = calib(xbeam(end), xpend(end), offset, slope);
        if(abs(ang - xbeam(end)) < 0.1) 
            break;
        end
        disp(xbeam(end))
        torque = sign(ang - xbeam(end))*max(5*abs(ang - xbeam(end)), 0.05);
        disp(torque)
        fugiboard('Write', h, 0, 1, [torque 0.0]);
        data = fugiboard('Read', h);

        xbeam = data(6);
        xpend = data(7);
        
        t = bt + (0.001 * X);
        %t = toc + 0.005;
        while (toc < t); end
    end
    toc;
    
    

end