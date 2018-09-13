function D = taper(signal, ratio)
  % tapers a signal at both ends for preprocessing before taking the Fourier transform
  % *** Holger Dannenberg & Alec Hoyland, 2018
  % Arguments:
    % signal: a vector or matrix containing the signal to be tapered
    % ratio: a value between zero and one determining the tapering
      % a value of 0 means no tapering
      % 1 means the whole signal is tapered
      % tapering is two-tailed, meaning that a ratio of 0.5
      % implies that the first 25% and last 25% of the signal
      % are tapered
  % Outputs:
    % D: the tapered signal, same size as when it went in

  assert(ratio >= 0, 'ratio must be greater than or equal to zero')
  assert(ratio <= 1, 'ratio must be less than or equal to one')

  % long side first
  if size(signal, 1) < size(signal, 2)
    signal = signal';
  end

  % if signal is a matrix, iterative recursively
  if ~isvector(signal)
    D = zeros(size(signal));
    for ii = 1:size(D, 2)
      D(:, ii) = BandwidthEstimator.taper(signal(:, ii), ratio);
    end
    return
  end

  % if signal is *not* a matrix

  % compute the number of time steps to taper
  N           = floor(floor(length(signal) * ratio)) * 2;
  hN          = N/2;

  % use the welch window for the tapering
  welch       = 1 - ( ((0:N) - hN) / hN).^2;

  % scale the beginning of the signal
  D(1:hN)     = D(1:hN) .* welch(1:hN);

  % scale the end of the signal
  start = length(D) - hN + 1;
  D(start:end) = D(start:end) .* welch(hN+2:end);

end % function
