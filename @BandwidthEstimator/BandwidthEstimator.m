classdef BandwidthEstimator

properties

  range       % the range of bandwidth parameters to be tested
  spikeTrain  % the spike train in time-steps
  spikeTimes  % the spike times in seconds
  Fs          % the sample frequency in Hz
  timestamps  % the time steps in s
  kernel      % the type of kernel to be used
  parallel    % whether to automatically parallelize computations

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
    self.parallel     = false;
  end % function

  % set the range to 3 : 2 : (value / best.Fs), where value is in seconds
  function self = set.range(self, value)

    if isscalar(value)
      if (value > 0)
        self.range = 3:2:(value * self.Fs);
      else
        error('Property value must be positive')
      end % value > 0
    else
      self.range = value;
    end % isscalar(value)

  end % function

  % set the kernel to a function handle
  function self = set.kernel(self, value)

    % if kernel is a character vector, find the appropriate static method
    % otherwise, kernel should be a function handle

    if ischar(value)
      self.kernel   = str2func(['BandwidthEstimator.' value]);
    else
      self.kernel   = value;
    end

  end % function

  function self = set.parallel(self, value)

    % if parallel is true, try to start a parallel pool
    % if parallel is false, try to shut down parallel pool

    p = gcp('nocreate');

    if value == true & isempty(p)
      try
        parpool
        self.parallel = true;
      catch
        disp('[ERROR] could not start parallel pool')
      end
    elseif value == false
      try
        % delete(gcp('nocreate'))
        self.parallel = false;
      catch
        % disp('[ERROR] could not terminate parallel pool')
      end
    else
      % disp('[ERROR] parallel should be true or false')
    end

  end % function


end % methods

methods (Static)

  spikeTrain   = getSpikeTrain(spikeTimes, timestep)
                 batchFunction(index, location, batchname, outfile, test)
  result       = alpha(k, tau)
  w            = hanning(n)
  D            = taper(signal, ratio)
  [yvar, xvar] = histogram2(x,y,edges)
  gmm          = unmixGaussians(data, k, N, reg)

end % static methods

end % classdef
