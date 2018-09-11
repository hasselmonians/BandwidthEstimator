# Bandwidth Estimator
A simple package that implements the maximum-likelihood leave-one-out cross-validated bandwidth parameter estimation algorithm from [Prerau & Eden 2011](https://www.ncbi.nlm.nih.gov/pubmed/21732865).

## How do I install this?
Clone the repository or download and extract the zip. `getSpikeTrain` and `getSpikeTimes` requires `CMBHOME`, since they get the spike times from a `Session` object.

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

The core functionality of this package is in the `cvKernel` and `kconv` functions, written by Michael Prerau (c) 2011. These functions have been heavily modified from their original forms to be methods of the `BandwidthEstimator` class.

* `cvKernel` computes the maximum likelihood estimate, the bandwidth parameter associated with the MLE, the log likelihoods for the range of tested bandwidths, and the tested bandwidths themselves. It takes a spike train, the time step, and the bandwidth range to be tested, in time-steps. It defaults to 3:2:N where N is 3/2 the length of the spike train. Generally, this is much too long, and it is advisable to put limits on the range of tested bandwidths.
* `kconv` performs the kernel convolution. It is called within `cvKernel`.
* `cvExample` is a script that demonstrates the algorithm. I doubt it works right now.

The `batchFunction` is used for generating batch scripts with [RatCatcher](https://github.com/hasselmonians/RatCatcher).
