function ProcessCams(varargin)

%% Sky Cam:
[Sky] = GetSkyVideo();
%% Analog Cams:
if nargin>=1
    [Head] = GetAnalogVideo('Head',Sky.TTtimes);
    [Lear] = GetAnalogVideo('Lear',Sky.TTtimes);
    [Rear] = GetAnalogVideo('Rear',Sky.TTtimes);
%     [Forw] = GetAnalogVideo('Forw',Sky.TTtimes);
else
end
%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save
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
    
    %%%% This snippet here identifies the first frame for each LED pulse,
    %%%% and saves them as Sky.TTs (which stands for 'TrueTriggers'
    temp = ones(size(length(Sky.TTs))); temp(1) = 90;
    for i=2:length(Sky.TTs)
        temp(i)=Sky.TTs(i)-Sky.TTs(i-1); %subtract previous trigger framenumber.
    end
    temp = temp - ones(size(temp)); temp = find(temp);
    Sky.TTs = Sky.TTs(temp(1,:),1); clear temp;
    %%%% End of that snippet
    
    Sky.TTtimes = Sky.times(Sky.TTs,1); %timestamps for each trigger
    Sky.NumberOfTrigs = length(Sky.TTs); %number of triggers detected
    Sky.TTdur = time(between(Sky.TTtimes(1),Sky.TTtimes(end),'time')); %duration of video between first and last trigger
    Sky.dur = time(between(Sky.times(1),Sky.times(end),'time')); %duration of video
    %We should incorporate a comparison with the number of SCTs for a
    %sanity check here in the future
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
    video.TTtimes = video.times(video.TTs); %timestamps for each trigger
    video.TTdur = time(between(video.TTtimes(1),video.TTtimes(end),'time')); %duration of video between first and last trigger
    video.dur = time(between(video.times(1),video.times(end),'time')); %duration of video
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