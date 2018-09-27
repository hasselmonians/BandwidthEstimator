function getTransfer(self, signal, kmax, verbose, parallel)

  % computes the transfer function between the spike train and a signal
  % Arguments:
    % signal: an n x 1 vector that describes the animal speed (or similar)
    % verbose: a logical flag that describes whether extra info should be printed
    % parallel: a logical flag that describes whether the computation should be parallelized

  if nargin < 3
    kmax = [];
  end

  if nargin < 4
    verbose = false;
  end

  if nargin < 5
    parallel = false;
  end

  % compute the MLE/CV bandwidth parameter for a hanning filter
  if ~isempty(kmax)
    % if kmax was passed as an argument, use that value instead
    if verbose, disp('[INFO] computing kmax') end
    best.kernel = 'hanning';
    [~, kmax] = best.cvKernel(parallel);
  end

  % compute the transfer function using Welch's method
  % [txy,f] = tfestimate(x,y,window,noverlap,f,fs)
  [txy, f] = tfestimate(signal, best.spikeTrain, kmax, [], [], best.Fs);
