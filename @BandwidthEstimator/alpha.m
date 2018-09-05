function w = alpha(k, tau)
  % returns a k-point alpha function kernel (not normalized)
  % tau is the time-constant of the alpha function

  if nargin < 2
    tau = 1 + log(max(k));
  end

  if isscalar(k)
    L = 1:k;
    w = L .* exp(-L / tau);
    w = w';
    return
  end

  if isvector(k)
    w = k(:) .* exp(-k(:) / tau);
    w = w';
    return
  end
