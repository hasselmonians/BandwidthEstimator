function batchFunction(filename, cellnum, outfile, test)

  if nargin < 4
    test = false;
  end

  % preamble
  if ~test
    addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/RatCatcher/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/BandwidthEstimator/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools/src/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
    import CMBHOME.*
  end

  % acquire data using function arguments
  load(filename);
  root.cel = cellnum;

  % generate the Bandwidth Estimator
  best        = BandwidthEstimator(root);
  best.range  = 3:2:(120*best.Fs);

  % perform bandwidth parameter estimate
  [estimate, kmax, loglikelihoods, bandwidths, CI] = best.cvKernel(true);

  % save the data
  csvwrite(outfile, [kmax*(1/best.Fs) CI]);

end % function
