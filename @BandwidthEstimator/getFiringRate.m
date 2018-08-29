function rate = getFiringRate(self, bandwidth)

  % wraps the kconv function in a CMBHOME object
  filter = hanning(bandwidth) / sum(hanning(bandwidth));
  rate = self.kconv(self, filter);

end % function
