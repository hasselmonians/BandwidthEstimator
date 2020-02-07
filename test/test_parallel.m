r = RatCatcher;

r.expID         = {'Caitlin', 'A'; 'Caitlin', 'B'};
r.remotepath    = '/projectnb/hasselmogrp/ahoyland/RatCatcher/cluster/';
r.localpath     = '/mnt/hasselmogrp/ahoyland/RatCatcher/cluster/';
r.protocol      = 'BandwidthEstimator';
r.project       = 'hasselmogrp';
r.verbose       = true;
r.mode          = 'parallel';
r.threading     = 'multi';

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

return
