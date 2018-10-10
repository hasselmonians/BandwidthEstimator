function gmm = unmixGaussians(data, k, N, reg)
    % fit a gaussian mixed model to data
    % this is essentially a wrapper for gmdistribution.cluster()
    % Input:
      % data: a vector of data to be unmixed
      % k: the number of gaussians to fit, defaults to 2
      % reg: a small scalar used to regularize the covariance matrix
      % N: the number of models to produce, taking the best one, by log-likelihood

    if nargin < 4
        reg = 0;
    end

    if nargin < 3
        N = 100;
    end

    if nargin < 2
        k = 2;
    end

    % fit a gaussian mixed model to the data
    gmm     = fitgmdist(data, k, 'Regularization', reg);

    % fit N models, taking the best one
    for ii = 1:N
        try
            gmm0 = fitgmdist(data, k, 'Regularization', reg);
            % pick the best model by negative log-likelihood
            if gmm0.NegativeLogLikelihood > gmm.NegativeLogLikelihood
                gmm = gmm0;
            end
        catch
        end
    end % ii

end % function
