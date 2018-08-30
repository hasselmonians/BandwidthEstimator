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
  best.range  = 3:2:(60*best.Fs);

  % perform bandwidth parameter estimate with MLE/CV
  [estimate, kmaxMLE, loglikelihoods, bandwidths, CI] = best.cvKernel(true);

  % perform bandwidth parameter estimate with cross-correlation
  % NOTE: This is a very inefficient way of running this. Ideally, this analysis should be part of cvKernel, so that the convolutions are only performed once. This analysis is being done here so that it can be readily eliminated if necessary.
  [estimate, kmaxCorr, logmaxcorr, corr, lag] = best.corrKernel(root.svel, true);

  % save the data
  csvwrite(outfile, [kmaxMLE*(1/best.Fs) CI kmaxCorr*(1/best.Fs)]);

end % function
