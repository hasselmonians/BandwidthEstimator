function p = exgaussian(x, mu, sigma, lambda)

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
