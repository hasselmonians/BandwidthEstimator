function batchFunction_parallel(bin_id, bin_total, location, batchname, outfile, test)

    if ~test
        % add the propery directories to the MATLAB path
        addpath(genpath('/projectnb/hasselmogrp/ahoyland/MLE-time-course/'))
        addpath(genpath('/projectnb/hasselmogrp/ahoyland/RatCatcher/'))
        addpath(genpath('/projectnb/hasselmogrp/ahoyland/BandwidthEstimator/'))
        addpath(genpath('/projectnb/hasselmogrp/ahoyland/srinivas.gs_mtools'))
        addpath(genpath('/projectnb/hasselmogrp/ahoyland/CMBHOME/'))
        import CMBHOME.*
    end

    % get the start and end times for the binned jobs
    [bin_start, bin_finish] = RatCatcher.getParallelOptions(bin_id, bin_total, location, batchname);

    % set up 'local' parallel pool cluster
    pc = parcluster('local');

    % discover the number of available cores assigned by SGE
    nCores = str2num(getenv('NSLOTS'));

    % set up directory for temporary parallel pool files
    parpool_tmpdir = ['~/.matlab/local_cluster_jobs/ratcatcher/ratcatcher_' num2str(bin_id)];
    mkdir(parpool_tmpdir);
    pc.JobStorageLocation = parpool_tmpdir;

    % start parallel pool
    parpool(pc, nCores);

    %% Begin main loop

    parfor ii = bin_start:bin_finish

        % set up dummy outfile variable
        outfile_pc = [outfile, '-', num2str(ii) '.csv'];

        %% Read data

        % the 'filename' is the path to your data file on the cluster
        % the 'filecode' is the associated numeric code (if any)
        [filename, cellnum] = RatCatcher.read(ii, location, batchname);

        % load the root object from the specified raw data file
        this = load(filename);
        root = this.root;
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

        writematrix([kmax, CI, kcorr], outfile);

    end % parfor

end % function
