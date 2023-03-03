function e = costfun(x,U,y)
% cost function for nonlinear parameter tuning
% x contains the candidate parameters, U is the experimental input signal
% and y is the experiemental output signal

assignin('base','bhat',x);              % assign bhat in workspace
[tm,xm,ym]=sim('nlmodel',U(:,1),[],U);  % simulate nonlinear model using current candidate parameter
                                        % the nonlinear model is built on
                                        % top of the real system, but of
                                        % course in this case there is no
                                        % noise

e = y-ym;                               % residual (error)

% you can comment the below line to speed up
figure(1); stairs(tm,[y ym]);           % intermediate fit
%pause

% NOTE: sim here is called using a backward-compatible syntax (as of R2017b):
%
%[T,X,Y] = sim('model',Timespan, Options, UT)
%
% where UT represents data to be loaded into root level input ports. In
% this case it is the input signal (first column: time instants; second
% column: input signal value at a given time instant)