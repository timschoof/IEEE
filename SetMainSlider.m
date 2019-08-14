function SetMainSlider(attn)
<<<<<<< HEAD
=======
% translate attennuation values to something RME can use
>>>>>>> 0b685226edca2ece51aecdbdc9867973e4c4878b
attn2midi = [0:5:120, 127;
           -64.6, -58.7, -53.2, -48,   -43,   -38.3, -34,  -29.9, -26.1, -22.6, ...
           -19.4, -16.5, -13.8, -11.5,  -9.4,  -7.7,  -6.2, -4.9,  -3.6,  -2.3, ...
            -1.1,   0.2,   0.9,   2.8,   4.1,   5.9];
if attn< -64 || attn > 5.9
 error('attenuation out of range\n')
end
a = round(interp1(attn2midi(2,:),attn2midi(1,:), attn, 'spline'));

import javax.sound.midi.*
<<<<<<< HEAD

  
info       = MidiSystem.getMidiDeviceInfo;      % This will return a list of available MIDI devices
=======
  
% This will return a list of available MIDI devices
info       = MidiSystem.getMidiDeviceInfo;      
>>>>>>> 0b685226edca2ece51aecdbdc9867973e4c4878b

% find the loopMIDI port
for i=1:size(info)
    infoChans(i).info= sprintf('%s',info(i));
end
channel = find( cellfun(@(x)isequal(x,'loopMIDI Port'),{infoChans.info}) );

<<<<<<< HEAD
=======
if isempty(channel)
    error('You may still need to start loopMIDI')
end

>>>>>>> 0b685226edca2ece51aecdbdc9867973e4c4878b
outputPort = MidiSystem.getMidiDevice(info(channel(2))); % The actual device index will vary depending on your configuration
outputPort.open;
r          = outputPort.getReceiver;
note       = ShortMessage;

<<<<<<< HEAD
=======
% if you want to control the main slider
>>>>>>> 0b685226edca2ece51aecdbdc9867973e4c4878b
% note.setMessage(ShortMessage.PITCH_BEND,   ...
%                  9 - 1,                    ...  % MIDI channel # minus 1
%                  48,                       ...  % MIDI note A#6
%                  a);                            % syntax 
             
<<<<<<< HEAD
note.setMessage(ShortMessage.CONTROL_CHANGE,   ...
    9 - 1,                    ...  % MIDI channel # minus 1
    104,                       ...  % MIDI note A#6
    a);                            % syntax
             
=======
% controlling RME hardware outputs 3 & 4
note.setMessage(ShortMessage.CONTROL_CHANGE,   ...
    9 - 1,                    ...  % MIDI channel # minus 1
    104,                       ...  % MIDI note A#6
    a);                            % syntax         
>>>>>>> 0b685226edca2ece51aecdbdc9867973e4c4878b
r.send(note, -1)

note.setMessage(ShortMessage.CONTROL_CHANGE,   ...
    9 - 1,                    ...  % MIDI channel # minus 1
    105,                       ...  % MIDI note A#6
    a);                            % syntax
<<<<<<< HEAD

=======
>>>>>>> 0b685226edca2ece51aecdbdc9867973e4c4878b
r.send(note, -1)
