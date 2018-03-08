function IEEEinNoiseAdaptive(varargin)
%% should work for BKBs and ASLs as well.
%% Only runs from csv file, using IEEEparseArgs. I don't think TestSpecs works.
% runIEEEseq('E01','IEEE Seq Lists\E01.csv')

% IEEEinNoiseAdaptive, modified from BilateralSimulationsAdaptive, modified from BilateralSentInNoiseAdaptive,
% to run adaptive experiments.
%
% ASL, BKB or IEEE sentences (3 key words for BKB & ASL but 5 for IEEE)
% Program accounts for the fact that some ASL/BKB sentences are missing
%       (those with 4 key words), hence not all sentence numbers exist
%
% BilateralSimulationsAdaptive('SentenceDirectory',['ASL' 'BKB' 'IEE' or 'ABC',
%   with additional single character indicator])
% The full string is taken as the name of the directory with the stimuli
% Stimulus wav file  names must be of the form BKBQ0101, for example.
% The first 3 characters indicate the name of the text file with the key
% words
%
% For Tim Schoof: AdaptiveUp routine only appropriate for BKB/ASL sentences!!
% November 2009
%-----------------------------------------------------------------------
% To do:
%   put rms levels in and out on to the interface
%   put MaxBumps on the interface
%   figure out a general way to initialise the parameter values in the
%       interface from a text file, line a .ini
%   browse masker file names choose?
%-----------------------------------------------------------------------
% Previous History:
%
%   Version 1 -- January 2012 IEEEinNoiseAdaptive
%       IEEE and BKBs without CI and HA simulations
%       have the option of running sequence of runs specified in csv file
%       can select ear
%       finish button prints out condition details
%
%   Vs 2.0 -- June 2009
%       implement fixed level procedure
%       allow shift or not of odd channels
%       keep track of overall level of performance (esp for fixed levels)
%
%   Vs 1.1 -- June 2009
%       allow the specification of tracking level, in some rought way
%       fix monor error in time
%   Vs 1.0 -- June 2009
%
%
% BilateralSentInNoiseAdaptive('SentenceDirectory','IEEEm','Listener', 'L27','ListNumber',2)
%
% Version 2.3 - May 2009
%   correct error in use of non-integral list numbers in specifying start
% Version 2.2 - May 2009
%   allow the use of ABC sentences (similar to IEEE)
%
% Version 2.1 - May 2009
%   read in rms from VolumeSettings.txt as in CCRM
%   allow typical adaptive procedure starting from high SNR, as well as
%       Plomp & Mimpen up from bottom
%
% Version 2.0 - May 2009
%   control which sections of long noise wave get played out to minimise
%       repeated playing of particular sections
%   use function add_noise.m from CCRM 2009, in place of AddNoiseReturnAnother.m
%       possibility of a contralateral noise nobbled in this version
%       could be added back later.
% Version 1.2 - February 2008
%   allow specification of run-time paramaters on command line
% Version 1.1 - January 2008
%   modify bumping rules to stop premature termination of trials, esp on
%   the 2nd trial.
%   Make MaxBumps an explicit paramater
%   Up the Bumps
% Version 1.0 - December 2007, based on SentInNoiseFixed for Arooj
%   and SentInNoise for KMair
%   Major changes:
%   Bring sentence up from a low level until heard correctly,
%       and then begion adaptive track (as in Plomp & Mimpen, 1978)
%   Use GUI for entering information for starting procedure

% Version 2.0 - November 2007, modified for Arooj's project
%   read in volume settings from a file for easier use in compiled mode
%   convert arguement strings to numbers when appropriate
%   delete interface completely at end of session
% June 2007 based on SentInNoise from K Mair's project
% Vs 1.5 December 2006: only play sentences in specified file list, and
% index properly into the list.
% Stuart Rosen stuart@phon.ucl.ac.uk -- October 2006
% based on version for Bronwen Evans -- 27 August 2003
% based on ASLBKBrun -- December 2001

%% initialisations
VERSION='HHL';
player = 0; % are you using playrec? yes = 1, no = 0

