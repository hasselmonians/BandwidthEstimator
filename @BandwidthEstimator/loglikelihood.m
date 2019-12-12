% loglikelihood
% computes the log likelihood of a non-homogeneous Poisson process
% where firing_rate_estimate is the Poisson rate
% and the Poisson process produces a given spike train
%
%% Arguments:
%   self: a BandwidthEstimator object
%   firing_rate_estimate: an estimate for the underlying firing rate
%     this is a vector probably computed by kconv
%
%% Outputs: the loglikelihood as a scalar
%
% See Also: BandwidthEstimator.kernelCore, BandwidthEstimator.cvKernel

function L = loglikelihood(self, firing_rate_estimate)

  dt = 1 / self.Fs;

  L = sum(-firing_rate_estimate' * dt + self.spikeTrain .* log(firing_rate_estimate') ...
      + self.spikeTrain * log(dt) - log(factorial(self.spikeTrain)));

end % function
