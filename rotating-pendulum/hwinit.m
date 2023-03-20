%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DSCS FPGA interface board: init and I/O conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gains and offsets
daoutoffs = [0.00];                   % output offset
daoutgain = 1*[-6];                   % output gain

% Sensor calibration:
% adinoffs = -[0 0];
% adingain = [1 1];

load("calib_data\adin_gain.mat")
load("calib_data\adin_offs.mat")

adinoffs = [adin_offs 0 0 0 0 0];    % input offset
adingain = [adin_gain 1 1 1 1 1];     % input gain (to radians)

h = 0.01;