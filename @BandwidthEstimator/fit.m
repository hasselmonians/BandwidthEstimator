function [stats] = fit(self, data, verbose)
  % fits the firing rate versus the speed of a cell
  % Temporally binned firing rate versus running speed: Firing rate was fit using a maximum likelihood estimator. The instantaneous running speed was taken from the Kalman velocity, based on displacement in location between each recorded tracking sample (Fyhn et al, 2004). The number of spikes occurring in each video frame (30Hz) was counted. Only frames with instantaneous velocity greater than 2 cm sec-1 and less than the 95th percentile of running speeds were considered, in order to avoid under sampled regions. The firing rate parameter (lambda) was assumed to follow one of two functions of running speed:
  %
  % Linear: lambda(dach) = b(dach) *v + a(dach)
  %
  % Saturating exponential: lambda(dach) = k(dach) -m(dach)*e^(-q(dach)*v)

  % Arguments:
    % self: the BandwidthEstimator object
    % data: data can take many forms, and is processed as thus
      % if data is a class object, it is expected to be a fully-processed Session object that matches the BandwidthEstimator object
      % if data is a struct, it should have a field named 'speed', 'spd', 'vel', or 'velocity'
      % if data is a vector, it is expected to be the signal to which the firing rate should be fit
  % Outputs:
    % stats: a struct full of statistics

    if nargin < 3
      verbose = false;
    end

  % process the inputs
  if class(data) == 'CMBHOME.Session'
    % assume is a Session object that matches the BandwidthEstimator object
    speed = data.vel;
    if verbose
      disp('[INFO] interpreted ''data'' as a ''CMBHOME.Session'' object')
    end
  elseif class(data) == 'double' && length(data) > 1
    % assume is the speed vector
    speed = data;
    if verbose
      disp('[INFO] interpreted ''data'' as a ''vector'' ')
    end
  elseif isstruct(data)
    % try to find a reasonable field which contains the speed and use that
    names = fieldnames(data)
    index = find(contains(names, {'speed', 'spd', 'vel', 'velocity'}, 'IgnoreCase', true));
    try
      speed = data.(names{index(1)});
      if verbose
        disp(['[INFO] interpreted ''data'' as a ''struct'' with field '' ' names{index(1)} ' '' '])
      end
    catch
      disp('[ERROR] I don''t recognize any of the fields in ''data''')
      stats = [];
      return
    end
  else
    disp('[ERROR] I don''t know what to do with these argument types')
    stats = [];
    return
  end

  assert(length(speed) == length(self.spikeTrain), 'speed and spike train must have the same length')

  % only consider speed above 2 cm/sec and less than the 95% to avoid undersampled regions
  speed_bin     = vectorise(2:1:quantile(speed, 0.95))';
  % bin index into which that speed value fits
  % e.g. if speed(i) is in speed_bin(j) then speed_idx(i) = j
  speed_idx     = discretize(speed, speed_bin);

  % number of spikes total that occur during a given speed bin
  for ii = 1:length(speed_bin)-1
    tstep_idx   = find(speed_idx == speed_bin(ii));
    count(ii)   = sum(self.spikeTrain(tstep_idx));
    stddev(ii)  = std(self.spikeTrain(tstep_idx));
  end

  % number of frames in each bin
  occupancy     = histcounts(speed, speed_bin);

  % firing rate in each speed bin
  % this is the total number of spikes per speed bin divided by the number of time-bins times the sample rate
  frequency     = count ./ (occupancy / self.Fs);
  freq_std      = stddev ./ (occupancy / self.Fs);

  % average firing rate
  % calculates the duration of the session by time frames with small differences
  freq_avg      = numel(self.spikeTimes) / (sum(abs(diff(self.timestamps) - 1/self.Fs) < 1/self.Fs) / self.Fs);

  % number of spikes in each frame
  count2        = histcounts(self.spikeTimes, self.timestamps);

  % housekeeping
  speed_bin     = speed_bin(1:end-1); % snip off end to fix off-by-one error
  T             = table(speed_bin(1:end-1)', frequency(1:end-1)', 'VariableNames', {'SpeedBins', 'FiringRate'});
  warning off curvefit:fit:noStartPoint;

  %% Linear Fit

  if verbose
    disp('[INFO] computing the linear fit')
  end

  % linear fit of binned data using fitlm
  linear        = fitlm(T, 'linear');
  quadra        = fitlm(T, 'quadratic');

  if verbose
    disp(linear)
  end

  %% Saturating Exponential Fit

  if verbose
    disp('[INFO] computing the saturating exponential fit')
  end

  % saturating exponential fit of binned data using fitnlm
  modelfun      = @(b, x) b(1) + b(2) * exp(- b(3) * x(:,1));
  % defaults to constant model: b(1) + b(2)
  beta0         = [linear.Coefficients.Estimate(1), linear.Coefficients.Estimate(2), 0];
  satexp        = fitnlm(T, modelfun, beta0);

  if verbose
    disp(satexp);
  end

  %% Linear Fit vs. Exponential Fit

  if verbose
    disp('[INFO] computing the linear vs. exponential statistics')
  end

  % compare both models using the F-test and p-value
  num           = (satexp.SSE - linear.SSE) / (linear.NumCoefficients - satexp.NumCoefficients);
  denom         = linear.SSE / linear.DFE;
  F             = numerator / denominator;
  p             = 1 - fcdf(F, linear.NumCoefficients - satexp.NumCoefficients, linear.DFE);

  % compute the Akaike and Bayesian inference criteria
  % lower values mean better inferential power
  % linear model is aic(:, 1), saturating exponential model is aic(:, 2)
  [aic, bic]    = aicbic([linear.LogLikelihood, satexp.LogLikelihood], [2, 3], length(speed_bin(1:end-1)));

  % check significance of

  %% Package Output

  if verbose
    disp('[INFO] packaging output')
  end

  stats         = struct;
  stats.linear  = linear;
  stats.satexp  = satexp;
  stats.linexp  = linexp;
  stats.F       = F;
  stats.p       = p;
  stats.aic     = aic;
  stats.bic     = bic;
  stats.frequency = frequency;
  stats.freq_std = freq_std;
  stats.freq_avg = freq_avg;
  stats.speed_bin = speed_bin;

end % function
