function [xbeam,xpend] = measure_angles(steps, han)
   
    fugiboard('Write', han, 0, 1, [0 0])
    xbeam = zeros(1,steps);
    xpend = zeros(1,steps);
    tic;
    bt = toc;
    for X=1:steps
     if (X > 600)
          fugiboard('Write', han, 0, 0, [0 0]);
       else
           fugiboard('Write', han, 0, 1, [0 0]);
       end
        data = fugiboard('Read', han);
        xbeam(X) = data(6);
        xpend(X) = data(7);
        t = bt + (0.001 * X);
        %t = toc + 0.005;
        while (toc < t); end;
    end
    toc;
end