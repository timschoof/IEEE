function y=normRMS(y, rms)

y =  y * rms/(norm(y)/sqrt(length(y)));

% check for overloads
max_sample = max(abs(y));
if max_sample > 0.99	% ---- !! OVERLOAD !! -----
	% figure out degree of attenuation necessary
	ratio = 0.99/max_sample;
	fprintf('!! WARNING -- OVERLOAD !! File should be scaled by %f = %f dB\n', ratio, 20*log10(ratio));
    %error('RMS level must be decreased')
end
