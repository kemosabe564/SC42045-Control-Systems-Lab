% estimate (fine-tune) a parameter in a nonlinear Simulink model

clear all; clc;
b = .5;     % "true" parameter value
bi = 0.2;   % initial guess
x0 = [0;0]; % initial state

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% design input excitation signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = 100;    % length of experiment
h = 0.05;   % sampling interval
ts = 10;    % estimated settling time of the process
A = 1;      % amplitude of GBN
U = [h*(0:T/h)' gbn(T,ts,A,h,1)]; % input signal (first colum contains
                                  % sampling instants, second actual input signal)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data collection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim('nlsysid');     % this simulates the real system, which is affected by noise
                    % ouput data available in variable y in the workspace

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OPT = optimset('MaxIter',25); % options
f = @(x)costfun(x,U,y); % anonymous function for passing extra input arguments to the costfunction
[bhat,fval]= lsqnonlin(f,bi,-0.1,1,OPT); % actual optimization

[b bhat], fval % true and final estimated parameter, final cost