%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   CVKERNEL.M
%                         � Michael J. Prerau, Ph.D. 2011
%
%   This code is derived from the algorithm in:
%   Prerau M.J., Eden U.T.
%   "A General Likelihood Framework for Characterizing the Time Course of Neural Activity",
%   Journal of Neuroscience, 2011
%
%   Performs hanning kernel smoothing using cross validation on the
%   kernel smoother used on spiking
%
%   OUTPUTS:
%       estimate is the estimate of the nonparametric regression/rate
%       kmax is the bandwidth with the maximum likelihood
%       loglikelihoods is a vector of log-likelihood values for each kernel
%           bandwidth
%       bandwidths is a 1xV vector number of dt sized time bins used for the bandwith
%           at each iteration of the cross-validation
%       CI is a 1x2 vector of estimated 95% confidence bounds from the Fisher
%           information on the bandwidth size
%
%   EXAMPLE:
%       Run "cvexample.m" for an example of the cross-validated kernel
%       smoother used on spiking data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [estimate, kmax, loglikelihoods, bandwidths, CI] = cvKernel(self, parallel)

  range       = self.range;
  spikeTrain  = self.spikeTrain;
  Fs          = self.Fs;
  dt          = 1 / Fs;
  kernel      = self.kernel;

  if ~any(spikeTrain)
      estimate=zeros(1,length(spikeTrain));
      kmax=-1;
      loglikelihoods=[];
      bandwidths=[];
      CI=[];
      return;
  end

  if nargin < 2
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

  %Allocate mean square error
  loglikelihoods=zeros(1,length(bandwidths));

  %Loop through kernel sizes, do a leave one out filter, and find loglikelihoods
  if parallel
    parfor wn=1:length(bandwidths)
        %Set window size
        if ~mod(bandwidths(wn),2)
            bandwidths(wn)=bandwidths(wn)+1;
        end
        w=bandwidths(wn);

        % set center point to zero for leave one out filter
        k       = vectorise(kernel(w));
        mid     = (w-1)/2+1;
        k(mid)  = 0;
        % normalize the notch kernel
        k       = k/sum(k);

        %Perform leave one out convolution
        l1o = self.kconv(k);

        %Fix log(0) problem
        l1o(~l1o)=1e-5;

        %Calculate the likelihood
        loglikelihoods(wn)=sum(-l1o*dt+spikeTrain.*log(l1o)+spikeTrain*log(dt)-log(factorial(spikeTrain)));
    end % wn
  else
    for wn=1:length(bandwidths)
        %Set window size
        if ~mod(bandwidths(wn),2)
            bandwidths(wn)=bandwidths(wn)+1;
        end
        w=bandwidths(wn);

        % set center point to zero for leave one out filter
        k       = vectorise(kernel(w));
        mid     = (w-1)/2+1;
        k(mid)  = 0;
        % normalize the notch kernel
        k       = k/sum(k);

        %Perform leave one out convolution
        l1o = self.kconv(k);

        %Fix log(0) problem
        l1o(~l1o)=1e-5;

        %Calculate the likelihood
        loglikelihoods(wn)=sum(-l1o*dt+spikeTrain.*log(l1o)+spikeTrain*log(dt)-log(factorial(spikeTrain)));

        textbar(wn, length(bandwidths))
    end % wn
  end % parallel

  %Calculate the maximum likelihood bandwidth
  [~, ki]=max(loglikelihoods);
  kmax=bandwidths(ki);

  %Fix last bandwidth
  if (ki==length(loglikelihoods)) || (ki==1)
      ki=length(loglikelihoods)-1;
      kmax=bandwidths(end);
  end

  %Calculate confidence bounds using Fisher information
  a=loglikelihoods(ki-1);
  b=loglikelihoods(ki);
  c=loglikelihoods(ki+1);
  pstd=sqrt(-1/((c+a-2*b)/(dt^2)));

  CI(1)=kmax*dt-2*pstd;
  CI(2)=kmax*dt+2*pstd;

  %Calculate the full convolution with the best kernel
  if kmax<length(loglikelihoods)
      k=hanning(kmax)/sum(hanning(kmax));
      estimate = self.kconv(k);
  else
      estimate=ones(1,length(spikeTrain))*(sum(spikeTrain)/(dt*length(spikeTrain)));
  end

end % function
