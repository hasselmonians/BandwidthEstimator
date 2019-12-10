% cost function to perform the log-likelihood maximization procedure
% using an Exponentially_modified_Gaussian_distribution kernel
% with fixed bandwidth parameter and variable kernel parameters

function objective = exGaussian_cost_function(self, params, bandwidth)

  w = bandwidth * self.Fs;

  % create the kernel
  k = corelib.vectorise(ExGaussian.exgaussian(w, params(1), params(2), params(3)))';

  % set the first point to zero for leave-one-out filtering
  k(1) = 0;

  % normalize the notch kernel
  k = k / sum(k);

  %% Perform leave-one-out convolution

  firing_rate_estimate = self.kconv(k);

  % fix log(0) problem
  firing_rate_estimate(~firing_rate_estimate) = 1e-5;

  % calculate the log-likelihood of a Poisson-distributed point-process
  dt = 1 / self.Fs;
  objective = self.loglikelihood(firing_rate_estimate);

end % function
