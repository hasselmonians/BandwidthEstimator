function [loglikelihoods, correlation] = kernelCore(self, bandwidths, signal)

  % performs the core computation in the MLE/CV algorithm for determining an ideal bandwidth parameter
  % for kernel smoothing a spike train, developed by Prerau & Eden 2011.
  % requires a vector of bandwidths (each element must be scalar and odd)
  % returns the log-likelihoods for each bandwidth
  % if a signal is also provided, computes the cross-correlation
  % between the signal and the smoothed spike train

  % Allocate mean square error
  loglikelihoods=zeros(1,length(bandwidths));
  correlation=zeros(1,length(bandwidths));

  dt = 1 / self.Fs;

  %Loop through kernel sizes, do a leave one out filter, and find loglikelihoods
  if nargin > 2
    if self.parallel
      parfor wn=1:length(bandwidths)
          %Set window size
          if ~mod(bandwidths(wn),2)
              bandwidths(wn)=bandwidths(wn)+1;
          end
          w=bandwidths(wn);

          % set center point to zero for leave one out filter
          k       = vectorise(self.kernel(w))';
          mid     = (w-1)/2+1;
          k(mid)  = 0;
          % normalize the notch kernel
          k       = k/sum(k);

          %Perform leave one out convolution
          l1o = self.kconv(k);

          %Fix log(0) problem
          l1o(~l1o)=1e-5;

          %Calculate the likelihood
          loglikelihoods(wn)=sum(-l1o'*dt+self.spikeTrain.*log(l1o')+self.spikeTrain*log(dt)-log(factorial(self.spikeTrain)));

          % calculate the cross-correlation
          correlation(wn) = log(max(xcorr(zscore(signal), zscore(self.spikeTrain))));

      end % wn
    else
      for wn=1:length(bandwidths)
          %Set window size
          if ~mod(bandwidths(wn),2)
              bandwidths(wn)=bandwidths(wn)+1;
          end
          w=bandwidths(wn);

          % set center point to zero for leave one out filter
          k       = vectorise(self.kernel(w));
          mid     = (w-1)/2+1;
          k(mid)  = 0;
          % normalize the notch kernel
          k       = k/sum(k);

          %Perform leave one out convolution
          l1o = self.kconv(k);

          %Fix log(0) problem
          l1o(~l1o)=1e-5;

          %Calculate the likelihood
          loglikelihoods(wn)=sum(-l1o'*dt+self.spikeTrain.*log(l1o')+self.spikeTrain*log(dt)-log(factorial(self.spikeTrain)));

          % calculate the cross-correlation
          correlation(wn) = corr(zscore(signal), zscore(self.spikeTrain))));
          textbar(wn, length(bandwidths))
      end % wn
    end % parallel
  else
    if self.parallel
      parfor wn=1:length(bandwidths)
          %Set window size
          if ~mod(bandwidths(wn),2)
              bandwidths(wn)=bandwidths(wn)+1;
          end
          w=bandwidths(wn);

          % set center point to zero for leave one out filter
          k       = vectorise(self.kernel(w))';
          mid     = (w-1)/2+1;
          k(mid)  = 0;
          % normalize the notch kernel
          k       = k/sum(k);

          %Perform leave one out convolution
          l1o = self.kconv(k);

          %Fix log(0) problem
          l1o(~l1o)=1e-5;

          %Calculate the likelihood
          loglikelihoods(wn)=sum(-l1o'*dt+self.spikeTrain.*log(l1o')+self.spikeTrain*log(dt)-log(factorial(self.spikeTrain)));
      end % wn
    else
      for wn=1:length(bandwidths)
          %Set window size
          if ~mod(bandwidths(wn),2)
              bandwidths(wn)=bandwidths(wn)+1;
          end
          w=bandwidths(wn);

          % set center point to zero for leave one out filter
          k       = vectorise(self.kernel(w));
          mid     = (w-1)/2+1;
          k(mid)  = 0;
          % normalize the notch kernel
          k       = k/sum(k);

          %Perform leave one out convolution
          l1o = self.kconv(k);

          %Fix log(0) problem
          l1o(~l1o)=1e-5;

          %Calculate the likelihood
          loglikelihoods(wn)=sum(-l1o'*dt+self.spikeTrain.*log(l1o')+self.spikeTrain*log(dt)-log(factorial(self.spikeTrain)));

          textbar(wn, length(bandwidths))
      end % wn
    end % parallel
  end % signal

end % function
