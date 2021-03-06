function ProcessCams(varargin)

%% Sky Cam:
[Sky] = GetSkyVideo();

%% Analog Cams:
if nargin>=1
    [Head] = GetAnalogVideo('Head',Sky.TTtimes);
    [Lear] = GetAnalogVideo('Lear',Sky.TTtimes);
    [Rear] = GetAnalogVideo('Rear',Sky.TTtimes);
%     [Forw] = GetAnalogVideo('Forw',Sky.TTtimes);
%     [Leye] = GetAnalogVideo('Leye',Sky.TTtimes);
%     [Reye] = GetAnalogVideo('Reye',Sky.TTtimes);
%     [Eye] = GetAnalogVideo('Eye',Sky.TTtimes);
end

%% Save the camera structures in a .mat file named 'Behavior_mouse-IDnm_YYYY-MM-DDTHH_MM_SS.mat'
Behavior = strcat('Behavior', Sky.vid.name(4:34));
if nargin>=1
    save(Behavior,'Sky','Head','Lear','Rear')
else
    save(Behavior,'Sky')
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
    DetectTracking = dir('Sky_m*000.csv'); %see if there is a DLC csv in the directory
    if ~isequal(length(DetectTracking),0) %if so, add the tracked points to the camera structure
        Sky.dlc.vid = dir('Sky_m*labeled.mp4');
        Sky.dlc.csv = dir('Sky_m*000.csv');
        Sky.dlc.raw = textscan(fopen(Sky.dlc.csv.name),'%q'); Sky.dlc.raw = Sky.dlc.raw{1};
        [Sky] = readDLCOutput(Sky);
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Add in path to ephys folder
    test = dir(); narrowdown = find([test.isdir]); %identifies folders present in our main experiment folder
    for k = 1:length(narrowdown)
        testing = strsplit(test(k).name,'_mouse-');
        if length(testing) > 1 %then it is a folder with '_mouse-' in its name, so it's almost certainly the OE folder...
            ephysfolder = strcat(test(k).folder,'\',test(k).name);
        end
    end
    try
        Sky.ephysfolder = ephysfolder;
    catch
        Sky.ephysfolder = []; %no ephys folder found for this experiment
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
            if length(video.csv(i).name) == 39
                video.vid = video.vid(i); %choose raw video instead of DLC-labeled video if present in the folder
                break
            end
        end
    end
    obj = VideoReader(video.vid.name);
    video.vid.framerate = obj.FrameRate;
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
    video.dur = time(between(video.times(1),video.times(end),'time'));      %duration of video
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DLC tracks
    DetectTracking = strcat(CamName,'_m*000.csv'); DetectTracking = dir(DetectTracking); %see if there is a DLC csv in the directory
    if ~isequal(length(DetectTracking),0) %if so, add the tracked points to the camera structure
        vidsearch = strcat(CamName,'_m*labeled.mp4'); csvsearch = strcat(CamName,'_m*000.csv');
        video.dlc.vid = dir(vidsearch);
        video.dlc.csv = dir(csvsearch);
        video.dlc.raw = textscan(fopen(video.dlc.csv.name),'%q'); video.dlc.raw = video.dlc.raw{1};
        [video] = readDLCOutput(video);
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
function [Skyframe] = DI2Sky(varargin) %varargin = InputVid,DIframe

    %Returns Skyframe# closest in time to InputVidFrame#
    InputVid = varargin{1};
    DIframe = varargin{2};
    Sky = varargin{3};
    
    test = milliseconds(InputVid.times(DIframe) - Sky.times);
    frame = find(test<0,1);
    if isempty(frame)
        frame = length(test);
    end
    timeaftertime = milliseconds(Sky.times(frame)-InputVid.times(DIframe));
    timebefortime = milliseconds(Sky.times(frame-1)-InputVid.times(DIframe));
    
    if abs(timeaftertime)<abs(timebefortime)
        Skyframe = frame;
    elseif abs(timebefortime)<abs(timeaftertime)
        Skyframe = frame-1;
    elseif abs(timebefortime)==abs(timeaftertime)
        Skyframe = frame-1;
    end

end