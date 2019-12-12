r             = RatCatcher;
r.localpath   = '/mnt/hasselmogrp/ahoyland/BandwidthEstimator/cluster';
r.remotepath  = '/projectnb/hasselmogrp/ahoyland/BandwidthEstimator/cluster';
r.protocol    = 'ExGaussian';
r.project     = 'hasselmogrp';
r.expID       = {'Caitlin', 'A'; 'Caitlin', 'B'; 'Caitlin', 'C'; 'Caitlin', 'D'; 'Caitlin', 'E'};
r.verbose     = true;

index         = 1;
location      = '/mnt/hasselmogrp/ahoyland/BandwidthEstimator/cluster/';
batchname     = 'Caitlin-A-ExGaussian';
outfile       = '~/code/BandwidthEstimator/test.csv';

[filename, cellnum] = RatCatcher.read(index, location, batchname);
filename      = strrep(filename, 'projectnb', 'mnt');

% load the root object from the specified raw data file
load(filename);
root.cel = cellnum;
root = root.AppendKalmanVel;
speed = root.svel;

%% Generate the Bandwidth Estimator

best = BandwidthEstimator(root);
best.parallel = true;

%% Perform particle swarm optimization

% generate the options struct
options = optimoptions('particleswarm', ...
          'Display', 'off', ...
          'UseParallel', best.parallel);

% generate the cost function
bandwidth = round(100 * best.Fs); % s TODO: see if this is sufficient?
if rem(bandwidth, 2) == 0
  bandwidth = bandwidth + 1;
end

cost_fcn = @(params) best.exGaussian_cost_function(params, 1:2:bandwidth);

% lower and upper bounds
lb = 1e-5 * ones(3, 1); % NOTE: don't use 0 due to arithmetic errors
ub = bandwidth * best.Fs * ones(3, 1); % TODO: see if this is sufficient?

% perform particle swarm optimization
[params, fval, exitflag, output] = particleswarm(cost_fcn, 3, lb, ub, options);

%% Save the parameter results

writematrix([params(:), fval], outfile)
