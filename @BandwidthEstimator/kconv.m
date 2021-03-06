%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    KCONV.M
%                         � Michael J. Prerau, Ph.D. 2011
%
%   This code is used in thethe algorithm described in:
%   Prerau M.J., Eden U.T.
%   "A General Likelihood Framework for Characterizing the Time Course of Neural Activity",
%   Journal of Neuroscience, 2011
%
%   Performs a kernel convolution removing end effects and returning a
%   result the same size as the input data
%
%       result is the 1XN result of the kernel smoother
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=kconv(self, k)

  % convolves self.spikeTrain with a kernel k
  % fixes the edges and returns a vector the same size as self.spikeTrain
  % if k is a scalar, the window is generated using self.kernel(k)
  % if k is a vector, the window is k

  data    = self.spikeTrain;
  dt      = 1 / self.Fs;
  kernel  = self.kernel;

  data    = data(:)';

  % if k is scalar, generate a vector that defines the window
  if isscalar(k)
    k       = corelib.vectorise(kernel(k))'; % k becomes the vector that defines the window
  else
    k       = corelib.vectorise(k)';
  end % otherwise, k is a vector, and will be used as the window

  % normalize k
  k       = k / sum(k);

  % require an odd length window
  w=length(k);
  if mod(w,2)==0
      error('Window must be of an odd length');
  end

  %Perform the standard convolution
  % result=conv(data,k/dt,'same');

  %Define the overlap size and window midpoint
  snip=(w-1)/2;
  mid=snip+1;

  %Fix the ends to remove the end effects
  if w<length(data)
  wval=[1:w (length(data)-w):length(data)];
  else
      wval=1:length(data);
  end

  for wsize=wval
      %Calculate data start and end, dealing with boundaries
      ds=max(wsize-snip,1);
      de=min(wsize+snip,length(data));

      %Calculate kernel start and end, dealing with boundaries
      ks=max(mid-(wsize-1),1);
      ke=min(mid+length(data)-wsize,w);

      %Calculate the leave-one out convolution
      result(wsize)=sum(data(ds:de).*k(ks:ke)/sum(k(ks:ke))/dt);
  end

end % function
