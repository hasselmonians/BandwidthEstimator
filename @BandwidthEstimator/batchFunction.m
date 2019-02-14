function batchFunction(index, batchname, location, outfile, test)

  %% Preamble

  if nargin < 4
    test = false;
  end

  % if test is false, do not add to the matlab path
  if ~test
    addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/RatCatcher/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/BandwidthEstimator/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools/src/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
    import CMBHOME.*
  end

  %% Read data

  [filename, cellnum] = RatCatcher.read(location, batchname, index); %

  %% Load data

  % load the root object from the specified raw data file
  % root object is the raw data from the experiment
  load(filename); % load data on cluster indicated by filename and root object is loaded
  root.cel    = cellnum; % determine cell number to look at
  root        = root.AppendKalmanVel;
  speed       = root.svel; % speed is set by scaled velocity

  %% Generate the Bandwidth Estimator
  % generate BandwidthEstimator object and determine properties within it
  best        = BandwidthEstimator(root);
  best.parallel = false;
  best.range  = 3:2:(60*best.Fs);
  best.kernel = 'hanning';

  % perform bandwidth parameter estimate with MLE/CV
  [~, kmax, ~, ~, CI, kcorr, ~] = best.cvKernel(speed);
  % best bandwidth parameter estimate given the algorithm, best confidence interval of the bandwidth paramter estimate (computed using fisher info), bandwidth parameter if you tried to find bandwidth parameter for maximum speed score
  %% Save the data

  csvwrite(outfile, [kmax, CI, kcorr]); % write and save information

end % function
