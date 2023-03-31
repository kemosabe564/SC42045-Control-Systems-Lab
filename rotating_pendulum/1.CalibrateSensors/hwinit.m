%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DSCS FPGA interface board: init and I/O conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gains and offsets
daoutoffs = [0.00];                   % output offset
daoutgain = 1*[-6];                   % output gain

% % Sensor calibration:
adin_offs = -[0 0];
adin_gain = [1 1];

adinoffs = [-adin_offs 0 0 0 0 0];    % input offset
adingain = [adin_gain 1 1 1 1 1];     % input gain (to radians)

h = 0.001;

theta_1_0 = pi;
theta_2_0 = 0;


