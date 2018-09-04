classdef BandwidthEstimator

properties

  range       % the range of bandwidth parameters to be tested
  spikeTrain  % the spike train in time-steps
  spikeTimes  % the spike times in seconds
  Fs          % the sample frequency in Hz
  timestamps  % the time steps in s
  kernel      % the type of kernel to be used

end % properties

methods

  % constructor
  function self = BandwidthEstimator(root)
    self.timestamps   = root.ts;
    spikeTimes        = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
    spikeTrain        = BandwidthEstimator.getSpikeTrain(spikeTimes, self.timestamps);
    Fs                = root.fs_video;
    range             = 3:2:(60 * Fs);
    kernel            = 'hanning';

    self.spikeTimes   = spikeTimes;
    self.spikeTrain   = spikeTrain;
    self.Fs           = Fs;
    self.range        = range;
    self.kernel       = kernel;
  end

  % set the range to 3 : 2 : (value / best.Fs), where value is in seconds
  function self = set.range(self, value, scaled)

    if nargin < 3
      scaled = true; % should the range be scaled by the sampling rate?
    end

    if (value > 0)
      self.range = 3:2:value
    else
      error('Property value must be positive')
    end

    if (scaled == true)
      self.range = self.range / self.Fs;
    end

  end % function

end % methods

methods (Static)

  spikeTrain = getSpikeTrain(spikeTimes, timestep)
  batchFunction(filename, cellnum, outfile, test)
  result = alpha(k, tau)
  w = hanning(n)

end % static methods

end % classdef
