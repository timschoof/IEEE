function varargout = TestSpecs(varargin)
%
%
% TESTSPECS M-file for TestSpecs.fig
%      TESTSPECS, by itself, creates a new TESTSPECS or raises the existing
%      singleton*.
%
%      H = TESTSPECS returns the handle to a new TESTSPECS or the handle to
%      the existing singleton*.
%
%      TESTSPECS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTSPECS.M with the given input arguments.
%
%      TESTSPECS('Property','Value',...) creates a new TESTSPECS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TestSpecs_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TestSpecs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TestSpecs

% Last Modified by GUIDE v2.5 08-Mar-2018 09:03:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TestSpecs_OpeningFcn, ...
    'gui_OutputFcn',  @TestSpecs_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TestSpecs is made visible.
function TestSpecs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TestSpecs (see VARARGIN)

% Move the GUI to the center of the screen.
movegui(hObject,'center')

% Choose default command line output for TestSpecs
handles.output = hObject;

% set default Volume Settings file
handles.VolumeSettingsFile = 'VolumeSettings.txt';

% process any arguments to re-set the TestSpecs GUI
if length(varargin{1})>1
    for index=1:2:length(varargin{1})
        if length(varargin{1}) < index+1
            break;
        elseif strcmp('SentenceDirectory', varargin{1}(index))
            set(handles.OrderFile,'String',char(varargin{1}(index+1)));
        elseif strcmp('SNR', varargin{1}(index))
            set(handles.StartLevel,'String',num2str(cell2mat(varargin{1}(index+1))));
        elseif strcmp('ListNumber', varargin{1}(index))
            set(handles.ListNumber,'String',num2str(cell2mat(varargin{1}(index+1))));
        elseif strcmpi('VolumeSettingsFile', varargin{1}(index))
            set(handles.VolSetFile,'String',char(varargin{1}(index+1)));
        elseif strcmp('method', varargin{1}(index))
            switch lower(char(varargin{1}(index+1)))
                case 'd'
                    set(handles.AdaptiveDown,'Value',1);
                case 'u'
                    set(handles.AdaptiveUp,'Value',1);
                case 'f'
                    set(handles.Fixed,'Value',1);
                otherwise
                    error('Illegal option for method: must be d(own), u(p), f(ixed)');
            end
        elseif strcmp('ear', varargin{1}(index))
            switch lower(char(varargin{1}(index+1)))
                case 'b'
                    set(handles.Both,'Value',1);
                case 'u'
                    set(handles.Left,'Value',1);
                case 's'
                    set(handles.Right,'Value',1);
                otherwise
                    error('Illegal option for ear: must be b(oth), u(nshifted), s(hifted)');
            end
        elseif strcmp('track', varargin{1}(index))
            switch num2str(cell2mat(varargin{1}(index+1)))
                case '3'
                    set(handles.track30,'Value',1);
                case '5'
                    set(handles.track50,'Value',1);
                otherwise
                    error('Illegal option for track: must be 3 or 5');
            end
        elseif strcmp('feedback', varargin{1}(index))
            switch num2str(cell2mat(varargin{1}(index+1)))
                case '0'
                    set(handles.AudioOff,'Value',1);
                case '1'
                    set(handles.AudioOn,'Value',1);
                otherwise
                    error('Illegal option for feedback: must be 0 or 1');
            end
        elseif strcmp('NAL', varargin{1}(index))
            switch lower(char(varargin{1}(index+1)))
                case 'nal'
                    set(handles.nal,'Value',1);
                case 'normal'
                    set(handles.normal,'Value',1);
                otherwise
                    error('Illegal option for ear: must be b(oth), u(nshifted), s(hifted)');
            end
        elseif strcmpi('ITD_us', varargin{1}(index))
            set(handles.itd_us,'String',num2str(cell2mat(varargin{1}(index+1))));
        elseif strcmpi('itd_invert', (varargin{1}(index)))
            if strcmpi(char(upper(varargin{1}(index+1))),'ITD')
                set(handles.ITD, 'Value', 1)
            elseif strcmpi(char(upper(varargin{1}(index+1))),'inverted')
                set(handles.inverted, 'Value', 1)
            elseif strcmpi(char(upper(varargin{1}(index+1))),'none')
                set(handles.neither, 'Value', 1)
            end
        elseif strcmpi('lateralize', (varargin{1}(index)))
            if strcmpi(char(upper(varargin{1}(index+1))),'signal')
                set(handles.signal, 'Value', 1)
            elseif strcmpi(char(upper(varargin{1}(index+1))),'noise')
                set(handles.noise, 'Value', 1)
            elseif strcmpi(char(upper(varargin{1}(index+1))),'signz')
                set(handles.signz, 'Value', 1)
            elseif strcmpi(char(upper(varargin{1}(index+1))),'neither')
                set(handles.neither, 'Value', 1)
            end
        elseif strcmpi('VolumeSettingsFile', varargin{1}(index))
            handles.VolumeSettingsFile = char(varargin{1}(index+1));
        else
            error('Illegal option: %s -- Legal options are:\nSentenceDirectory\nListNumber\nListener', ...
                char(varargin{1}(index)));
        end
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TestSpecs wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TestSpecs_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.L;
varargout{2} = handles.AorF;
varargout{3} = handles.Ear;
varargout{4} = handles.O;
varargout{5} = handles.SNR;
varargout{6} = handles.step;
varargout{7} = handles.feedback;
varargout{8} = handles.Max;
varargout{9} = handles.nList;
varargout{10} = handles.tl;
varargout{11} = handles.Nz;
varargout{12} = handles.NAL;
varargout{13} = handles.VolumeSettingsFile;
varargout{14} = handles.itd_invert;
varargout{15} = handles.lateralize;
varargout{16} = handles.itd_us;

