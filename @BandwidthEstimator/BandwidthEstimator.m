classdef BandwidthEstimator

properties

  range       % the range of bandwidth parameters to be tested
  spikeTrain  % the spike train in time-steps
  spikeTimes  % the spike times in seconds
  Fs          % the sample frequency in Hz
  timestamps  % the time steps in s

end % properties

methods

  % constructor
  function self = BandwidthEstimator(root)
    self.timestamps   = root.ts;
    spikeTimes        = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
    spikeTrain        = BandwidthEstimator.getSpikeTrain(spikeTimes, self.timestamps);
    Fs                = root.fs_video;
    range             = 3:2:(120 * Fs);

    self.spikeTimes   = spikeTimes;
    self.spikeTrain   = spikeTrain;
    self.Fs           = Fs;
    self.range        = range;
  end

end % methods

methods (Static)

  spikeTrain = getSpikeTrain(spikeTimes, timestep)
  batchFunction(filename, cellnum, outfile, test)

end % static methods

end % classdef
