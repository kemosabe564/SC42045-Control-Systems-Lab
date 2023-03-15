
% initialize FPGA
init_fugi

% calib
calib

% disp
adin_offs
adin_gain

save('adin_offs.mat', 'adin_offs');
save('adin_gain.mat', 'adin_gain');

% rotpentest