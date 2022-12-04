function [BehaviorFile] = ProcessCams(varargin)

% This function will save a .mat file named 'Behavior_mouse-ID##_YYYY-MM-DDTHH_MM_SS'.
% The file contains a matlab structure for each camera used in the experiment.
% Each structure contains all the important information for the specific camera.
% If DLC has been run for a specific camera, ProcessCams will save the data 
% in the camera's structure.
%
% This function must be run in the bonsai directory you want to process
        
%Input1:
    %For Rig2 before blackfly: 'Rig2old'
    %For Rig2 after blackfly: 'Rig2'
    %For Rig4: no input

%% Step1: Process information from the cameras:
if nargin>=1
    if isequal(varargin{1},'Rig2')
        [Sky] = GetSkyVideo();
        [Head] = GetAnalogVideo('Head',Sky.TTtimes);
        [Reye] = GetAnalogVideo('Reye',Sky.TTtimes);
    elseif isequal(varargin{1},'Rig2old')
        [Sky] = GetSkyVideoRig2old();
        [Head] = GetAnalogVideo('Head',Sky.TTtimes);
        [Reye] = GetAnalogVideo('Reye',Sky.TTtimes);
    else
        [Sky] = GetSkyVideo();
        [Head] = GetAnalogVideo('Head',Sky.TTtimes);
        [Lear] = GetAnalogVideo('Lear',Sky.TTtimes);
        [Rear] = GetAnalogVideo('Rear',Sky.TTtimes);
    end
else
    [Sky] = GetSkyVideo();
end

%% Step2: Save the camera structures in a .mat file named 'Behavior_mouse-IDnm_YYYY-MM-DDTHH_MM_SS.mat'
try
    BehaviorFile = strcat(pwd, filesep, 'Behavior', Sky.vid.name(4:34),'.mat');
catch %Rig2old
    BehaviorFile = strcat(pwd,filesep,'Behavior_mouse-', Sky.vid.name(5:28),'.mat'); 
end

if nargin>=1
    if isequal(varargin{1},'Rig2')
        save(BehaviorFile,'Sky','Head','Reye');
    elseif isequal(varargin{1},'Rig2old')
        save(BehaviorFile,'Sky','Head','Reye');
    else
        save(BehaviorFile,'Sky','Head','Lear','Rear')
    end
else
   save(BehaviorFile,'Sky');
end

end

%%%%%%%%%%%% Functions %%%%%%%%%%%%
function [Sky] = GetSkyVideo(varargin) %Returns a structure with video information
Sky.vid = dir('Sky_m*.mp4'); %raw video from bonsai
    if length(Sky.vid) < 1
        error('Couldnt find Sky video')
    end
    if length(Sky.vid) > 1
        for i = 1:length(Sky.vid)
            if length(Sky.vid(i).name) == 38
                Sky.vid = Sky.vid(i); %choose raw video instead of DLC-labeled video if present in the folder
                break
            end
        end
    end
    obj = VideoReader(Sky.vid.name);
    Sky.vid.framerate = obj.FrameRate;
    Sky.vid.size = [obj.Width,obj.Height];
