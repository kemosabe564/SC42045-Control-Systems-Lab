
%TODO: pos1

% we could use the following to create the effect of stop and continue
disp("place the beam/pend to 180/0 and press Enter")
waitforbuttonpress();

steps = 100;
beam_temp_1 = 0;
pend_temp_1 = 0;
% steps = 500

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

%     if (X > 500)
%         fugiboard('Write', h, 0, 1, [0.0 0.0]);
%     else
%         fugiboard('Write', h, 0, 7, [0.0 0.0]);
%     end
    fugiboard('Write', h, 0, 1, [0.0 0.0]);
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
    
    beam_temp_1 = beam_temp_1 + data(6);
    pend_temp_1 = pend_temp_1 + data(7);
    while (toc < t); end;
end
beam_temp_1 = beam_temp_1 / steps
pend_temp_1 = pend_temp_1 / steps

toc;

%TODO: pos2
disp("place the beam/pend to 0/180 and press Enter")
waitforbuttonpress();

beam_temp_2 = 0;
pend_temp_2 = 0;

tic;
bt = toc;
for X=1:steps

%     if (X > 500)
%         fugiboard('Write', h, 0, 1, [0.0 0.0]);
%     else
%         fugiboard('Write', h, 0, 7, [0.0 0.0]);
%     end
    fugiboard('Write', h, 0, 1, [0.0 0.0]);
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
    
    beam_temp_2 = beam_temp_2 + data(6);
    pend_temp_2 = pend_temp_2 + data(7);
    while (toc < t); end;
end
beam_temp_2 = beam_temp_2 / steps
pend_temp_2 = pend_temp_2 / steps
toc;

% TODO: calib, get the gamma_0 and gamma_1
% for the beam
gamma_0_beam = beam_temp_2;
gamma_1_beam = (beam_temp_1 - beam_temp_2) / pi;

% for the pend
gamma_0_pend = pend_temp_1;
gamma_1_pend = (pend_temp_2 - pend_temp_1) / pi;

% Sensor calibration:
% adinoffs = -[0 0];
% adingain = [1 1];
adin_offs = [gamma_0_beam gamma_0_pend];
adin_gain = [gamma_1_beam gamma_1_pend];
