r             = RatCatcher;
r.localpath   = '/mnt/hasselmogrp/ahoyland/BandwidthEstimator/cluster';
r.remotepath  = '/projectnb/hasselmogrp/ahoyland/BandwidthEstimator/cluster';
r.protocol    = 'BandwidthEstimator';
r.project     = 'hasselmogrp';
r.expID       = {'Caitlin', 'A'; 'Caitlin', 'B'; 'Caitlin', 'C'; 'Caitlin', 'D'; 'Caitlin', 'E'};
r.verbose     = true;

index         = 1;
location      = '/mnt/hasselmogrp/ahoyland/BandwidthEstimator/cluster/';
batchname     = 'Caitlin-A-ExGaussian';
outfile       = '~/code/BandwidthEstimator/test.csv';

%% Read data
[filename, cellnum] = RatCatcher.read(index, location, batchname);
filename      = strrep(filename, 'projectnb', 'mnt');

%% Load data

% load the root object from the specified raw data file
load(filename);
root.cel    = cellnum;
root        = root.AppendKalmanVel;
speed       = root.svel;

%% Generate the Bandwidth Estimator

best        = BandwidthEstimator(root);
best.parallel = false;
best.range  = 3:2:(60*best.Fs);
best.kernel = 'hanning';

% perform bandwidth parameter estimate with MLE/CV
[~, kmax, ~, ~, CI, ~, ~] = best.cvKernel();

writematrix([kmax, CI], outfile)