% The figure can be deleted now
delete(handles.figure1);


%% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%% ------------------------------------------------------------------------
function StartLevel_Callback(hObject, eventdata, handles)
% hObject    handle to StartLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartLevel as text
%        str2double(get(hObject,'String')) returns contents of StartLevel as a double

% --- Executes during object creation, after setting all properties.
function StartLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ------------------------------------------------------------------------
function OrderFile_Callback(hObject, eventdata, handles)
% hObject    handle to OrderFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OrderFile as text
%        str2double(get(hObject,'String')) returns contents of OrderFile as a double

% --- Executes during object creation, after setting all properties.
function OrderFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OrderFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ------------------------------------------------------------------------
function TestTrials_Callback(hObject, eventdata, handles)
% hObject    handle to TestTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestTrials as text
%        str2double(get(hObject,'String')) returns contents of TestTrials as a double

% --- Executes during object creation, after setting all properties.
function TestTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ------------------------------------------------------------------------
function ListenerCode_Callback(hObject, eventdata, handles)
% hObject    handle to ListenerCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListenerCode as text
%        str2double(get(hObject,'String')) returns contents of ListenerCode as a double


% --- Executes during object creation, after setting all properties.
function ListenerCode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListenerCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ------------------------------------------------------------------------
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.AdaptiveUp,'Value')
    handles.AorF='adaptiveUp';
elseif get(handles.AdaptiveDown,'Value')
    handles.AorF='adaptiveDown';
else
    handles.AorF='fixed';
end
if get(handles.Both,'Value')
    handles.Ear='B';
elseif get(handles.Left,'Value')
    handles.Ear='L';
elseif get(handles.Right,'Value')
    handles.Ear='R';
else
    handles.Ear='Other';
end
if get(handles.AudioOn,'Value')
    handles.feedback=1;
else
    handles.feedback=0;
end
if get(handles.track30,'Value')
    handles.tl=30;
else
    handles.tl=50;
end
if get(handles.nal,'Value')
    handles.NAL='nal';
elseif get(handles.normal,'Value')
    handles.NAL='normal';
end
if get(handles.signal,'Value')
    handles.lateralize='signal';
elseif get(handles.noise,'Value')
    handles.lateralize='noise';
elseif get(handles.signz,'Value')
    handles.lateralize='signz';
else get(handles.neither,'Value')
    handles.lateralize='none';
end
if get(handles.ITD,'Value')
    handles.itd_invert='ITD';
elseif get(handles.inverted,'Value')
    handles.itd_invert='inverted';
elseif get(handles.neither,'Value')
    handles.itd_invert='none';
end

handles.O=get(handles.OrderFile,'String');
handles.SNR=str2num(get(handles.StartLevel,'String'));
handles.step=str2num(get(handles.StartingStep,'String'));
handles.L=get(handles.ListenerCode,'String');
handles.Max=str2num(get(handles.MaxTrialsSpec,'String'));
handles.nList=str2num(get(handles.ListNumber,'String'));
handles.Nz=get(handles.NoiseFile,'String');
handles.itd_us = str2num(get(handles.itd_us,'String'));
handles.VolumeSettingsFile = get(handles.VolSetFile,'String');

guidata(hObject, handles); % Save the updated structure
uiresume(handles.figure1);

%% -----------------------------------------------------------------------
function AdaptiveOrFixed_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to AdaptiveOrFixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.AorF=lower(get(hObject,'Tag'))   % Get Tag of selected object
if get(handles.AdaptiveUp,'Value')
    set(handles.StartLevel,'String','-10');
elseif get(handles.AdaptiveDown,'Value')
    set(handles.StartLevel,'String','20');
end

%% --------------------------------------------------------------------
function MaxTrialsSpec_Callback(hObject, eventdata, handles)
% hObject    handle to MaxTrialsSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxTrialsSpec as text
%        str2double(get(hObject,'String')) returns contents of MaxTrialsSpec as a double

% --- Executes during object creation, after setting all properties.
function MaxTrialsSpec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxTrialsSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% --------------------------------------------------------------------
function ListNumber_Callback(hObject, eventdata, handles)
% hObject    handle to ListNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListNumber as text
%        str2double(get(hObject,'String')) returns contents of ListNumber as a double

% --- Executes during object creation, after setting all properties.
function ListNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% --------------------------------------------------------------------
function StartingStep_Callback(hObject, eventdata, handles)
% hObject    handle to StartingStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartingStep as text
%        str2double(get(hObject,'String')) returns contents of StartingStep as a double

% --- Executes during object creation, after setting all properties.
function StartingStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartingStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% --------------------------------------------------------------------
% --- Executes on button press in AudioOn.
function AudioOn_Callback(hObject, eventdata, handles)
% hObject    handle to AudioOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of AudioOn

% --- Executes on button press in AudioOff.
function AudioOff_Callback(hObject, eventdata, handles)
% hObject    handle to AudioOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AudioOff



function NoiseFile_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoiseFile as text
%        str2double(get(hObject,'String')) returns contents of NoiseFile as a double


% --- Executes during object creation, after setting all properties.
function NoiseFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoiseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VolSetFile_Callback(hObject, eventdata, handles)
% hObject    handle to VolSetFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VolSetFile as text
%        str2double(get(hObject,'String')) returns contents of VolSetFile as a double


% --- Executes during object creation, after setting all properties.
function VolSetFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VolSetFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function itd_us_Callback(hObject, eventdata, handles)
% hObject    handle to itd_us (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of itd_us as text
%        str2double(get(hObject,'String')) returns contents of itd_us as a double


% --- Executes during object creation, after setting all properties.
function itd_us_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itd_us (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