DEBUG=0;
OutputDir = 'results';
MAX_SNR_dB = 18;
SentenceNumber=1; % can be modified if list number is not an integer
START_change_dB = 6.0;
MIN_change_dB = 2.0;
INITIAL_TURNS = 2; % need one for the initial sentence up from the bottom if adaptiveUp
FINAL_TURNS = 18;
limit = 1;
MaxBumps = 10;
warning_noise_duration = 500;
NoiseRiseFall = 100;    % taper the noise on and off, adding this duration
mInputArgs = varargin;
min_num_turns = 3;
max_std = 4;

% initialise the random number generator on the basis of the time
rand('twister', sum(100*clock));

%% Get audio device ID based on the USB name of the device.
if player == 1 % if you're using playrec
    %dev = playrec('getDevices');
    playDeviceInd = 50; % RME FireFace channels 3+4
    recDeviceInd = 50;
end

%% get control parameters one way or t'other
if nargin==0
    StartMessage='Here we go!';
    [OutFile, TestType, ear, SentenceDirectory, InitialSNR_dB, START_change_dB, ...
        AudioFeedback, MaxTrials, ListNumber, TrackingLevel, ...
        NoiseFile,VolumeSettingsFile,itd_invert,lateralize,ITD_us] = TestSpecs(mInputArgs);
    
else % pick up defaults and specified values from args
    if ~rem(nargin,2)
        error('You should not have an even number of input arguments');
    end
    SpecifiedArgs=IEEEparseArgs(varargin{1},varargin{2:end});
    % now set all parameters obtained
    fVars=fieldnames(SpecifiedArgs);
    for f=1:length(fVars)
        if ischar(eval(['SpecifiedArgs.' char(fVars{f})]))
            eval([char(fVars{f}) '=' '''' eval(['SpecifiedArgs.' char(fVars{f})]) ''';']);
        else % it's a number
            eval([char(fVars{f}) '='  num2str(eval(['SpecifiedArgs.' char(fVars{f})])) ';'])
        end
    end
end

SentenceType=upper(SentenceDirectory([1:3]));
SNR_dB=InitialSNR_dB;

NoiseFile = fullfile('maskers', NoiseFile);

% revert back to some default values if necessary
if ~strcmp(ear,'B') % if signal is to be monaural
    itd_invert = 'none';
end
if ~strcmp(itd_invert,'ITD') % if no ITD is to be applied
    ITD_us = 0; % set ITD to 0 microseconds if it's not being used anyway - for saving in output file
end
if strcmp(itd_invert,'none') % if no ITD or inverted polarity is to be applied
    lateralize = 'none'; % set lateralize (i.e. whether to apply ITD or inverted polarity to the signal, noise, or signz) to 'none' if no manipulation is applied - for saving in output file
end

% check if a non-integral list number has been specified
if round(ListNumber)~=ListNumber
    switch SentenceType
        case 'ABC'
            SentenceNumber=mod(round((ListNumber-1)*30),30);
        case 'IEE'
            SentenceNumber=mod(round((ListNumber-1)*10),10);
        case 'ASL'
            SentenceNumber=mod(round((ListNumber-1)*15),15);
        otherwise % BKB
            SentenceNumber=mod(round((ListNumber-1)*14),14);
    end
    ListNumber=floor(ListNumber);
end

%% Settings for level
[InRMS, OutRMS] = SetLevels(VolumeSettingsFile);

%% set rules for adaptively altering levels
if strcmp(SentenceType,'IEE')|| strcmp(SentenceType,'ABC')
    SentenceType='IEEE';
    % define the direction in which to change levels for
    %               [0  1  2  3 4 5] correct
    % CHANGE_VECTOR = [1  1  1  1 0 -1]; % 0-3 correct makes it easier; 4 correct stays at the same level; 5 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  1  -1 -1 -1]; % 0-2 correct makes it easier; 3-5 correct makes it more difficult
    if TrackingLevel==30
        CHANGE_VECTOR = [1  1  -1  -1 -1 -1]; % track 30% -- 0-1 correct makes it easier; 2-5 correct makes it more difficult
    else
        CHANGE_VECTOR = [1  1  1  -1 -1 -1];  % track 50% -- 0-2 correct makes it easier; 3-5 correct makes it more difficult
    end
elseif strcmp(SentenceType,'BKB') || strcmp(SentenceType,'ASL')
    % define the direction in which to change levels for BKB/ASL
    %               [0  1  2  3] correct
    % CHANGE_VECTOR = [1  0  -1 -1]; % Track 33% -- 0 correct makes it easier; stays put with 1 correct; 2 or 3 correct makes it more difficult
    CHANGE_VECTOR = [1  1  -1 -1]; % 0 or 1 correct makes it easier; 2 or 3 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  0 -1]; % Track 66% --  0 or 1 correct makes it easier; 2 correct stays at same level; 3 correct makes it more difficult
    % CHANGE_VECTOR = [1  1  1 -1]; % 0 or 1 or 2 correct makes it easier; 3 correct makes it more difficult
