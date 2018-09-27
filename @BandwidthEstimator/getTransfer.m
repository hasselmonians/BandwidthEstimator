function getTransfer(self, signal, verbose)

  % computes the transfer function between the spike train and a signal
  % Arguments:
    % signal: an n x 1 vector that describes the animal speed (or similar)
    % verbose: a logical flag that describes whether extra info should be printed

  if nargin < 3
    verbose = false;
  end

  
