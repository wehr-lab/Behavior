%Example function plotting spiketimes, pupildiameter and SCT:

function [fig] = PlotPupil(BonsaiDir,EphysDir)
%% 1) load the data files for the trial:

BehaviorFileStr = strcat(BonsaiDir, filesep, 'Beh*.mat');
BehaviorFile = strcat(BonsaiDir,filesep,dir(BehaviorFileStr).name);
    load(BehaviorFile);
SortedUnitsFileStr = strcat(EphysDir,filesep,'Sort*.mat');
SortedUnitsFile = strcat(EphysDir,filesep,dir(SortedUnitsFileStr).name);
    load(SortedUnitsFile);
notebookfile = fullfile(EphysDir,'notebook.mat');
    load(notebookfile);

%% 2) load djmaus data:
currentdir = pwd; cd(EphysDir)
[~,~,~,chans.sampleRate,Events,~] = LoadExperiment(); 
for i = 1:length(Events)
    EventSamples(i) = Events(i).soundcard_trigger_timestamp_sec*sampleRate;
end
chans.start = Events(1).soundcard_trigger_timestamp_sec*sampleRate;
chans.stop = Events(end).soundcard_trigger_timestamp_sec*sampleRate;
cd(currentdir);

%% 3) Get all the spiketimes and pupil diameters for each stimulus:
xlimits = [-500,500]; %time window in ms for extracting spikes, relative to stim onset, e.g. -200 to 200
for idx=1:length(Events)
    if strcmp(Events(idx).type, 'tone') || strcmp(Events(idx).type, 'whitenoise') || strcmp(Events(idx).type, 'silentsound')
        if isfield(Events(idx), 'soundcard_trigger_timestamp_sec')
            pos = Events(idx).soundcard_trigger_timestamp_sec*sampleRate();
        else
            error('stimulus delivery timestamp missing')
        end

        %get stimulus params from Events(idx)
        data(idx).stim = stimlog(idx).stimulus_description;

        %get start and stop samples for OpenEphys:
        data(idx).OEstart = (pos+xlimits(1)*(1/1000)*sampleRate); %in samples
        data(idx).OEstop = (pos+xlimits(2)*(1/1000)*sampleRate); %in samples
        
        %get start and stop frames for Reye camera:
        data(idx).ReyeStart = Reye.TTs(idx)+xlimits(1)*(1/1000)*Reye.vid.framerate; %frame number for start
        data(idx).ReyeStop = Reye.TTs(idx)+xlimits(2)*(1/1000)*Reye.vid.framerate; %frame number for stop

        %get spiketimes for each cell between start &stop
        for cellnumber = 1:length(SortedUnits)
            st = SortedUnits(cellnumber).spiketimes*sampleRate; %spikestimes in sample number
            firstIdx = find(st > data(idx).OEstart,1,'first');
            lastIdx = find(st < data(idx).OEstop,1,'last');
            %spikestimes in sample number, offset by OEstart, and centered in the window:
            data(idx).spiketimes{cellnumber} = st(firstIdx:lastIdx)-data(idx).OEstart+xlimits(1)*(1/1000)*sampleRate;
        end

        %Get pupil diameter values within this range:
        data(idx).PD = (Reye.PupilDiameter(data(idx).ReyeStart:data(idx).ReyeStop));
    end
end

%% 4) Example plotting of a specific stimulus and cellnumber
StimulusString = 'tone frequency:2000 amplitude:60 duration:25 laser:0 ramp:3 next:800';
cellnumber = 1;
% The function overlays pupil traces, which is very uninformative, but
% shows
[fig] = PlotPupilSingle(data,StimulusString,cellnumber,sampleRate);

end

function [fig] = PlotPupilSingle(data,StimulusString,cellnumber,sampleRate)
indices = [];
for idx = 1:length(data)
    if isequal(data(idx).stim,StimulusString) %find the stims matching the string
        indices = [indices,idx];
    end
end

Colors = cool(120);
fig = figure;
subplot(2,1,1); title(StimulusString); hold on;
plot([30,30],[0,120],'k--');
for idx=indices
    ColorValue(idx) = round(mean(data(idx).PD(:)));
    if isnan(ColorValue(idx))
        ColorValue(idx) = 1;
    end
    PupilDiameter = plot(data(idx).PD(:),'-','Color',Colors(ColorValue(idx),:),'DisplayName','PupilDiameter','MarkerSize',5);
end
ylim([0,120]); xlim([0,60]);
xticks([0,30,60]);
xticklabels({'-500ms','0ms','500ms'});
ylabel('Pupil Diameter (pixels)');

k = 1;
subplot(2,1,2); hold on
plot([0,0],[0,length(indices)],'k--')
for idx=indices
    ydata = ones(size(data(idx).spiketimes{cellnumber}))*k;
    spikes{k} = plot((data(idx).spiketimes{cellnumber}/sampleRate),ydata,'.','Color',Colors(ColorValue(idx),:));
    k = k+1;
end
xticks([-0.5,0,0.5]);
xticklabels({'-500ms','0ms','500ms'});
titlestring = strcat('Cell ID #',num2str(cellnumber));
title(titlestring);
ylabel('Stimulus repitition'); grid on;
end