else
    error('First 3 characters of directory given must be one of IEEE, ABC, BKB or ASL');
end

if strcmp(TestType,'fixed')
    FINAL_TURNS = 200;
    MaxBumps = 200;
    CHANGE_VECTOR = [0 0 0 0 0 0];
    % error('Fixed procedure not yet implemented');
end

%% read in list of key words
% assume the key words are in ASLwords.txt, BKBwords.txt, IEEEwords.txt
[list, sentence, KeyWords]= textread([upper(SentenceType) 'words.txt'],'%d %d %s','delimiter','\n','whitespace','');

status = mkdir(OutputDir);
if status==0
    error('Cannot create new output directory for results: %s', OutputDir);
end
% get the starting date & time of the session
StartTime=fix(clock);
StartTimeString=sprintf('%02d:%02d:%02d',...
    StartTime(4),StartTime(5),StartTime(6));
FileNamingStartTime = sprintf('%02d-%02d-%02d',StartTime(4),StartTime(5),StartTime(6));
StartDate=date;
% construct the output data file name
ListenerName = OutFile;
% [pathstr, ListenerName, ext, versn] = fileparts(OutFile);
% put method, date and time on filenames so as to ensure a single file per test
if practice > 0
    FileListenerName=[ListenerName '_practice_' StartDate '_' FileNamingStartTime];
else
    if strcmp(itd_invert,'ITD')
        FileListenerName=[ListenerName '_' num2str(ITD_us) 'us_' itd_invert '_' lateralize '_' StartDate '_' FileNamingStartTime];
    elseif strcmp(itd_invert,'inverted')
        FileListenerName=[ListenerName '_' itd_invert '_' lateralize '_' StartDate '_' FileNamingStartTime];
    elseif strcmp(itd_invert,'none')
        FileListenerName=[ListenerName '_' itd_invert '_' StartDate '_' FileNamingStartTime];
    end
end
OutFile = fullfile(OutputDir, [FileListenerName '.csv']);
SummaryOutFile = fullfile(OutputDir, [FileListenerName '_sum.csv']);
% write some headings and preliminary information to the output file
fout = fopen(OutFile, 'at');
if strcmp(SentenceType,'BKB') || strcmp(SentenceType,'ASL')
    fprintf(fout, 'listener,date,sTime,trial,targets,masker,VolumeSettings,manipulation,lateralized,ITD,SNR,wave,w1,w2,w3,total,rTime,revs');
else
    fprintf(fout, 'listener,date,sTime,trial,targets,masker,VolumeSettings,manipulation,lateralized,ITD,SNR,wave,w1,w2,w3,w4,w5,total,rTime,revs');
end

fclose(fout);

%% find starting place in list of sentences
% modification for IEEE should be applicable to ~any~ list
if strcmp(SentenceType,'IEEE')
    % find list and sentences in given list of stimuli
    % throw error if not available
    SentenceIndex=find(list==ListNumber & sentence==SentenceNumber);
    if isempty(SentenceIndex)
        error('List %d sentence %d not in stimulus list',ListNumber,SentenceNumber);
    end
    % SentenceIndex = (ListNumber-1)*10 + SentenceNumber;
elseif strcmp(SentenceType,'ASL')
    SentenceIndex = SentenceNumber;
else % BKB sentences
    SentenceIndex = SentenceNumber;
end

%% setup a few starting values
if strcmp(TestType,'adaptiveUp')
    previous_change = 1; % assume track is initially moving from hard to easy
