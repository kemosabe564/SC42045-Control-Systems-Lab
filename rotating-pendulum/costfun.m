function e = costfun(x, y, t)
    
    assignin('base', 'params_hat', x);              % assign bhat in workspace
    x
    U = [0 x];
%     params = x
%     [P1, P2, P3, g1, g2] = setparams(x)
    ym = sim('Copy_of_nonlinear_model', t, [], U);
    
    ym = [ym.nonlinearSim(:, 1) ym.nonlinearSim(:, 2)];
    
%     ym = detrend(ym);
    
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