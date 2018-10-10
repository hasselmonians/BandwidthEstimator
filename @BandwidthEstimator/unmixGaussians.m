function gmm = unmixGaussians(varargin{:})
    % fit a gaussian mixed model to data
    % this is essentially a wrapper for gmdistribution.cluster()
    % Input:
      % data: a vector of data to be unmixed
      % k: the number of gaussians to fit, defaults to 2
      % Regularization: a small scalar used to regularize the covariance matrix
      % TrialNumber: the number of models to produce, taking the best one, by log-likelihood

    p = inputParser;
    p.addRequired('data', @(x) isvector(x));
    p.addParameter('k', 2, @(x) isscalar(x) && x > 0);
    p.addParameter('Regularization', 0, @(x) isscalar(x) && x > 0);
    p.addParameter('TrialNumber', 100), @(x) isscalar(x) && x > 0;
    p.parse();

    data    = p.Results.data;
    k       = p.Results.k;
    reg     = p.Results.Regularization;
    N       = p.Results.TrialNumber;

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