else
    previous_change = -1; % assume track is initially moving from easy to hard
end
num_turns = 0;
change = START_change_dB;
inc = (START_change_dB-MIN_change_dB)/INITIAL_TURNS;
limit = 0;
response_count = 0;
trial = 0;
nWavSection=0;

FirstSentence=1; % indicate different procedure for first sentence for adaptiveUp
if strcmp(TestType,'adaptiveUp')
    tmpCHANGE_VECTOR=CHANGE_VECTOR;
    CHANGE_VECTOR=ones(size(CHANGE_VECTOR));
    CHANGE_VECTOR(end)=0;
end

%% wait to start
Image = imread('benzilan.jpg','jpg');
GoOrMessageButton('String', StartMessage, Image)

nCorrect=[]; % keep track of the number of key words correct in each sentence
%% run the test (do adaptive tracking until stop criterion)
while (num_turns<FINAL_TURNS  && limit<=MaxBumps && trial<MaxTrials)
    trial=trial+1;
    nWavSection=nWavSection+1;
    % construct complete filename
    InFileName = construct_filename(SentenceDirectory,list(SentenceIndex), sentence(SentenceIndex));
    StimulusFile = fullfile(SentenceDirectory, InFileName);
    
    % construct the correct stimulus
    [y,Fs,~,sigAlone,noiseAlone] = add_noise(StimulusFile, NoiseFile, 0, SNR_dB, 0, 'noise', 0, OutRMS, warning_noise_duration, NoiseRiseFall);
    
    % if required, apply crude spatialization (based on overall ITD or by simply inverting the polarity)
    if strcmp(itd_invert,'ITD') && ~ITD_us==0 % if ITD is to be applied (i.e. is not zero)
        if strcmp(lateralize,'signal')
            % create lagging and leading signal
            sig_lead = [sigAlone; zeros(round(((ITD_us*Fs)/10^6)),1)];
            sig_lag = [zeros(round(((ITD_us*Fs)/10^6)),1); sigAlone]; % NB: ITD is in microseconds
            % equate length of noiseAlone with that of signal by adding zeros at the end
            nz_front = [noiseAlone; zeros(round(((ITD_us*Fs)/10^6)),1)];
            % combine signal and noise
            lead = sig_lead + nz_front;
            lag = sig_lag + nz_front;
            % combine left and right channels
            y = [lag,lead]; % position of the signal is on the right
        elseif strcmp(lateralize,'noise')
            % create lagging and leading noise
            noise_lead = [noiseAlone; zeros(round(((ITD_us*Fs)/10^6)),1)];
            noise_lag = [zeros(round(((ITD_us*Fs)/10^6)),1); noiseAlone]; % NB: ITD is in microseconds
            % equate length of sigAlone with that of noise by adding zeros at the end
            sig_front = [sigAlone; zeros(round(((ITD_us*Fs)/10^6)),1)];
            % combine signal and noise
            lead = sig_front + noise_lead;
            lag = sig_front + noise_lag;
            % combine left and right channels
            y = [lag,lead]; % position of the noise is on the right
        elseif strcmp(lateralize,'signz')
            % create lagging and leading signal
            sig_lead = [sigAlone; zeros(round(((ITD_us*Fs)/10^6)),1)];
            sig_lag = [zeros(round(((ITD_us*Fs)/10^6)),1); sigAlone]; % NB: ITD is in microseconds
            % create lagging and leading noise
            noise_lead = [noiseAlone; zeros(round(((ITD_us*Fs)/10^6)),1)];
            noise_lag = [zeros(round(((ITD_us*Fs)/10^6)),1); noiseAlone]; % NB: ITD is in microseconds
            % combine signal and noise (one leads, other lags)
            lead = sig_lead + noise_lag;
            lag = sig_lag + noise_lead;
            % combine left and right channels
            y = [lag,lead]; % position of the signal is on the right
        else
            error('If ITD_invert is set to ITD, lateralize should be either signal, noise, or signz (i.e. both)')
        end
    elseif strcmp(itd_invert,'ITD') && ITD_us==0
        error('If laterlize is set to ITD, then an ITD >0 should be specified')
    elseif strcmp(itd_invert,'inverted')
        if strcmp(lateralize,'signal')
            % invert signal polarity
            sig_inv = -1*sigAlone;
            % combine signal and noise
            sig_nz_inv = sig_inv + noiseAlone;
            sig_nz = sigAlone + noiseAlone;
            % combine left and right channels
            y = [sig_nz_inv, sig_nz]; % left channel is always inverted
        elseif strcmp(lateralize,'noise')
            % invert noise polarity
            nz_inv = -1*noiseAlone;
            % combine signal and noise
            sig_nz_inv = nz_inv + sigAlone;
            sig_nz = sigAlone + noiseAlone;
            % combine left and right channels
            y = [sig_nz_inv, sig_nz]; % left channel is always inverted
        elseif strcmp(lateralize,'signz')
            % invert signal and noise polarities
            sig_inv = -1*sigAlone;
            nz_inv = -1*noiseAlone;
            % combine signal and noise, where one is inverted and the
            % other isn't
            nz_sig_inv = sig_inv + noiseAlone; % inverted signal + non-inverted noise
            sig_nz_inv = nz_inv + sigAlone; % non-inverted signal + inverted noise
            y = [sig_nz_inv, nz_sig_inv]; % left: inverted noise, right: inverted signal
        else
            error('If ITD_invert is set to inverted, lateralize should be either signal, noise, or signz (i.e. both)')
        end
    end
    
    if ~strcmp(itd_invert,'ITD') && ~strcmp(itd_invert,'inverted') % if no ITD or inverting polarity is applied
        ContraNoise = zeros(size(y)); % make a silent contralateral noise for monaural presentations
        % determine the ear(s) to play out the stimuli
        switch upper(ear)
            case 'L', y = [y ContraNoise];
            case 'R', y = [ContraNoise y];
            case 'B', y = [y y];
            otherwise error('variable ear must be one of L, R or B')
        end
    end
    
    %     y = [y;y;y;y;y;y;y;y]; % for calibration
    
    % intialize playrec
    if player == 1 % if you're using playrec
        if playrec('isInitialised')
            fprintf('Resetting playrec as previously initialised\n');
            playrec('reset');
        end
        playrec('init', Fs, playDeviceInd, recDeviceInd);
    end
    
    if ~DEBUG
        % play it out and score it.
        if strcmp(SentenceType,'IEEE')
            response =     IEEE(5,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,SNR_dB,y,player);
        else
            response = ASLscore(3,KeyWords{SentenceIndex},list(SentenceIndex),sentence(SentenceIndex),Fs,SNR_dB,y,player);
        end
    else
        if strcmp(SentenceType,'IEEE')
            RandomPropCorrect=0.3;
            response=[rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect];
        else
            RandomPropCorrect=0.3;
            response=[rand>RandomPropCorrect rand>RandomPropCorrect rand>RandomPropCorrect];
        end
    end
    TmpTimeOfResponse = fix(clock);
    TimeOfResponse=sprintf('%02d:%02d:%02d',...
        TmpTimeOfResponse(4),TmpTimeOfResponse(5),TmpTimeOfResponse(6));
    % test for quitting
    if strcmp(response,'quit')
        break
    end
    
    % strip out the required number of keywords from the concatenated string
    KW = cell(3,1);
    remnant = char(KeyWords{SentenceIndex});
    for i=1:3
        [KW{i}, remnant]=strtok(remnant);
    end
    
    AllCorrect=0;
        
    % extract level from VolumeSettingsFile
    Num = regexp(VolumeSettingsFile,'\d');
    Level = VolumeSettingsFile(Num);
    
    fout = fopen(OutFile, 'at');
    % print out relevant information
    % fprintf(fout, 'listener,date,sTime,trial,targets,masker,VolumeSettings,manipulation,lateralized,ITD,SNR,wave,w1,w2,w3,total,rTime,revs');
    if strcmp(SentenceType,'BKB') || strcmp(SentenceType,'ASL')
        fprintf(fout, '\n%s,%s,%s,%d,%s,%s,%s,%s,%s,%+5.1f,%+5.1f,%s,%d,%d,%d,%d,%s', ...
            ListenerName,StartDate,StartTimeString,trial,SentenceDirectory,NoiseFile,Level,itd_invert,lateralize,ITD_us,SNR_dB,InFileName,...
            response(1),response(2),response(3),sum(response),...
            TimeOfResponse);
        % give optional auditory feedback
        if sum(response)==3
            AllCorrect=1;
        end
    else
        fprintf(fout, '\n%s,%s,%s,%d,%s,%s,%s,%s,%s,%+5.1f,%+5.1f,%s,%d,%d,%d,%d,%d,%d,%s', ...
            ListenerName,StartDate,StartTimeString,trial,SentenceDirectory,NoiseFile,Level,itd_invert,lateralize,ITD_us,SNR_dB,InFileName,...
            response(1),response(2),response(3),response(4),response(5),sum(response),...
            TimeOfResponse);
        if sum(response)==5
            AllCorrect=1;
        end
    end
    
    % give optional auditory feedback
    if AudioFeedback && ~DEBUG
        [x, SampRate] =  audioread(['',StimulusFile,'.wav','']);
        p = audioplayer(x,SampRate);
        play(p)
        pause(1);
        p = audioplayer(y,Fs);
        play(p)
        pause(1);
    end
    
    % decide in which direction to change levels
    current_change = CHANGE_VECTOR(sum(response)+1);
    % are we at a turnaround? (defined here as any change in direction)
    % If so, do a few things
    if (previous_change ~= current_change)
        % reduce step proportion if not minimum */
        if ((change-0.001) > MIN_change_dB) % allow for rounding error
            change = change-inc;
        else % final turnarounds, so start keeping a tally
            num_turns = num_turns + 1;
            reversals(num_turns)=SNR_dB;
            fprintf(fout,',*');
        end
        % reset change indicator
        previous_change = current_change;
    end
    % change stimulus level
    SNR_dB = SNR_dB +  change*current_change;
    
    % ensure that the current stimulus level is within the possible range
    % and keep track of hitting the endpoints, but not for the first sentence
    if SNR_dB>MAX_SNR_dB
        SNR_dB = MAX_SNR_dB;
        if  ~FirstSentence
            limit = limit+1;
        end
    end
    
    % close file for safety
    fclose(fout);
    
    if strcmp(TestType,'adaptiveUp')
        if FirstSentence
            % move on to proper test if all words identified
            % only good for BKB sentences!!
            if sum(response)>=2; %length(CHANGE_VECTOR)-1
                FirstSentence=0;
                CHANGE_VECTOR=tmpCHANGE_VECTOR;
            end
        end
    end
    % increment sentence counter except if first trial
    if ~FirstSentence || ~strcmp(TestType,'adaptiveUp')
        SentenceIndex = SentenceIndex + 1;
    else
        trial=trial-1;
    end
    % keep a running tally of number correct
    nCorrect=[nCorrect sum(response)];
