function [y, f, l]   = noise(freqs, levels, samp_frq, min_dur)
%
%	function [y, f, l] = noise(freqs, levels, samp_frq, min_dur)
%
%	Generate a random noise of a given spectral structure
%
%	freqs - a vector of frequencies
% 	levels - a corresponding set of levels in dB
%	samp_freq - the sampling frequency
%	min_dur - minimum duration of the noise, in seconds
%
% 	y - the time wavform
%	f - the frequencies in the spectrum
% 	l - the interpolated levels (dB)
% Stuart Rosen December 1999

% POWER OF 2 SAMPLES ABOVE MINIMUM DURATION OF NOISE * SAMPLING FREQUENCY */
spect_length = 2^ceil(log2(min_dur*samp_frq));

% SET UP A VECTOR OF FREQUENCIES CORRESPONDING TO THE IFFT
f = samp_frq * (0:spect_length/2)/spect_length;

% INTERPOLATE THE VALUES FOR THE DESIRED SPECTRUM FROM THE GIVEN VALUES 
% ON dB BY LOG FREQUENCY SCALES (ADD 0.01 TO EACH FREQUENCY TO ALLOW FREQUENCY OF 0)
l = interp1(log(freqs+0.001), levels, log(f+0.001), 'linear');
% EXTRAPOLATE VALUES FOR FREQUENCIES IN THE SPECTRUM OUTSIDE GIVEN RANGE
l(f<freqs(1)) = levels(1);
l(f>freqs(length(freqs))) = levels(length(freqs));

% semilogx(f, l);

% CONVERT THE dB VALUES INTO LINEAR VALUES
l = 10.^(l/20);
% semilogx(f, l);

% randomly set the state of the random number generator
rand('state',sum(100*clock));
% Set up the real and imaginary parts of the desired spectrum
% This technique sets a random phase for each component in a given amplitude spectrum
real_s = l .* (2*rand(size(l))-1);
imag_s = ran_sign(l) .* sqrt(l.*l - real_s.*real_s); 
spectrum = real_s + i * imag_s;
% ZERO OUT ALL SPECTRAL COMPONENTS BELOW 50 Hz
spectrum = spectrum .* (f>50);
% for ease in constructing the necessary symmetric spectrm, set the DC component
% and the Nyquist frequency to 0
spectrum(1+spect_length/2)=0;
spectrum(1) = 0;
% construct the top half of the spectrum
top_spectrum = real_s(spect_length/2:-1:2) - i * imag_s(spect_length/2:-1:2);
% Create the rest of the spectrum (symmetric spectrum for real waveforms)
s = [spectrum top_spectrum];
%fprintf('Length of real frequency spectrum= %d; of upper half= %d; Total= %d\n', ...
%   length(spectrum),length(top_spectrum),length(s));


% optionally check that the magnitude of this is correct
Pyy = s .* conj(s) / spect_length;
%plot(20*log10(Pyy(Pyy>0)));
% plot(Pyy);

% calculate inverse FFT
y = real(ifft(s));

% scale y to be a 'good' level for a .wav file
y = y * 0.95/max(abs(y));

% plot(y);