Sky.csv = dir('Sky_m*.csv');
    if length(Sky.csv) > 1
        for i = 1:length(Sky.csv)
            if length(Sky.csv(i).name) == 38
                Sky.csv = Sky.csv(i); %choose timestamp csv instead of DLC csv if one is present in the folder
                break
            end
        end
    end
    Sky.times = textscan(fopen(Sky.csv.name),'%q'); Sky.times = Sky.times{1,1};
    Sky.times = Sky.times(2:2:end,:); Sky.times = cell2mat(Sky.times); Sky.times = Sky.times(:,1:27);
    Sky.length = length(Sky.times);
    for i=1:Sky.length
        Sky.times(i,:) = strrep(Sky.times(i,:),'T','_');
    end
    Sky.times = datetime(Sky.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');
    if ~isequal(Sky.length,obj.NumberOfFrames)
        Sky.length = obj.NumberOfFrames;
        try
            Sky.times = Sky.times(1:Sky.length);
        catch
%             flagVariable = Sky;
%             save('Flag_discordant.mat','flagVariable');
        end
    end
    Sky.TTL = dir('TTL_m*.csv'); Sky.TTL = textscan(fopen(Sky.TTL.name),'%q'); Sky.TTL = Sky.TTL{1,1};
    Sky.TTL = Sky.TTL(1:2:end,:); %trigger values
    Sky.TTs = find(~cellfun(@isempty,strfind(Sky.TTL,'True'))); %Framenumber for all triggered SkyCam frames
    
    %%%% This snippet here identifies the onset frame for each LED pulse,
    %%%% and saves them as Sky.TTs (which stands for 'TrueTriggers')
    temp = ones(size(length(Sky.TTs))); temp(1) = 90;
    for i=2:length(Sky.TTs)
        temp(i)=Sky.TTs(i)-Sky.TTs(i-1); %subtract previous trigger framenumber.
    end
    temp = temp - ones(size(temp)); temp = find(temp);
    try
        Sky.TTs = Sky.TTs(temp(1,:),1);
    catch
        Sky.TTs = [];
        disp('No LED triggers found!')
    end
    clear temp;
    %%%% End of that snippet
    
    Sky.TTtimes = Sky.times(Sky.TTs,1);                                     %timestamps for each trigger
    Sky.NumberOfTrigs = length(Sky.TTs);                                    %number of triggers detected
    try
        Sky.TTdur = time(between(Sky.TTtimes(1),Sky.TTtimes(end),'time'));      %duration of video between first and last trigger
    catch
        Sky.TTdur = [];
    end
    Sky.dur = time(between(Sky.times(1),Sky.times(end),'time'));            %duration of video
    %%%% We should incorporate a comparison with the number of SCTs for a sanity check here in the future
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DLC tracks
    try %if present, add tracked DLC points to the camera structure
        Sky.dlc.vid = dir('Sky_m*0_labeled.mp4');
        Sky.dlc.csv = dir('Sky_m*000.csv');
        Sky.dlc.raw = textscan(fopen(Sky.dlc.csv.name),'%q'); Sky.dlc.raw = Sky.dlc.raw{1};
        [Sky] = readDLCOutput(Sky);
    end
    try %if present, add filtered DLC points to the camera structure
        Sky.fdlc.vid = dir('Sky_m*filtered_labeled.mp4');
        Sky.fdlc.csv = dir('Sky_m*0_filtered.csv');
        Sky.fdlc.raw = textscan(fopen(Sky.fdlc.csv.name),'%q'); Sky.fdlc.raw = Sky.fdlc.raw{1};
        [Sky] = readfDLCOutput(Sky);
    end
    try %if present, add maDLC points to the camera structure
        Sky.madlc.vid = dir('Sky_m*0_el_bp_labeled.mp4');
        Sky.madlc.csv = dir('Sky_m*0_el_filtered.csv');
        Sky.madlc.raw = textscan(fopen(Sky.madlc.csv.name),'%q'); Sky.madlc.raw = Sky.madlc.raw{1};
        [Sky] = readmaDLCOutput(Sky);
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Add in path to ephys folder
    test = dir(); narrowdown = find([test.isdir]); %identifies folders present in our main experiment folder
    for k = narrowdown
        testing = strsplit(test(k).name,'_mouse-');
        if length(testing) > 1 %then it is a folder with '_mouse-' in its name, so it's almost certainly the OE folder...
            ephysfolder = strcat(test(k).folder,'\',test(k).name);
            ephysfolderName = test(k).name;
        end
    end
    try
        Sky.ephysfolder = ephysfolder;
    catch
        Sky.ephysfolder = []; %no ephys folder found for this experiment
    end
    [Sky.DataRoot,Sky.BdirName,~] = fileparts(pwd);
    Sky.DataRoot = strcat(Sky.DataRoot,'\');
    if ~isempty(Sky.ephysfolder)
        Sky.dirName = ephysfolderName;
    end
end
function [video] = GetAnalogVideo(varargin) %Returns a structure with video information
CamName = varargin{1}; TrueTrigTimes = varargin{2};

vidsearch = strcat(CamName,'_m*.mp4');
video.vid = dir(vidsearch);
    if length(video.vid) < 1
        errormessage = strcat('Couldnt find ',CamName,' video');
        error(errormessage)
    end
    if length(video.vid) > 1
        for i = 1:length(video.vid)
            if length(video.vid(i).name) == 39
                video.vid = video.vid(i); %choose raw video instead of DLC-labeled video if present in the folder
                break
            end
        end
    end
    obj = VideoReader(video.vid.name);
    video.vid.framerate = obj.FrameRate;
    video.vid.size = [obj.Width,obj.Height];
csvsearch = strcat(CamName,'_m*.csv');
video.csv = dir(csvsearch); %timestamps from bonsai
    if length(video.csv) < 1
        errormessage = strcat('Couldnt find ',CamName,' csv file');
        error(errormessage)
    end
    if length(video.csv) > 1
        for i = 1:length(video.csv)
            if length(video.csv(i).name) == 39
                video.csv = video.csv(i); %choose timestamp csv instead of DLC csv if one is present in the folder
                break
            end
        end
    end
    video.times = readtable(video.csv.name);
    video.times = video.times(:,17); video.times =  table2cell(video.times);
    video.length = length(video.times);
    for i=1:video.length
        video.times{i,:} = video.times{i,:}(1:27);
        video.times(i,:) = strrep(video.times(i,:),'T','_');
    end
    video.times = datetime(video.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');

    for i=1:length(TrueTrigTimes)
        video.TTs(i) = find(TrueTrigTimes(i)<video.times, 1); %framenumber of trigger
    end
    try
        video.TTtimes = video.times(video.TTs);                                     %timestamps for each trigger
        video.TTdur = time(between(video.TTtimes(1),video.TTtimes(end),'time'));    %duration of video between first and last trigger
    catch
        video.TTtimes = [];                                                         %no triggers were found
        video.TTdur = [];                                                           %no triggers were found
    end
    
% % %     interframeintervals = milliseconds(diff(video.times));
% % %     figure;
% % %     plot(interframeintervals,'.');
% % %     idealNframes = (milliseconds(video.dur)/1000)*30;
% % %     estimatedDroppedFrames = idealNframes - video.length;
% % %     figure;
% % %     plot(video.times,'.'); hold on;

    fieldBframes = interp1(1:video.length,video.times,(1:video.length)+0.5);
    fieldBframes(end) = video.times(end) + milliseconds(0.0167*1000);
    
% % %     plot((1:video.length)+0.5,fieldBframes,'.'); hold on;

    video.times = [video.times';fieldBframes];
    video.times = video.times(:)';
    
% % %     plot(video.times,'k.');
    
% % %     video.length = video.length*2;
    vidobject = VideoReader(video.vid.name);
    video.length = vidobject.NumberOfFrames;
    if ~isequal(video.length,length(video.times))
        try
            video.times = video.times(1:video.length);
        catch
%             flagVariable = video;
%             save('Flag_discordant.mat','flagVariable');
%             video.length = length(video.times);
        end
    end
    video.TTs = (video.TTs*2)-1;
    video.dur = time(between(video.times(1),video.times(end),'time'));      %duration of video
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DLC tracks
    try %if present, add tracked DLC points to the camera structure
        vidsearch = strcat(CamName,'_m*labeled.mp4'); csvsearch = strcat(CamName,'_m*000.csv');
        video.dlc.vid = dir(vidsearch);
        video.dlc.csv = dir(csvsearch);
        video.dlc.raw = textscan(fopen(video.dlc.csv.name),'%q'); video.dlc.raw =  video.dlc.raw{1};
%             [Sky] = readmaDLCOutput(Sky);
        [video] = readDLCOutput(video);
    end
    try %if present, add filtered DLC points to the camera structure
        vidsearch = strcat(CamName,'_m*full.mp4'); csvsearch = strcat(CamName,'_m*filtered.csv');
        video.fdlc.vid = dir(vidsearch);
        video.fdlc.csv = dir(csvsearch);
        video.fdlc.raw = textscan(fopen(video.fdlc.csv.name),'%q'); video.fdlc.raw =  video.fdlc.raw{1};
%             [Sky] = readmaDLCOutput(Sky);
        [video] = readfDLCOutput(video);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Add in path to ephys folder
    test = dir(); narrowdown = find([test.isdir]); %identifies folders present in our main experiment folder
    for k = narrowdown
        testing = strsplit(test(k).name,'_mouse-');
        if length(testing) > 1 %then it is a folder with '_mouse-' in its name, so it's almost certainly the OE folder...
            ephysfolder = strcat(test(k).folder,'\',test(k).name);
            ephysfolderName = test(k).name;
        end
    end
    try
        video.ephysfolder = ephysfolder;
    catch
        video.ephysfolder = []; %no ephys folder found for this experiment
    end
    [video.DataRoot,video.BdirName,~] = fileparts(pwd);
    video.DataRoot = strcat(video.DataRoot,'\');
    if ~isempty(video.ephysfolder)
        video.dirName = ephysfolderName;
    end
end

function [outputstructure] = readDLCOutput(inputstructure) %detects the unique points tracked and integrates them into the camera's matlab structure
    titles = strsplit(inputstructure.dlc.raw{2,1},','); titles = titles(2:end);
    numberofpoints = (length(titles))/3;        %number of unique points tracked
    u = unique(titles); %the names of each unique point tracked
    
    %This snippet identifies the X,Y,&P values in the csv for each unique tracked point in the csv file
    for i = 1:numberofpoints
        columnIdx = [];
        for ii = 1:length(titles)
            columnIdx = [columnIdx;isequal(u(i),{titles{ii}})];
        end
        columns{1,i} = u(i);
        columns{2,i} = find(columnIdx);
    end
    numberofframes = length(inputstructure.dlc.raw)-3;
    for i = 1:numberofpoints
        name = string(columns{1,i});
        inputstructure.dlc.(char(name)) = dlmread(inputstructure.dlc.csv.name,',',[3,columns{2,i}(1),numberofframes+2,columns{2,i}(end)]);
    end
    %End of snippet
    
    inputstructure.numberofpoints = numberofpoints;
    outputstructure = inputstructure;
end
function [outputstructure] = readfDLCOutput(inputstructure) %detects the unique points tracked and integrates them into the camera's matlab structure
    titles = strsplit(inputstructure.fdlc.raw{2,1},','); titles = titles(2:end);
    numberofpoints = (length(titles))/3;        %number of unique points tracked
    u = unique(titles); %the names of each unique point tracked
    
    %This snippet identifies the X,Y,&P values in the csv for each unique tracked point in the csv file
    for i = 1:numberofpoints
        columnIdx = [];
        for ii = 1:length(titles)
            columnIdx = [columnIdx;isequal(u(i),{titles{ii}})];
        end
        columns{1,i} = u(i);
        columns{2,i} = find(columnIdx);
    end
    numberofframes = length(inputstructure.fdlc.raw)-3;
    for i = 1:numberofpoints
        name = string(columns{1,i});
        inputstructure.fdlc.(char(name)) = dlmread(inputstructure.fdlc.csv.name,',',[3,columns{2,i}(1),numberofframes+2,columns{2,i}(end)]);
    end
    %End of snippet
    
    inputstructure.numberofpoints = numberofpoints;
    outputstructure = inputstructure;
end
function [outputstructure] = readmaDLCOutput(inputstructure) %detects the unique points tracked and integrates them into the camera's matlab structure
    individuals = strsplit(inputstructure.madlc.raw{2,1},','); individuals = individuals(2:end);
    titles = strsplit(inputstructure.madlc.raw{3,1},','); titles = titles(2:end);
    numberofpoints = (length(titles))/3;        %number of unique points tracked
    u = unique(titles); %the names of each unique point tracked
    
    %This snippet identifies the X,Y,&P values in the csv for each unique tracked point in the csv file
    for i = 1:numberofpoints
        columnIdx = [];
        for ii = 1:length(titles)
            columnIdx = [columnIdx;isequal(u(i),{titles{ii}})];
        end
        columns{1,i} = u(i);
        columns{2,i} = find(columnIdx);
    end
    numberofframes = length(inputstructure.madlc.raw)-4;
    for i = 1:numberofpoints
        name = string(columns{1,i});
        inputstructure.madlc.(char(name)) = dlmread(inputstructure.madlc.csv.name,',',[4,columns{2,i}(1),numberofframes+3,columns{2,i}(end)]);
    end
    %End of snippet
    
    inputstructure.numberofpoints = numberofpoints;
    outputstructure = inputstructure;
end

function [Sky] = GetSkyVideoRig2old(varargin) %Returns a structure with video information
Sky.vid = dir('Sky_*.mp4'); %raw video from bonsai
    if length(Sky.vid) < 1
        error('Couldnt find Sky video')
    end
    if length(Sky.vid) > 1
        for i = 1:length(Sky.vid)
            if length(Sky.vid(i).name) == 32
                Sky.vid = Sky.vid(i); %choose raw video instead of DLC-labeled video if present in the folder
                break
            end
        end
    end
    obj = VideoReader(Sky.vid.name);
    try
    Sky.vid.framerate = obj.FrameRate; 
    Sky.vid.size = [obj.Width,obj.Height];
    catch
        %on a mac, some bonsai mp4s cannot be read because of an invalid
        %audio codec. So we can use a system call to ffprobe to get the
        %framerate (which is all we need)
        [status, framerate]=system(sprintf('/usr/local/bin/ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate %s', Sky.vid.name))
        Sky.vid.framerate=str2num(strtok(framerate, '/'));

    end
    Sky.csv = dir('Sky_*.csv');
    if length(Sky.csv) > 1
        for i = 1:length(Sky.csv)
            if length(Sky.csv(i).name) == 32
                Sky.csv = Sky.csv(i); %choose timestamp csv instead of DLC csv if one is present in the folder
                break
            end
        end
    end
    Sky.times = textscan(fopen(Sky.csv.name),'%q'); Sky.times = Sky.times{1,1};
    Sky.times = Sky.times(17:17:end,:); Sky.times = cell2mat(Sky.times); Sky.times = Sky.times(:,1:27);
    Sky.length = length(Sky.times);
    for i=1:Sky.length
        Sky.times(i,:) = strrep(Sky.times(i,:),'T','_');
    end
    Sky.times = datetime(Sky.times, 'Format','yyyy-MM-dd_HH:mm:ss.SSSSSSS');
    if ~isequal(Sky.length,obj.NumberOfFrames)
        Sky.length = obj.NumberOfFrames;
        try
            Sky.times = Sky.times(1:Sky.length);
        catch
%             flagVariable = Sky;
%             save('Flag_discordant.mat','flagVariable');
        end
    end
    Sky.TTL = dir('TTL_*.csv'); Sky.TTL = textscan(fopen(Sky.TTL.name),'%q'); Sky.TTL = Sky.TTL{1,1};
    Sky.TTL = Sky.TTL(1:2:end,:); %trigger values
    Sky.TTs = find(~cellfun(@isempty,strfind(Sky.TTL,'True'))); %Framenumber for all triggered SkyCam frames
    
    %%%% This snippet here identifies the onset frame for each LED pulse,
    %%%% and saves them as Sky.TTs (which stands for 'TrueTriggers')
    temp = ones(size(length(Sky.TTs))); temp(1) = 90;
    for i=2:length(Sky.TTs)
        temp(i)=Sky.TTs(i)-Sky.TTs(i-1); %subtract previous trigger framenumber.
    end
    temp = temp - ones(size(temp)); temp = find(temp);
    try
        Sky.TTs = Sky.TTs(temp(1,:),1);
    catch
        Sky.TTs = [];
        disp('No LED triggers found!')
    end
    clear temp;
    %%%% End of that snippet
    
    Sky.TTtimes = Sky.times(Sky.TTs,1);                                     %timestamps for each trigger
    Sky.NumberOfTrigs = length(Sky.TTs);                                    %number of triggers detected
    try
        Sky.TTdur = time(between(Sky.TTtimes(1),Sky.TTtimes(end),'time'));      %duration of video between first and last trigger
    catch
        Sky.TTdur = [];
    end
    Sky.dur = time(between(Sky.times(1),Sky.times(end),'time'));            %duration of video
    %%%% We should incorporate a comparison with the number of SCTs for a sanity check here in the future
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DLC tracks
    try %if present, add tracked DLC points to the camera structure
        Sky.dlc.vid = dir('Sky_m*0_labeled.mp4');
        Sky.dlc.csv = dir('Sky_m*000.csv');
        Sky.dlc.raw = textscan(fopen(Sky.dlc.csv.name),'%q'); Sky.dlc.raw = Sky.dlc.raw{1};
        [Sky] = readDLCOutput(Sky);
    end
    try %if present, add filtered DLC points to the camera structure
        Sky.fdlc.vid = dir('Sky_m*filtered_labeled.mp4');
        Sky.fdlc.csv = dir('Sky_m*0_filtered.csv');
        Sky.fdlc.raw = textscan(fopen(Sky.fdlc.csv.name),'%q'); Sky.fdlc.raw = Sky.fdlc.raw{1};
        [Sky] = readfDLCOutput(Sky);
    end
    try %if present, add maDLC points to the camera structure
        Sky.madlc.vid = dir('Sky_m*0_el_bp_labeled.mp4');
        Sky.madlc.csv = dir('Sky_m*0_el_filtered.csv');
        Sky.madlc.raw = textscan(fopen(Sky.madlc.csv.name),'%q'); Sky.madlc.raw = Sky.madlc.raw{1};
        [Sky] = readmaDLCOutput(Sky);
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Add in path to ephys folder
    test = dir(); narrowdown = find([test.isdir]); %identifies folders present in our main experiment folder
    for k = narrowdown
        testing = strsplit(test(k).name,'_mouse-');
        if length(testing) > 1 %then it is a folder with '_mouse-' in its name, so it's almost certainly the OE folder...
            ephysfolder = strcat(test(k).folder,'\',test(k).name);
            ephysfolderName = test(k).name;
        end
    end
    try
        Sky.ephysfolder = ephysfolder;
    catch
        Sky.ephysfolder = []; %no ephys folder found for this experiment
    end
    [Sky.DataRoot,Sky.BdirName,~] = fileparts(pwd);
    Sky.DataRoot = strcat(Sky.DataRoot,'\');
    if ~isempty(Sky.ephysfolder)
        Sky.dirName = ephysfolderName;
    end

    %%%%%% Resolving potential mismatches between SCT and Events:
    notebookfile = fullfile(Sky.ephysfolder,'notebook.mat'); load(notebookfile);
    if ~isequal(Sky.NumberOfTrigs,length(stimlog)) %If the number of Sky.TTs doesnt match the number of SCTs
        currentdir = pwd; cd(Sky.ephysfolder)
            [~,~,~,chans.sampleRate,Events,~] = LoadExperiment();
            chans.start = Events(1).soundcard_trigger_timestamp_sec*chans.sampleRate;
            chans.stop = Events(end).soundcard_trigger_timestamp_sec*chans.sampleRate;
            curr_aux1_chan = dir('*X1.continuous');
            [rawdata, ~, ~] = load_open_ephys_data(curr_aux1_chan.name);
            chans.Length = length(rawdata); clear rawdata;
            cd(currentdir);
        [Sky] = FixMissingTTLs(Sky,Events,chans); %Essentially assimilates the events using the first and last trigger and "corrects" Sky.TTs and associated fields
    end
    %%%%%%
end

function [Sky] = FixMissingTTLs(Sky,Events,chans)

for idx = 1:length(Events) %Get the OpenEphys sample for each event
    EventSamples(idx) = round(Events(idx).soundcard_trigger_timestamp_sec*chans.sampleRate);
end

[OutputIndices] = ThisToThat_Lite(EventSamples,Events,Sky); %Get the corresponding Sky frame for each event

% "Correct" Sky.TTs and associated fields:
Sky.BrokenTTs = Sky.TTs;
Sky.TTs = OutputIndices';
Sky.TTtimes = Sky.times(Sky.TTs,1); %timestamps for each trigger
Sky.NumberOfTrigs = length(Sky.TTs); %number of triggers detected

end
function [OutputIndices] = ThisToThat_Lite(InputEventIndex,Events,Sky) %Run in either the bonsai folder, or it's OE folder]
%%%%% get position between trigs:
if ~isnan(Events(1).soundcard_trigger_timestamp_sec) %default to using the SCTs
    Trig1_in = (Events(1).soundcard_trigger_timestamp_sec)*30000;
    Trig2_in = (Events(end).soundcard_trigger_timestamp_sec)*30000;
    [TrigRatio] = GetTrigRatio(InputEventIndex,Trig1_in,Trig2_in);
else %but use the events if SCTs not recorded (GetEventsAndSCT_Timestamps will warn you in this case)
    Trig1_in = (Events(1).message_timestamp_samples);
    Trig2_in = (Events(end).message_timestamp_samples);
    [TrigRatio] = GetTrigRatio(InputEventIndex,Trig1_in,Trig2_in);
end
%%%%%% find equivalent sample between trigs, add offset by trig1 %%%%%%%
%     Trig1_out = Sky.TTtimes(1);
%     Trig2_out = Sky.TTtimes(end);
%     [IdealTime] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out);
%     [OutputIndices] = Time2Index(IdealTime, Sky);

    Trig1_out = Sky.TTs(1);
    Trig2_out = Sky.TTs(end);
    [OutputIndices] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out);
    OutputIndices = round(OutputIndices);
%     [OutputIndices] = Time2Index(IdealTime, Sky);

function [TrigRatio] = GetTrigRatio(InputEventIndex,Trig1_in,Trig2_in)
    TSBTinput = (Trig2_in)-(Trig1_in); %TotalSamplesBetweenTrigs
        for i = 1:length(InputEventIndex)
            TrigRatio(i) = (InputEventIndex(i)-Trig1_in(1))/(TSBTinput);
        end
end
function [OutputIndex] = GetOutputIndex(TrigRatio,Trig1_out,Trig2_out)
    TSBToutput = (Trig2_out)-(Trig1_out); %TotalSamplesBetweenTrigs
        for i = 1:length(TrigRatio)
            OutputIndex(i) = (TSBToutput*TrigRatio(i))+(Trig1_out);
        end
end
function [OutputIndex] = Time2Index(IdealTime, Sky)
    if isequal(IdealTime, 1)
    for i = 1:length(IdealTime)
        [~, OutputIndex(i)] = min(abs(Sky.times-IdealTime(i)));
    end
else
    [SortedIdealTime,Idx] = sort(IdealTime);
    i1 =1;
    for i = 1:length(SortedIdealTime)
        while (Sky.times(i1)-SortedIdealTime(i))<0
            i1=i1+1;
        end
        [~,x] = min(abs(Sky.times(i1-1:i1)-SortedIdealTime(i)));
        OutputIndex(i) =  i1+x-2;
        i1 = i1-1;
    end
    newInd(Idx) = 1:length(IdealTime);
    OutputIndex = OutputIndex(newInd);
end
end
end