end  % end of a single trial */

%% We're done!
EndTime=fix(clock);
EndTimeString=sprintf('%02d:%02d:%02d',EndTime(4),EndTime(5),EndTime(6));

%% output summary statistics
fout = fopen(SummaryOutFile, 'at');
fprintf(fout, 'listener,date,sTime,endTime,type,stimuli,masker,condition,TestType,startSNR,feedback,ear,changes,VolumeSettings,manipulation,lateralised,ITD,version');
fprintf(fout, ',finish,uRevs,sdRevs,nRevs,nTrials,totKWc,totKW,uKW,sdKW');
%                 L  S  S  E  S  S  T dB  c fd ear cv vs
fprintf(fout, '\n%s,%s,%s,%s,%s,%s,%s,%s,%s,%g,%d,%s,%s,%s,%s,%s,%+5.1f,%s', ...
    ListenerName,StartDate,StartTimeString,EndTimeString,...
    SentenceType,SentenceDirectory,NoiseFile,condition,TestType,InitialSNR_dB,...
    AudioFeedback,ear,sprintf('%d ',CHANGE_VECTOR),Level,itd_invert,lateralize,ITD_us,VERSION);


%  % print out summary statistics -- how did we get here?
% if (limit>=3) % bumped up against the limits
%    fprintf(fout,',BUMPED');
% elseif strcmp(response,'quit')  % test for quitting
%    fprintf(fout, ',QUIT');
% elseif (num_turns<FINAL_TURNS)
%       fprintf(fout, ',RanOut');
% else
%       fprintf(fout, ',OK');
% end

