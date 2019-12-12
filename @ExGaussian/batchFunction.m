%% Optimize an exponential-gaussian kernel for use in bandwidth estimation

function batchFunction(index, location, batchname, outfile, test)

  %% Preamble

  if nargin < 4
    test = false;
  end

  % if test is false, do not add to the matlab path
  if ~test
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/MLE-time-course/'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/RatCatcher/'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/BandwidthEstimator/'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/srinivas.gs_mtools'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/CMBHOME/'))
    import CMBHOME.*
  end

  %% Read data

  [filename, cellnum] = RatCatcher.read(index, location, batchname);

  %% Load data

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
  bandwidth = 100; % s TODO: see if this is sufficient?
  cost_fcn = @(params) best.exGaussian_cost_function(params, bandwidth);

  % lower and upper bounds
  lb = 1e-5 * ones(3, 1); % NOTE: don't use 0 due to arithmetic errors
  ub = 10 * ones(3, 1); % TODO: see if this is sufficient?

  % perform particle swarm optimization
  [params, fval, exitflag, output] = particleswarm(cost_fcn, 3, lb, ub, options);

  %% Save the parameter results

  writematrix([params(:), fval], outfile);

end % function
