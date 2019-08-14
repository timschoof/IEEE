function SetMainSlider(attn)
attn2midi = [0:5:120, 127;
           -64.6, -58.7, -53.2, -48,   -43,   -38.3, -34,  -29.9, -26.1, -22.6, ...
           -19.4, -16.5, -13.8, -11.5,  -9.4,  -7.7,  -6.2, -4.9,  -3.6,  -2.3, ...
            -1.1,   0.2,   0.9,   2.8,   4.1,   5.9];
if attn< -64 || attn > 5.9
 error('attenuation out of range\n')
end
a = round(interp1(attn2midi(2,:),attn2midi(1,:), attn, 'spline'));

import javax.sound.midi.*

  
info       = MidiSystem.getMidiDeviceInfo;      % This will return a list of available MIDI devices

% find the loopMIDI port
for i=1:size(info)
    infoChans(i).info= sprintf('%s',info(i));
end
channel = find( cellfun(@(x)isequal(x,'loopMIDI Port'),{infoChans.info}) );

outputPort = MidiSystem.getMidiDevice(info(channel(2))); % The actual device index will vary depending on your configuration
outputPort.open;
r          = outputPort.getReceiver;
note       = ShortMessage;

% note.setMessage(ShortMessage.PITCH_BEND,   ...
%                  9 - 1,                    ...  % MIDI channel # minus 1
%                  48,                       ...  % MIDI note A#6
%                  a);                            % syntax 
             
note.setMessage(ShortMessage.CONTROL_CHANGE,   ...
    9 - 1,                    ...  % MIDI channel # minus 1
    104,                       ...  % MIDI note A#6
    a);                            % syntax
             
r.send(note, -1)

note.setMessage(ShortMessage.CONTROL_CHANGE,   ...
    9 - 1,                    ...  % MIDI channel # minus 1
    105,                       ...  % MIDI note A#6
    a);                            % syntax

r.send(note, -1)
