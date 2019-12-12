% cost function to perform the log-likelihood maximization procedure
% using an Exponentially_modified_Gaussian_distribution kernel
% with fixed bandwidth parameter and variable kernel parameters

%% Arguments:
%   self: the BandwidthEstimator object
%   params: a 3-vector of parameter values (mu, sigma, lambda)
%   w: the bandwidth parameter; must be a positive, odd integer

function objective = exGaussian_cost_function(self, params, w)

  % create the kernel
  k = corelib.vectorise(ExGaussian.exgaussian(w, params(1), params(2), params(3)))';

  % set the first point to zero for leave-one-out filtering
  k(1) = 0;

  % normalize the notch kernel
  k2 = k / sum(k);

  % check to make sure that the kernel is valid
  if any(isnan(k2))
    corelib.verb(self.verbosity, 'BandwidthEstimator::exGaussian_cost_function', 'kernel is not valid')
    objective = 0;
    return
  end

  %% Perform leave-one-out convolution

  firing_rate_estimate = self.kconv(k2);

  % fix log(0) problem
  firing_rate_estimate(~firing_rate_estimate) = 1e-5;

  % calculate the log-likelihood of a Poisson-distributed point-process
  dt = 1 / self.Fs;
  objective = self.loglikelihood(firing_rate_estimate);

end % function
