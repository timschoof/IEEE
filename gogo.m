VS_2009('sine',4.8, 0.5, 'greenwood', 'full', 32, 8, 6, '0104.wav', 'test_bkb_0.wav');
% makes sine vocoded, 4.8mm shift, 50% MAF correction on shifted carrier levels, greenwood spacing, full wave rectify
%32 Hz envelope smoothing, 8 bands, 6dB Speecn to noise ration for UNSHIFTED bands

VS_2009('sine',4.8, 0.5, 'greenwood', 'full', 32, 8, -70, '0104.wav', 'NoiseAlone.wav')
VS_2009('sine',4.8, 0.5, 'greenwood', 'full', 32, 8, 70, '0104.wav', 'SigAlone.wav')
