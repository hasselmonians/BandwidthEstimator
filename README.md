# Bandwidth Estimator
A simple package that implements the maximum-likelihood leave-one-out cross-validated bandwidth parameter estimation algorithm from [Prerau & Eden 2011](https://www.ncbi.nlm.nih.gov/pubmed/21732865).

## How do I install this?
Clone the repository or download and extract the zip. `getSpikeTrain` and `getSpikeTimes` requires `CMBHOME`, since they get the spike times from a `Session` object.

## What does this do?
Firing rate is a convenient mathematical construct useful in analyzing spike trains. It's believed that firing rate (measured in number of spikes per unit time) plays an important role in neural coding. Since actual spike-timing is somewhat stochastic, determining the firing rate is often non-trivial. A [2011 paper](https://www.ncbi.nlm.nih.gov/pubmed/21732865) describes a method by which Bayesian likelihood analysis and leave-one-out cross-validation can be used to determine an optimal bandwidth parameter for use in turning point-process spike-train data into smoothed firing rate vs. time curves.

The following functions process the `Session` data object to acquire a binned spike train. The first argument is the `Session` object.

* `getSpikeTimes` acquires the spiketimes from a `CMBHOME` `Session` object.
* `getSpikeTrain` bins the spike times based on the time step determined by the video sampling frequency. If spike times are passed to the function as a second argument, it only bins. If not, it runs `getSpikeTimes` first to get the spike times.
* `getFiringRate` takes the spike train as a second argument and a bandwidth in number of time-steps as a third argument. It computes the Hanning kernel-smoothed firing rate estimate, given the spike train and the bandwidth parameter.

The following functions were written by Michael Prerau (c) 2011.

* `cvKernel` computes the maximum likelihood estimate, the bandwidth parameter associated with the MLE, the log likelihoods for the range of tested bandwidths, and the tested bandwidths themselves. It takes a spike train, the time step, and the bandwidth range to be tested, in time-steps. It defaults to 3:2:N where N is 3/2 the length of the spike train. Generally, this is much too long, and it is advisable to put limits on the range of tested bandwidths.
* `kconv` performs the kernel convolution. It is called within `cvKernel`.
* `cvExample` is a script that demonstrates the algorithm.

The `batchFunction` is used for generating batch scripts with [RatCatcher](https://github.com/hasselmonians/RatCatcher).
