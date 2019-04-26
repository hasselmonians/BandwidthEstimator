function batchFunction(index, location, batchname, outfile, test)

  %% Preamble

  if nargin < 4
    test = false;
  end

  % if test is false, do not add to the matlab path
  if ~test
    addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/RatCatcher/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/BandwidthEstimator/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
    import CMBHOME.*
  end

  %% Read data

  [filename, cellnum] = RatCatcher.read(index, location, batchname);

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
  [~, kmax, ~, ~, CI, kcorr, ~] = best.cvKernel(speed);

  %% Save the data

  csvwrite(outfile, [kmax, CI, kcorr]);

end % function
