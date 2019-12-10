function p = exgaussian(x, mu, sigma, lambda)

  % produces a normalized exponentially-modified gaussian kernel\
  % https://en.wikipedia.org/wiki/Exponentially_modified_Gaussian_distribution

  %% Arguments:
  %   x: the bandwidth of the kernel, as integral values
  %     if x is a scalar, the support of the distribution is 1:x
  %       and x is called the bandwidth
  %     if x is a vector, it is taken as-is
  %   mu, sigma, and lambda are three parameters of the kernel
  %% Outputs:
  %   p is the kernel as a 1 x n vector

  assert(all(rem(x, 1) == 0), 'x must be comprised of integer values')

  if isscalar(x)
    x = 1:x;
  end

  if nargin == 1
    mu = 1;
    sigma = 1;
    lambda = 1;
  end

  % precompute some values
  a = lambda / 2;
  b = lambda * sigma * sigma;

  p = a * exp(a * (2*mu + b - 2*x)) .* erfc((mu + b - x) / (sqrt(2) * sigma));

end
