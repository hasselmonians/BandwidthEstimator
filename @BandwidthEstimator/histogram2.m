function [yvar, xvar] = histogram2(x,y,edges)
  % gets histogram for data y(x) with y1 = y(x1), y2 = y(x2), ... , yend =
  % y(xend) for bins of vector x determined by vector edges.
  % edges can be a 2x1 vector, or a bin width, or a character vector describing a binning method used in histcounts

  assert(length(y) == length(x), 'length of x and y must be the same')

  if nargin == 2
    [~, edges] = histcounts(x);
  elseif ischar(edges)
    [~, edges] = histcounts(x, 'BinMethod', edges);
  elseif isscalar(edges)
    edges = [0 edges];
  else
    % edges should be at least a 2x1 vector in length
    % do nothing
  end

  % determine the bin width as the difference between the edges
  bin_width = edges(2)-edges(1); % bin_width

  % group values from vector x into bins
  [xbins] = discretize(x,edges);
  x_min = min(xbins);
  x_max = max(xbins);
  if isnan(x_min)
      yvar = nan;
      xvar = nan;
      return
  end

  % if xbins or y are not column vectors, transpose vectors to make them
  % column vectors
  if size(xbins,1) < size(xbins,2)
      xbins = xbins';
  end
  if size(y,1) < size(y,2)
      y = y';
  end

  % remove nan values
  y(isnan(xbins)) = [];
  xbins(isnan(xbins)) = [];

  % get histogram
  histcounts_cel = cell(x_max-x_min+1,1); % preallocate variable
  for i = x_min:x_max
      histcounts_cel{i} = y(xbins==i); % stores spiking rate values per binned speed values
  end
  % calculate mean value per speed bin
  yvar = nan(length(histcounts_cel),1); % preallocate variable
  for i = 1:length(histcounts_cel)
      yvar(i) = nanmean(histcounts_cel{i});
  end
  % delete empty speed bins smaller than xmin
  yvar(1:x_min-1) = [];
  % create vector with speed bins matching to yvar
  % vector
  xvar = linspace(edges(x_min),edges(x_max),length(yvar));
  xvar = xvar + bin_width/2; % adjust xvar values to display the middle of the speed bin
  % remove non-existing speed bins and corresponding values in
  % yvar. non-existing speed bins are speed bins where
  % the corresponding values in yvar are nan values.
  xvar(isnan(yvar)) = [];
  yvar(isnan(yvar)) = [];

end % function
