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
    vids(1).name = 'Sky';
    vids(1).file = strcat(Sky.vid.folder,'\',Sky.vid.name);
    vids(1).start = SkyStart;
    vids(1).stop = SkyStop;
    
    if exist('Lear','var')
        vids(3).name = 'Lear';
        vids(3).file = strcat(Lear.vid.folder,'\',Lear.vid.name);
        vids(3).start = ThisToThat('Sky',SkyStart,'Lear');
        vids(3).stop = ThisToThat('Sky',SkyStop,'Lear');
        vids(4).name = 'Rear';
        vids(4).file = strcat(Rear.vid.folder,'\',Rear.vid.name);
        vids(4).start = ThisToThat('Sky',SkyStart,'Rear');
        vids(4).stop = ThisToThat('Sky',SkyStop,'Rear');
        vids(2).name = 'Head';
        vids(2).file = strcat(Head.vid.folder,'\',Head.vid.name);
        vids(2).start = ThisToThat('Sky',SkyStart,'Head');
        vids(2).stop = ThisToThat('Sky',SkyStop,'Head');
    end
    
%% calculate OpenEphys range & get spiketimes of sorted units
    OEstart = ThisToThat('Sky',SkyStart,'OE');  %OpenEphys start samplenumber
    OEstop = ThisToThat('Sky',SkyStop,'OE');  %OpenEphys stop samplenumber

    cd(Sky.ephysfolder)
    try
        load('SortedUnits.mat'); %spiketimes, in seconds after start of acquisition of this trial
        for i = 1:length(SortedUnits) %for each unit
            units(i).name = SortedUnits(i).cellnum; %CellID for each sorted unit
            units(i).spiketimes = SortedUnits(i).spiketimes; %spiketimes for this trial, in seconds after the start of acquisition for this trial
            units(i).start = OEstart/sampleRate;  %OpenEphys start converted to seconds
            units(i).stop = OEstop/sampleRate;  %OpenEphys stop converted to seconds
            units(i).channel = SortedUnits(i).channel;
            units(i).cluster = SortedUnits(i).cluster;
            units(i).rating = SortedUnits(i).rating;
            units(i).sampleRate = sampleRate;
        end
    catch
        disp('no SortedUnits.mat file found')
        units = {};
    end
    
%% declare Continuous traces & calculate ranges
	%First 3 are always the accelerometer traces
    Header = dir('*_AUX1.continuous'); Header = strsplit(Header.name,'_'); Header = Header{1};
    chans(1).name = 'ACCLRM-FB';
    chans(1).file = strcat(Sky.ephysfolder,'\',Header,'_AUX1.continuous');
    chans(1).start = OEstart;
    chans(1).stop  = OEstop;
    chans(1).sampleRate = sampleRate;
    chans(2).name = 'ACCLRM-UD';
    chans(2).file = strcat(Sky.ephysfolder,'\',Header,'_AUX2.continuous');
    chans(2).start = OEstart;
    chans(2).stop = OEstop;
    chans(2).sampleRate = sampleRate;
    chans(3).name = 'ACCLRM-LR';
    chans(3).file = strcat(Sky.ephysfolder,'\',Header,'_AUX3.continuous');
    chans(3).start = OEstart;
    chans(3).stop = OEstop;
    chans(3).sampleRate = sampleRate;
    
    %Additional chans are single channels, if desired
    [phys] = GetPhysiology(Sky);
    if length(phys)>1
        for i = 1:length(phys)
            chans(i+3).name = phys(i).Area;
            chans(i+3).file = strcat(Sky.ephysfolder,'\',phys(i).filename);
            chans(i+3).start = OEstart;
            chans(i+3).stop = OEstop;
            chans(i+3).sampleRate = sampleRate;
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