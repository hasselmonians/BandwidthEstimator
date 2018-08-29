function [spikeTrain] = getSpikeTrain(spikeTimes, timestamps)

  % accepts the spike times and a vector of timestamps and returns the binned spike train
  % the spikeTimes and timestamps must be in the same units (either time steps or units of time)

  spikeTrain = zeros(size(timestamps));
  [~,~,temp] = histcounts(spikeTimes, timestamps);
  tt = unique(temp);

  for i = 1:length(tt)
      spikeTrain(tt(i)) = sum(temp == tt(i));
  end

end % function
