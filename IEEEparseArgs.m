function SpecifiedArgs=IEEEparseArgs(ListenerName,varargin)

% There is probably a smarter way to deal with numeric parameters being
% passed and converted, yet still allow the checking of the variable type
% November 2010 -- strategic decision to do it dumbly!
% January 2012 -- adapted from CCRMparseArgs

% get arguments for IEEEinNoiseAdaptive

p = inputParser;
p.addRequired('OutFile', @ischar);
p.addParamValue('TestType', 'adaptiveDown', @ischar);
p.addParamValue('ear', 'B', @ischar);
p.addParamValue('SentenceDirectory', 'IEEE', @ischar);
p.addParamValue('InitialSNR_dB', -10, @isnumeric);
p.addParamValue('START_change_dB', 6, @isnumeric);
p.addParamValue('AudioFeedback', 0, @isnumeric);
p.addParamValue('MaxTrials', 25, @isnumeric);
p.addParamValue('ListNumber', 1, @isnumeric);
p.addParamValue('TrackingLevel', 50, @isnumeric);
p.addParamValue('NoiseFile', '44100HzSpchNz', @ischar);    
p.addParamValue('StartMessage', 'Ready?', @ischar);
p.addParamValue('condition', 'any', @ischar);
p.addParamValue('practice', 0, @isnumeric);
p.addParamValue('VolumeSettingsFile', 'VolumeSettings-80dBSPL.txt', @ischar);   
p.addParamValue('itd_invert', 'inverted', @ischar); % options: ITD = interaural time difference, inverted = invert polarity in one ear, none = no manipulation
p.addParamValue('lateralize', 'signal', @ischar); % apply ITD or inverted polarity manipulation to: signal, noise, signz (i.e. both), or none - this defaults to 'none' if no manipulation is applied
p.addParamValue('ITD_us', 0, @isnumeric); % ITD in microseconds (if ITD is applied) - this defaults to 0 if ITD is not applied
p.addParameter('RMEslider','TRUE',@ischar); % ajust sliders on RME TotalMix if necesary - TRUE or FALSE

p.parse(ListenerName, varargin{:});

SpecifiedArgs=p.Results;

% [OutFile, TestType, ear, SentenceDirectory, InitialSNR_dB, START_change_dB, ...
%      AudioFeedback, MaxTrials, ListNumber, TrackingLevel, ...
%      NoiseFile, StartMessage, NAL] = TestSpecs(mInputArgs);