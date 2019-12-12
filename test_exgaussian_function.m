% sample parameter space logarithmically
% and check for failed computations (NaNs)

% number of steps to test (performs nSteps^3 computations)
nSteps = 15;
passing = false(nSteps, nSteps, nSteps);
% go from 1e-5 to 1e2
params = logspace(-5, log(2997), nSteps);


counter = 0;

for ii = 1:nSteps
  for qq = 1:nSteps
    for ww = 1:nSteps
      counter = counter + 1;
      corelib.textbar(counter, nSteps^3);
      k = ExGaussian.exgaussian(1:2997, params(1), params(2), params(3));
      passing(ii, qq, ww) = ~any(isnan(k)) | ~any(isinf(k));
    end
  end
end

disp(['Each parameter sampled ' num2str(nSteps) ' times from ' num2str(params(1)) ...
 ' to ' num2str(params(end)) '. ' num2str(sum(passing(:) == false)) ' failed computations found.'])