% How did we get here?
if (limit>=3) % bumped up against the upper limits
    fprintf(fout,'%s',',BUMPED');
elseif (num_turns>=FINAL_TURNS)
    fprintf(fout,'%s',',RanOutTurns');
elseif (trial>=MaxTrials)
    fprintf(fout,'%s',',RanOutTrials');
elseif strcmp(TestFinish,'quit')  % test for quitting
    fprintf(fout,'%s',',QUIT');
else
    fprintf(fout,'%s',',OK');
end

if num_turns>1
    fprintf(fout, ',%5.2f,%5.2f', ...
        mean(reversals), std(reversals));
else
    fprintf(fout, ',,');
end
fprintf(fout, ',%d,%d', num_turns, trial);

fprintf(fout,',%d,%d,%5.2f', ...
    sum(nCorrect),trial*(length(CHANGE_VECTOR)-1),mean(nCorrect));
if trial>1
    fprintf(fout,',%d,%d,%5.2f,%5.2f', std(nCorrect));
else
    fprintf(fout,',,');
end

% if num_turns > min_num_turns
%     if nonzeros(std(reversals)) < max_std
%          [final_message_string, errmsg] = sprintf('mean= %5.2f s.d.= %5.2f for %d reversals', ...
%          mean(nonzeros(reversals)), nonzeros(std(reversals)), num_turns);
%     else
%          [final_message_string, errmsg] = sprintf('standard deviation > %5.2f , repeat the task. SETTINGS: TestType: %s , NAL: %s, ear: %s , SentenceDirectory: %s , InitialSNR_dB: %d , START_change_dB: %d , AudioFeedback: %d , MaxTrials: %d , ListNumber: %d , TrackingLevel: %d , NoiseFile: %s', max_std, TestType, NAL, ear, SentenceDirectory, InitialSNR_dB, START_change_dB, AudioFeedback, MaxTrials, ListNumber, TrackingLevel, NoiseFile);
%     end
% else
%   final_message_string = sprintf('Insufficient number of reversals for calculations (<2). SETTINGS: TestType: %s , NAL: %s, ear: %s , SentenceDirectory: %s , InitialSNR_dB: %d , START_change_dB: %d , AudioFeedback: %d , MaxTrials: %d , ListNumber: %d , TrackingLevel: %d , NoiseFile: %s', TestType, NAL, ear, SentenceDirectory, InitialSNR_dB, START_change_dB, AudioFeedback, MaxTrials, ListNumber, TrackingLevel, NoiseFile);
% end

