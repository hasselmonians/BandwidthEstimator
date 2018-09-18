function [stats] = fit(self, data, verbose)
  % fits the firing rate versus the speed of a cell
  % Temporally binned firing rate versus running speed: Firing rate was fit using a maximum likelihood estimator. The instantaneous running speed was taken from the Kalman velocity, based on displacement in location between each recorded tracking sample (Fyhn et al, 2004). The number of spikes occurring in each video frame (30Hz) was counted. Only frames with instantaneous velocity greater than 2 cm sec-1 and less than the 95th percentile of running speeds were considered, in order to avoid under sampled regions. The firing rate parameter (lambda) was assumed to follow one of two functions of running speed:

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

  %% Process the Inputs

  if class(data) == 'CMBHOME.Session'
    % assume is a Session object that matches the BandwidthEstimator object
    speed = data.svel;
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

  % only consider speed above 0 cm/sec and less than the 95% to avoid undersampled regions
  % we include the lower bound to incorporate saturating exponential models with
  speed_bin     = vectorise(0:1:quantile(speed, 0.95))'; % cm/s

  % bin index into which that speed value fits
  % e.g. if speed(i) is in speed_bin(j) then speed_idx(i) = j
  speed_idx     = discretize(speed, speed_bin); % unitless

  % number of spikes total that occur during a given speed bin (and associated error)
  for ii = 1:length(speed_bin)
    tstep_idx   = find(speed_idx == speed_bin(ii));
    count(ii)   = sum(self.spikeTrain(tstep_idx));
    stddev(ii)  = std(self.spikeTrain(tstep_idx));
  end

  % number of frames in each bin
  occupancy     = histcounts(speed, speed_bin);

  % firing rate in each speed bin
  % this is the total number of spikes per speed bin divided by the number of time-bins times the sample rate
  frequency     = count(1:end-1) ./ (occupancy / self.Fs);
  freq_std      = stddev(1:end-1) ./ (occupancy / self.Fs);

  % average firing rate
  % calculates the duration of the session by time frames with small differences
  freq_avg      = numel(self.spikeTimes) / (sum(abs(diff(self.timestamps) - 1/self.Fs) < 1/self.Fs) / self.Fs);

  % number of spikes in each frame
  count2        = histcounts(self.spikeTimes, self.timestamps);

  % housekeeping
  % snip off ends to remove zeros
  T             = table(speed_bin(1:end-2)', frequency(1:end-1)', 'VariableNames', {'SpeedBins', 'FiringRate'});

  %% Linear Fit

  if verbose
    disp('[INFO] computing the linear fit')
  end

  % linear fit of binned data
  % using Wilkinson notation: firing rate ~ 1 + speed
  linear        = fitlm(T, 'linear');
  % quadratic fit of binned data
  % using Wilkinson notation: firing rate ~ 1 + speed + speed^2
  quadra        = fitlm(T, 'quadratic');

  if verbose
    disp(linear)
    disp(quadra)
  end

  %% Saturating Exponential Fit

  if verbose
    disp('[INFO] computing the saturating exponential fit')
  end

  % saturating exponential fit of binned data
  modelfun      = @(b, x) b(1) - b(2) * exp(- b(3) * x(:,1));
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
  F             = num / denom;
  p             = 1 - fcdf(F, linear.NumCoefficients - satexp.NumCoefficients, linear.DFE);

  % the saturating exponential model converges to a linear mode as b(3) -> 0
  % in a second-order approximation, it converges towards a quadratic model
  % for these reasons, the null hypothesis is a linear fit
  % that is, p = NaN implies a linear fit

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
  stats.quadra  = quadra;
  stats.F       = F;
  stats.p       = p;
  stats.aic     = aic;
  stats.bic     = bic;
  stats.frequency = frequency;
  stats.freq_std = freq_std;
  stats.freq_avg = freq_avg;
  stats.speed_bin = speed_bin;

end % function
