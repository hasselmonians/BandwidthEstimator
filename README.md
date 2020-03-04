# Bandwidth Estimator
A simple package that implements the maximum-likelihood leave-one-out cross-validated bandwidth parameter estimation algorithm from [Prerau & Eden 2011](https://www.ncbi.nlm.nih.gov/pubmed/21732865).

## How do I install this?
Clone the repository or download and extract the zip.

It has explicit dependencies on [mtools](https://github.com/sg-s/srinivas.gs_mtools).

`getSpikeTrain` and `getSpikeTimes` requires [CMBHOME](https://github.com/hasselmonians/CMBHOME), since they get the spike times from a `Session` object.

This package has been written to function as a protocol in the [RatCatcher](https://github.com/hasselmonians/RatCatcher) data pipeline.

## What does this do?
Firing rate is a convenient mathematical construct useful in analyzing spike trains. It's believed that firing rate (measured in number of spikes per unit time) plays an important role in neural coding. Since actual spike-timing is somewhat stochastic, determining the firing rate is often non-trivial. A [2011 paper](https://www.ncbi.nlm.nih.gov/pubmed/21732865) describes a method by which Bayesian likelihood analysis and leave-one-out cross-validation can be used to determine an optimal bandwidth parameter for use in turning point-process spike-train data into smoothed firing rate vs. time curves.

Setting up a `BandwidthEstimator` object requires a fully-fleshed out `Session` object from `CMBHOME`.

```matlab
best = BandwidthEstimator(root)
```

* `timestamps` holds the vector of time-stamps for the bins of the spike train. This property is copied from `root.ts`.
* `spikeTimes` holds the spike times from the `root` object.
* `spikeTrain` contains the result of `BandwidthEstimator.getSpikeTrain`, using the spike times and time stamps. The spike train is a binned vector containing the number of spikes in each `diff(best.timestamps)`-sized bin.
* `Fs` contains the sample rate of the video recording.
* `range` contains the bandwidth parameters over which tests should be performed. These values should be odd integers only. The default is `3:2:(60 * Fs)`.
* `kernel` holds a function handle to the kernel smoothing function used by the rest of this package. It can be set by pointing directly to a function handle (e.g. `best.kernel = @fcn`), or by a character vector describing a static method of `BandwidthEstimator` (e.g. `best.kernel = 'hanning'`). Currently, only the hanning and alpha kernels are defined in this way.
* `verbosity` determines how much info text to print to the console.

The core functionality of this package is in the `cvKernel` and `kconv` functions, written by Michael Prerau (c) 2011. These functions have been heavily modified from their original forms to be methods of the `BandwidthEstimator` class.

### Performing the Maximum Likelihood Estimate with Cross-Validation
`cvKernel` computes the maximum likelihood estimate, the bandwidth parameter associated with the MLE, the log likelihoods for the range of tested bandwidths, and the tested bandwidths themselves. It takes a spike train, the time step, and the bandwidth range to be tested, in time-steps. It defaults to 3:2:N where N is 3/2 the length of the spike train. Generally, this is much too long, and it is advisable to put limits on the range of tested bandwidths.

For example, to test bandwidths up to 60 seconds:
```matlab
best.range = 3:2:(60 * best.Fs);
[estimate, kmax, loglikelihoods, bandwidths, CI] = best.cvKernel();
```

### Performing a Single Convolution
`kconv` performs the kernel convolution. It is called within `cvKernel`. Outside of the algorithm, `kconv` functions, essentially, as a wrapper for `MATLAB`'s `conv` function that post-processes the signal to remove edge effects. It can be called as a method of the `BandwidthEstimator` object with either a scalar or vector argument. If the argument is an odd scalar integer, the convolution will use a kernel constructed using the function handle stored in the `kernel` field of the object. If the argument is a vector, the `kernel` field is ignored and the vector is treated as the kernel vector for the convolution. In either case, it relies on the fields of the object for the signal, time step, etc.

For example, to test a bandwidth of 60 seconds:
```matlab
estimate = best.kconv(60*best.Fs);
estimate = best.kconv(hanning(60*best.Fs));
```
> Note that it is generally best practice for the argument to be in units of timesteps (and thus a positive, odd, integral, scalar), since there is little guarantee that `60*best.Fs` will return an odd integer.

The `test` script will test the algorithm for you.
It uses data from the Hasselmo Lab at Boston University.
Naturally, you will need to change the paths if you want to use it directly,
but it should serve as an adequate scaffolding for using this algorithm yourself.

The `batchFunction` is used for generating batch scripts with [RatCatcher](https://github.com/hasselmonians/RatCatcher).