if num_turns > min_num_turns
    if nonzeros(std(reversals)) < max_std
        [final_message_string, errmsg] = sprintf('mean= %5.2f s.d.= %5.2f for %d reversals', ...
            mean(nonzeros(reversals)), nonzeros(std(reversals)), num_turns);
    else
        [final_message_string, errmsg] = sprintf('standard deviation > %5.2f , repeat the task.', nonzeros(std(reversals)));
    end
else
    final_message_string = sprintf('Insufficient number of reversals for calculations (<3). Repeat the task.');
end

fprintf(fout, ',%s', final_message_string);

fclose(fout);
fclose('all');
%% clean up
set(0,'ShowHiddenHandles','on');
delete(findobj('Type','figure'));

finish_message(1,final_message_string);
waitforbuttonpress;
% FinishButton; % indicate test is over

if player==1
    % close psych toolbox audio
    PsychPortAudio('DeleteBuffer');
    PsychPortAudio('Close');
end

function name = construct_filename(SentenceIndicator,list, sentence)
if strcmp(SentenceIndicator([1:3]),'IEE')
    name = sprintf('ieee%02d%s%02d', list, 'm', sentence);
elseif strcmp(SentenceIndicator([1:3]),'ABC')
    name = sprintf('abc%s%02d%02d', 'f', list, sentence);
else
    name = [SentenceIndicator sprintf('%02d%02d', list, sentence)];
end


