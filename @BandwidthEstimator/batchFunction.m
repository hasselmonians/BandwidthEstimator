function batchFunction(index, location, outfile, test)

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

  % load the entire filename file
  % this is slow, but MATLAB has clunky textread options
  filename    = lineRead([location filesep 'filenames.txt']);
  % acquire only the character vector corresponding to the indexed filename
  filename    = filename{index};
  % acquire the cell number using similarly clunky indexing
  cellnum     = csvread([location filesep 'cellnums.csv'], index-1, 0, [index-1, 0, index-1, 1]);

  %% Load data

  % load the root object from the specified raw data file
  load(filename);
  root.cel    = cellnum;
  root        = root.AppendKalmanVel;
  speed       = root.svel;

  %% Generate the Bandwidth Estimator

  best        = BandwidthEstimator(root);
  best.parallel = true; % see if this works on cluster ...
  best.range  = 3:2:(60*best.Fs);
  best.kernel = 'alpha';

  % perform bandwidth parameter estimate with MLE/CV
  [~, kmax, ~, ~, CI, kcorr, ~] = best.cvKernel(speed);

  %% Save the data

  if index == 1
    csvwrite(outfile, [kmax, CI, kcorr]);
  else
    dlmwrite(outfile, [kmax CI kcorr], 'delimiter', ',', '-append');
  end

end % function
