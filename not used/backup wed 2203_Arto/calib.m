
function [xbeam_calib, xpend_calib] = calib(xbeam, xpend, offset, slope)
    %{
    answer = inputdlg('Enter beam angle:',...
             'Sample', [1 50])
    user_val = str2num(answer{1})
    if (user_val == 0)
        disp('ok')
    end

    if (user_val == pi)
        disp("ok2")
    end
    %fugiboard('Write', h, 0, 0, [0.0 0.0]);
    % figure(1); stairs([xpos1; xpos2]'); ylabel('Position1, Position2'); legend({'theta1', 'theta2'})
    % figure(2); stairs([xpos1; xpos2]'); ylabel('Position1, Position2'); legend({'theta1', 'theta2'})
    % figure(3); stairs(xcurr); ylabel('Current');
    figure(4); stairs([xbeam; xpend]'); title('Uncalibrated angles');ylabel('Beam, Pendulum'); legend({'Beam', 'Pendulum'})
    mean_beam = mean(xbeam)
    mean_xpend = mean(xpend)
    xbeam = (pi-mean_xpend)/mean_beam*xbeam - mean_xpend;
    figure(5); stairs([xbeam; xpend]');title('Calibrated angles'); ylabel('Beam, Pendulum'); legend({'Beam', 'Pendulum'})
    % figure(5); stairs(xdigin); ylabel('DigIN');
    %}
    
    xbeam_calib = (xbeam - offset(1))*slope(1);
    xpend_calib = (xpend - offset(2))*slope(2);

end

