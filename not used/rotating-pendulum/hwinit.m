%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DSCS FPGA interface board: init and I/O conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gains and offsets
daoutoffs = [0.00];                   % output offset
daoutgain = 1*[-6];                   % output gain



load("calib_data\adin_gain.mat")
load("calib_data\adin_offs.mat")

% % Sensor calibration:
adin_offs = -[0 0];
adin_gain = [1 1];

adin_offs = [1.2028, 1.1955];
adin_gain = [1.2030, 1.2126];

adinoffs = [-adin_offs 0 0 0 0 0];    % input offset
adingain = [adin_gain 1 1 1 1 1];     % input gain (to radians)

h = 0.001;

theta_1_0 = pi;
theta_2_0 = 0;


