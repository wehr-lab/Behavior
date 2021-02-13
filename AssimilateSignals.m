function [vids,units,chans] = AssimilateSignals(varargin) %run in bonsai folder
behaviorfile = dir('Beh*.mat'); load(behaviorfile.name); %loads behavior file
    
%% set range of analysis
    if nargin < 1
        SkyStart = Sky.TTs(1); %default to segment in time between first and last trigger
        SkyStop = Sky.TTs(end);
    else
        SkyStart = varargin{1}; %a custom range was inputted
        SkyStop = varargin{2};
    end
    
%% declare videos & calculate ranges
    vids = [];
    vids{1,1} = 'Sky';
    vids{1,2} = strcat(Sky.vid.folder,'\',Sky.vid.name);
    vids{1,3} = SkyStart;
    vids{1,4} = SkyStop;
    
    if exist('Lear','var')
        vids{3,1} = 'Lear';
        vids{3,2} = strcat(Lear.vid.folder,'\',Lear.vid.name);
        vids{3,3} = ThisToThat('Sky',SkyStart,'Lear');
        vids{3,4} = ThisToThat('Sky',SkyStop,'Lear');
        vids{4,1} = 'Rear';
        vids{4,2} = strcat(Rear.vid.folder,'\',Rear.vid.name);
        vids{4,3} = ThisToThat('Sky',SkyStart,'Rear');
        vids{4,4} = ThisToThat('Sky',SkyStop,'Rear');
        vids{2,1} = 'Head';
        vids{2,2} = strcat(Head.vid.folder,'\',Head.vid.name);
        vids{2,3} = ThisToThat('Sky',SkyStart,'Head');
        vids{2,4} = ThisToThat('Sky',SkyStop,'Head');
    end
        
    for i = 1:size(vids,1)
        vids{i,5} = vids{i,4}-vids{i,3}; %number of frames in range
    end
    
%% find units, calculate range, generate spike rasters
    cd(Sky.ephysfolder)
    Header = dir('*_CH1.continuous'); Header = strsplit(Header.name,'_'); Header = Header{1}; test = strcat(Header,'_CH1.continuous');
    [temp, ~, ~] = load_open_ephys_data(test);
    TotalSamples = length(temp); %total recording samples for this trial
    [~,~,~,sampleRate,~,~] = LoadExperiment();  close; %load the sampleRate
    units = []; blank = zeros(1,TotalSamples);
    try
        load('st.mat'); %spiketimes, in seconds after start of acquisition of this trial
    for i = 1:length(st) %for each unit
        units{i,1} = st{2,i}; %note its chan, clust, and cellID
        spikes = st{1,i}*sampleRate; %convert spiketimes to samples after start of acquisition
        trace = blank;
        for ii = 1:length(spikes)
           trace(1,round(spikes(ii))) = 1; %
        end
        units{i,2} = trace;       %total recording samples for trial with spikes as ones    
        units{i,3} = ThisToThat('Sky',SkyStart,'OE');  %SkyStart samplenumber
        units{i,4} = ThisToThat('Sky',SkyStop,'OE');  %SkyStop samplenumber
    end
    for i = 1:size(units,1)
        units{i,5} = units{i,4}-units{i,3}; %total samples between SkyStart and SkyStop
    end
    catch
    end
    
%% declare Continuous traces & calculate ranges
	%First 3 are always the accelerometer traces
    chans = []; Header = dir('*_AUX1.continuous'); Header = strsplit(Header.name,'_'); Header = Header{1};
    chans{1,1} = 'ACCLRM.FB';
    chans{1,2} = strcat(Sky.ephysfolder,'\',Header,'_AUX1.continuous');
    chans{1,3} = ThisToThat('Sky',SkyStart,'OE');
    chans{1,4} = ThisToThat('Sky',SkyStop,'OE');
    chans{1,5} = chans{1,4} - chans{1,3};
    chans{2,1} = 'ACCLRM.UD';
    chans{2,2} = strcat(Sky.ephysfolder,'\',Header,'_AUX2.continuous');
    chans{2,3} = chans{1,3};
    chans{2,4} = chans{1,4};
    chans{2,5} = chans{1,5};
    chans{3,1} = 'ACCLRM.LR';
    chans{3,2} = strcat(Sky.ephysfolder,'\',Header,'_AUX3.continuous');
    chans{3,3} = chans{1,3};
    chans{3,4} = chans{1,4};
    chans{3,5} = chans{1,5};
    
    %Additional chans are single channels, if desired
    [phys] = GetPhysiology(Sky);
    if length(phys)>1
        for i = 1:length(phys)
            chans{i+3,1} = phys(i).Area;
            chans{i+3,2} = strcat(Sky.ephysfolder,'\',phys(i).filename);
            chans{i+3,3} = chans{1,3};
            chans{i+3,4} = chans{1,4};
        end
        for i = 1:size(chans,1)
            chans{i,5} = chans{i,4}-chans{i,3};
        end
    else
    end
    
%% return to bonsai folder
cd(Sky.vid.folder)

end

function [phys] = GetPhysiology(Sky)
    if exist('E:\Nick\MouseConfigurations', 'dir')
        currentdir = pwd; %remember where we started
        mouseID = strsplit(Sky.ephysfolder,'mouse-'); mouseID = mouseID{end};
        cd('E:\Nick\MouseConfigurations')
        configurationfile = strcat('mouse', mouseID, '.mat');
        try
            load(configurationfile);
        catch
            PhysConfig = []; %no configuration file = all channels/TTs are in one brain location
        end
        phys = PhysConfig;
        cd(currentdir);
    else
        phys = [];
    end
end