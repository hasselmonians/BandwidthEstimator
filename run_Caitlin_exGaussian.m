r             = RatCatcher;
r.localpath   = '/mnt/hasselmogrp/hoyland/BandwidthEstimator/cluster';
r.remotepath  = '/projectnb/hasselmogrp/hoyland/BandwidthEstimator/cluster';
r.protocol    = 'ExGaussian';
r.project     = 'hasselmogrp';
r.expID       = {'Caitlin', 'A'; 'Caitlin', 'B'; 'Caitlin', 'C'; 'Caitlin', 'D'; 'Caitlin', 'E'};
r.verbose     = true;

return

% batch files
r = r.batchify;

% NOTE: run the 'qsub' command on the cluster now (see output in MATLAB command prompt)

return

% NOTE: once the cluster finishes, run the following commands

% gather files
r = r.validate;
dataTable = r.gather;
dataTable = r.stitch(dataTable);
