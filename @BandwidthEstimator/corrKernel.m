function [estimate, kmax, logmaxcorr, corr, lag] = corrKernel(self, signal, parallel)

  range       = self.range;
  spikeTrain  = self.spikeTrain;
  Fs          = self.Fs;
  dt          = 1 / Fs;

  if ~any(spikeTrain)
      estimate=zeros(1,length(spikeTrain));
      kmax=-1;
      logmaxcorr=[];
      bandwidths=[];
      CI=[];
      return;
  end

  if nargin < 3
    parallel = false;
  end

  %Make sure spikeTrain isn't logical
  if ~isa(spikeTrain,'double')
      spikeTrain=double(spikeTrain);
  end

  spikeTrain=spikeTrain(:)';


  %Get spikeTrain length
  N=length(spikeTrain);
  L=round(N/2);

  %Set kernel range and adjust to make the first odd < N
  if mod(L, 2)==0
      L = L - 1;
  end

  %Set bandwidths if not specified
  if isempty(range)
    bandwidths=3:2:3*L;
  else
    bandwidths=range;
  end

  % allocate mean square error
  logmaxcorr = zeros(length(bandwidths), 1);

  % loop through kernel sizes, do a leave one out filter, and find max cross-correlation
  if parallel
    parfor wn = 1:length(bandwidths)
        % set window size
        if ~mod(bandwidths(wn), 2)
            bandwidths(wn) = bandwidths(wn) + 1;
        end

        % set up hanning filter kernel
        w = bandwidths(wn);
        k = hanning(w);
        k = k / sum (k);      % normalize

        % perform leave one out convolution
        frequency = self.kconv(k);

        % compute the cross-correlation
        [corr, lag] = xcorr(frequency, signal);
        logmaxcorr(wn) = log(max(corr));
    end % wn
  else
    for wn=1:length(bandwidths)
      % set window size
      if ~mod(bandwidths(wn), 2)
          bandwidths(wn) = bandwidths(wn) + 1;
      end

      % set up hanning filter kernel
      w = bandwidths(wn);
      k = hanning(w);
      k = k / sum (k);      % normalize

      % perform leave one out convolution
      frequency = self.kconv(k);

      % compute the cross-correlation
      [corr, lag] = xcorr(frequency, signal);
      logmaxcorr(wn) = log(max(corr));

      textbar(wn, length(bandwidths))
    end % wn
  end % parallel

  % calculate the maximum likelihood bandwidth
  [~, ki] = max(logmaxcorr);
  kmax    = bandwidths(ki);

  % fix last bandwidth
  if (ki==length(logmaxcorr)) || (ki==1)
      ki = length(logmaxcorr)-1;
      kmax = bandwidths(end);
  end

  % calculate the full convolution with the best kernel
  if kmax < length(logmaxcorr)
      k           = hanning(kmax) / sum(hanning(kmax));
      estimate    = self.kconv(k);
      [corr, lag] = xcorr(estimate, signal);
  else
      estimate    = ones(1,length(spikeTrain))*(sum(spikeTrain)/(dt*length(spikeTrain)));
      [corr, lag] = xcorr(estimate, signal);
  end

end % function
